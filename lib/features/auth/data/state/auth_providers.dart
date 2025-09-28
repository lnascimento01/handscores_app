// lib/features/auth/state/auth_providers.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import 'package:handscore/core/network/dio_client.dart';
import 'package:handscore/features/auth/data/auth_api.dart';
import 'package:handscore/features/auth/data/auth_repository.dart';
import 'package:handscore/features/auth/data/models.dart';

// ========= Base URL de desenvolvimento (apenas se não vier por --dart-define=API_BASE) =========
String _defaultBase() {
  if (kIsWeb) return 'https://localhost:8686/api/v1';
  if (Platform.isAndroid) return 'https://10.0.2.2:8686/api/v1';
  return 'https://127.0.0.1:8686/api/v1';
}

extension _StrX on String {
  String ifEmpty(String Function() fb) => isEmpty ? fb() : this;
}

// ========= Providers de rede/auth =========
final dioProvider = Provider((ref) {
  final base = const String.fromEnvironment(
    'API_BASE',
    defaultValue: '',
  ).ifEmpty(_defaultBase);
  final client = DioClient(base); // base já deve incluir /api/v1
  return client.dio;
});

final authApiProvider = Provider((ref) => AuthApi(ref.read(dioProvider)));
final authRepoProvider = Provider(
  (ref) => AuthRepository(ref.read(authApiProvider)),
);

// ========= Estado/Auth =========
enum AuthFlow { idle, loading, mfaNeeded, authenticated, error }

class AuthState {
  final AuthFlow flow;
  final String? tempToken;
  final int countdown;  
  final String? error;
  final Map<String, List<String>> fieldErrors;

  // NOVOS:
  final List<String> mfaChannels;
  final int? challengeId;
  final String? selectedChannel;

  const AuthState({
    this.flow = AuthFlow.idle,
    this.tempToken,
    this.mfaChannels = const [],
    this.selectedChannel,
    this.challengeId,
    this.countdown = 0,
    this.fieldErrors = const {},
    this.error,
  });

