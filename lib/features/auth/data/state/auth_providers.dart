import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:handscore/core/device/device_identity.dart';
import 'package:riverpod/riverpod.dart';

import 'package:handscore/core/network/dio_client.dart';
import 'package:handscore/features/auth/data/auth_api.dart';
import 'package:handscore/features/auth/data/auth_repository.dart';
import 'package:handscore/features/auth/data/models.dart';
import 'package:handscore/core/ui/global_loading.dart';

typedef Json = Map<String, dynamic>;

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
final dioProvider = Provider<Dio>((ref) {
  final base = const String.fromEnvironment(
    'API_BASE',
    defaultValue: '',
  ).ifEmpty(_defaultBase);
  final client = DioClient(base);

  // ⬇️ Loader global amarrado ao Riverpod
  final loading = ref.read(globalLoadingProvider.notifier);

  client.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        loading.begin();
        h.next(o);
      },
      onResponse: (r, h) {
        loading.end();
        h.next(r);
      },
      onError: (e, h) {
        loading.end();
        h.next(e);
      },
    ),
  );

  return client.dio;
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.read(dioProvider)),
);
final authRepoProvider = Provider<AuthRepository>(
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

  // MFA
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
      mfaChannels: mfaChannels ?? this.mfaChannels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      challengeId: challengeId ?? this.challengeId,
      countdown: countdown ?? this.countdown,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repo;
  final Ref ref;
  AuthController(this.ref, this.repo) : super(const AuthState());

  // ========= Registro =========
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(
      flow: AuthFlow.loading,
      error: null,
      fieldErrors: const {},
    );
    try {
      await repo.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation, // ✅ corrige bug
        ),
      );
      await login(email: email, password: password);
    } on DioException catch (e) {
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

      state = state.copyWith(
        flow: AuthFlow.error,
        error: msg,
        fieldErrors: fieldErrors,
      );
    } catch (e) {
      state = state.copyWith(flow: AuthFlow.error, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      flow: AuthFlow.loading,
      error: null,
      fieldErrors: const {},
    );
    try {
      final id = await DeviceIdentity.ensure();
      final res = await repo.login(
        email: email,
        password: password,
        deviceId: id.id,
        deviceName: id.name,
        platform: id.platform,
      );

      if (res.mfaRequired == true) {
        final channels = res.mfaChannels;
        final channel = channels.isNotEmpty ? channels.first : 'totp';

        int? challengeId = res.challengeId;
        if (challengeId == null) {
          final raw = await repo.requestMfaChallenge(channel);
          final ch = MfaChallenge.parse(raw);
          challengeId = ch.id;
          if ((ch.expiresIn ?? 0) > 0) {
            state = state.copyWith(countdown: ch.expiresIn);
          }
        }

        state = state.copyWith(
          flow: AuthFlow.mfaNeeded,
          tempToken: res.tempToken,
          mfaChannels: channels,
          selectedChannel: channel,
          challengeId: challengeId,
        );
        return;
      }

      state = state.copyWith(flow: AuthFlow.authenticated, error: null);
    } on DioException catch (e) {
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

      state = state.copyWith(
        flow: AuthFlow.error,
        error: msg,
        fieldErrors: fieldErrors,
      );
    } catch (e) {
      state = state.copyWith(flow: AuthFlow.error, error: e.toString());
    }
  }

  // ========= MFA: trocar canal e gerar challenge =========
  Future<void> requestMfaChannel(String channel) async {
    try {
      final Object? raw = await repo.requestMfaChallenge(channel);
      final ch = MfaChallenge.parse(raw);

      if (ch.id == null) {
        state = state.copyWith(
          flow: AuthFlow.error,
          error: 'Não foi possível gerar o código MFA.',
        );
        return;
      }

      state = state.copyWith(
        flow: AuthFlow.mfaNeeded,
        selectedChannel: channel,
        challengeId: ch.id,
        countdown: ch.expiresIn ?? state.countdown,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        flow: AuthFlow.error,
        error: 'Falha ao solicitar código',
      );
    }
  }

  // ========= MFA: verificar código =========
  Future<void> verifyMfa(String code) async {
    state = state.copyWith(flow: AuthFlow.loading, error: null);
    try {
      await repo.verifyMfa(code, challengeId: state.challengeId);
      state = state.copyWith(flow: AuthFlow.authenticated, error: null);
    } on DioException catch (e) {
      String msg = 'Falha ao verificar código';
      final codeStatus = e.response?.statusCode ?? 0;
      if (codeStatus == 422) {
        final Map<String, List<String>> errors = _extractFieldErrors(
          e.response?.data,
        );
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
        msg = 'Erro no servidor ($codeStatus). Tente mais tarde.';
      }
      state = state.copyWith(flow: AuthFlow.error, error: msg);
    } catch (e) {
      state = state.copyWith(flow: AuthFlow.error, error: e.toString());
    }
  }

  // ========= Logout =========
  Future<void> logout() async {
    try {
      await repo.logout();
    } catch (_) {}
    state = const AuthState();
  }
}

// ========= Provider do controller =========
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref, ref.read(authRepoProvider)),
);

// ========= Helpers =========
String? _firstValidationError(Map<String, List<String>> errors) {
  try {
    for (final entry in errors.entries) {
      final list = entry.value;
      if (list.isNotEmpty) {
        final first = list.first;
        if (first.isNotEmpty) return first;
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

Map<String, List<String>> _extractFieldErrors(Object? data) {
  if (data is! Map) return const {};
  final dynamic raw = data['errors'];
  if (raw is! Map) return const {};

  final Map<String, List<String>> out = {};
  raw.forEach((key, value) {
    if (value is List) {
      out[key.toString()] = value
          .map((e) => e.toString())
          .toList(growable: false);
    } else if (value != null) {
      out[key.toString()] = [value.toString()];
    }
  });
  return out;
}

class MfaChallenge {
  final int? id;
  final int? expiresIn;

  const MfaChallenge({this.id, this.expiresIn});

  static MfaChallenge parse(Object? raw) {
    if (raw == null) return const MfaChallenge();
    if (raw is int) return MfaChallenge(id: raw);

    if (raw is Map) {
      final id =
          (raw['challenge_id'] as num?)?.toInt() ??
          (raw['id'] as num?)?.toInt();
      final exp = (raw['expires_in'] as num?)?.toInt();
      return MfaChallenge(id: id, expiresIn: exp);
    }
    // fallback: nada reconhecido
    return const MfaChallenge();
  }
}
