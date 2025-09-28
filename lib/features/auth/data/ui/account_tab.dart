import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/features/auth/data/ui/login_page.dart';
import 'package:handscore/features/auth/data/ui/register_page.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final cs = Theme.of(context).colorScheme;

    if (auth.flow == AuthFlow.authenticated) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40, color: cs.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Você está autenticado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.devices_other),
              title: const Text('Dispositivo confiável'),
              subtitle: const Text('Gerencie este dispositivo'),
              onTap: () {
                // futuro: tela de trusted devices
              },
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ),
        ],
      );
    }

    // Não autenticado
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 16),
              Text(
                'Faça login para personalizar sua experiência',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.flow == AuthFlow.loading
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                  child: Text(
                    auth.flow == AuthFlow.loading ? 'Carregando...' : 'Entrar',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text('Criar conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