  AuthState copyWith({
    AuthFlow? flow,
    String? tempToken,
    List<String>? mfaChannels,
    String? selectedChannel,
    int? challengeId,
    int? countdown,
    Map<String, List<String>>? fieldErrors,
    String? error,
  }) {
    return AuthState(
      flow: flow ?? this.flow,
      tempToken: tempToken ?? this.tempToken,
      error: error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      mfaChannels: mfaChannels ?? this.mfaChannels,
      challengeId: challengeId ?? this.challengeId,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      countdown: countdown ?? this.countdown,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repo;
  AuthController(this.repo) : super(const AuthState(AuthFlow.idle));

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState(AuthFlow.loading);
    try {
      await repo.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
        ),
      );

      // após auto-login, reusa a mesma lógica do login()
      await login(email: email, password: password);
    } on DioException catch (e) {
      // (mesmo tratamento que você já tem)
      // ...
      final code = e.response?.statusCode ?? 0;
      Map<String, List<String>> fieldErrors = const {};
      String msg = 'Falha ao registrar';
      if (code == 422) {
        fieldErrors = _extractFieldErrors(e.response?.data);
        msg = _firstValidationError(fieldErrors) ?? msg;
      } else if (code == 409) {
        msg = 'E-mail já cadastrado';
      } else if (code == 429) {
        final retryAfter = e.response?.headers.value('retry-after');
        msg = retryAfter != null
            ? 'Muitas tentativas. Tente novamente em ${retryAfter}s.'
            : 'Muitas tentativas. Tente novamente em instantes.';
      } else if (code >= 500) {
        msg = 'Erro no servidor ($code). Tente mais tarde.';
      }
      state = AuthState(AuthFlow.error, error: msg, fieldErrors: fieldErrors);
    } catch (e) {
      state = AuthState(AuthFlow.error, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(AuthFlow.loading);
    try {
      final res = await repo.login(email: email, password: password);

      if (res.mfaRequired) {
        // escolha um canal default
        final channel = (res.mfaChannels.isNotEmpty)
            ? res.mfaChannels.first
            : 'totp';

        // se backend já devolveu challengeId, use; senão crie agora
        int? challengeId = res.challengeId;
        challengeId ??= await repo.requestMfaChallenge(channel);

        state = AuthState(
          AuthFlow.mfaNeeded,
          mfaChannels: res.mfaChannels,
          challengeId: challengeId,
          selectedChannel: channel,
        );
        return;
      }

      state = const AuthState(AuthFlow.authenticated);
    } on DioException catch (e) {
      // (mesmo tratamento que você já tem)
      final code = e.response?.statusCode ?? 0;
      Map<String, List<String>> fieldErrors = const {};
      String msg = 'Falha ao entrar';
      if (code == 422) {
        fieldErrors = _extractFieldErrors(e.response?.data);
        msg = _firstValidationError(fieldErrors) ?? msg;
      } else if (code == 401) {
        msg = 'Credenciais inválidas';
      } else if (code == 429) {
        final retryAfter = e.response?.headers.value('retry-after');
        msg = retryAfter != null
            ? 'Muitas tentativas. Tente novamente em ${retryAfter}s.'
            : 'Muitas tentativas. Tente novamente em instantes.';
      } else if (code >= 500) {
        msg = 'Erro no servidor ($code). Tente mais tarde.';
      }
      state = AuthState(AuthFlow.error, error: msg, fieldErrors: fieldErrors);
    } catch (e) {
      state = AuthState(AuthFlow.error, error: e.toString());
    }
  }

  // permite trocar canal, reemitindo challenge
  Future<void> requestMfaChannel(String channel) async {
    try {
      final challengeId = await repo.requestMfaChallenge(channel);
      if (challengeId == null) {
        state = state.copyWith(
          flow: AuthFlow.error,
          error: 'Não foi possível gerar o código MFA.',
        );
        return;
      }
      state = state.copyWith(
        flow: AuthFlow.mfaNeeded,
        selectedChannel: channel,
        challengeId: challengeId,
      );
    } catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        error: 'Falha ao solicitar código',
      );
    }
  }

  Future<void> verifyMfa(String code) async {
    state = state.copyWith(flow: AuthFlow.loading);
    try {
      await repo.verifyMfa(code, challengeId: state.challengeId);
      state = const AuthState(AuthFlow.authenticated);
    } on DioException catch (e) {
      String msg = 'Falha ao verificar código';
      final codeStatus = e.response?.statusCode ?? 0;
      if (codeStatus == 422) {
        final data = e.response?.data;
        final errors = (data is Map && data['errors'] is Map)
            ? data['errors'] as Map
            : {};
        final first = _firstValidationError(errors);
        if (first != null) msg = first;
      } else if (codeStatus == 401) {
        msg = 'Código inválido ou expirado';
      } else if (codeStatus == 429) {
        final retryAfter = e.response?.headers.value('retry-after');
        msg = retryAfter != null
            ? 'Muitas tentativas. Tente novamente em ${retryAfter}s.'
            : 'Muitas tentativas. Tente novamente em instantes.';
      } else if (codeStatus >= 500) {
        msg = 'Erro no servidor (${e.response?.statusCode}). Tente mais tarde.';
      }
      state = state.copyWith(flow: AuthFlow.error, error: msg);
    } catch (e) {
      state = state.copyWith(flow: AuthFlow.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await repo.logout();
    } catch (_) {}
    state = const AuthState(AuthFlow.idle);
  }
}

// ========= Provider do controller =========
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authRepoProvider)),
);

// ========= Helpers =========
String? _firstValidationError(Map errors) {
  try {
    final first = errors.values
        .cast<List>()
        .expand((l) => l)
        .cast<dynamic>()
        .map((e) => e?.toString())
        .firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);
    return first;
  } catch (_) {
    return null;
  }
}

Map<String, List<String>> _extractFieldErrors(Object? data) {
  if (data is! Map || data['errors'] is! Map) return const {};
  final Map<String, dynamic> errs = Map<String, dynamic>.from(
    data['errors'] as Map,
  );
  return errs.map((k, v) {
    final list = (v is List ? v : [v])
        .map((e) => e.toString())
        .toList(growable: false);
    return MapEntry(k.toString(), list);
  });
}
