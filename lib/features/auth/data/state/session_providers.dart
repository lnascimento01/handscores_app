import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/models.dart';
import 'package:handscore/features/auth/data/auth_repository.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/core/secure/secure_store.dart';

enum SessionFlow { booting, unauthenticated, authenticated }

class SessionState {
  final SessionFlow flow;
  final UserDto? user;

  const SessionState._(this.flow, this.user);

  const SessionState.booting() : this._(SessionFlow.booting, null);
  const SessionState.unauthenticated()
    : this._(SessionFlow.unauthenticated, null);
  const SessionState.authenticated(UserDto u)
    : this._(SessionFlow.authenticated, u);
}

class SessionController extends StateNotifier<SessionState> {
  final AuthRepository repo;
  final Ref ref;
  SessionController(this.ref, this.repo) : super(const SessionState.booting());

  /// Chamado no start do app
  Future<void> bootstrap() async {
    try {
      final at = await SecureStore.read(SecureStore.kAccessToken);
      if (at == null || at.isEmpty) {
        state = const SessionState.unauthenticated();
        return;
      }
      final me = await repo.getCurrentUser();
      state = SessionState.authenticated(me);
    } catch (_) {
      await _purgeTokens();
      state = const SessionState.unauthenticated();
    }
  }

  /// Revalida “por tela”. Se falhar, derruba sessão.
  Future<bool> revalidate() async {
    try {
      final me = await repo.getCurrentUser();
      state = SessionState.authenticated(me);
      return true;
    } catch (_) {
      await _purgeTokens();
      state = const SessionState.unauthenticated();
      return false;
    }
  }

  /// Chame isso após login com sucesso
  Future<void> loadUser() async {
    try {
      final me = await repo.getCurrentUser();
      state = SessionState.authenticated(me);
    } catch (_) {
      state = const SessionState.unauthenticated();
    }
  }

  Future<void> signOutEverywhere() async {
    try {
      await repo.logout();
    } catch (_) {}
    await _purgeTokens();
    state = const SessionState.unauthenticated();
  }

  Future<void> _purgeTokens() async {
    await SecureStore.delete(SecureStore.kAccessToken);
    await SecureStore.delete(SecureStore.kRefreshToken);
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      final repo = ref.read(authRepoProvider);
      return SessionController(ref, repo);
    });
