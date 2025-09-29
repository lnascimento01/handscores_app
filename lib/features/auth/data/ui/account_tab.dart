import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/state/session_providers.dart';
import 'package:handscore/features/auth/data/ui/login_page.dart';
import 'package:handscore/features/auth/data/ui/register_page.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(sessionControllerProvider.notifier).revalidate();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final cs = Theme.of(context).colorScheme;

    // 1) Boot inicial da sessão (app acabou de abrir)
    if (session.flow == SessionFlow.booting) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // 2) Autenticado — mostra dados do usuário logado
    if (session.flow == SessionFlow.authenticated && session.user != null) {
      final u = session.user!;
      return RefreshIndicator.adaptive(
        onRefresh: () => _refresh(context, ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 40,
                foregroundImage:
                    (u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
                    ? NetworkImage(u.avatarUrl!)
                    : null,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                u.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                u.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (u.roles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: -6,
                  children: u.roles
                      .map(
                        (r) => Chip(
                          label: Text(r),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Minha conta'),
                subtitle: const Text('Dados pessoais e segurança'),
                onTap: () {
                  // TODO: navegar para detalhes/edição do perfil
                },
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.devices_other),
                title: const Text('Dispositivo confiável'),
                subtitle: const Text('Gerencie este dispositivo'),
                onTap: () {
                  // TODO: tela de trusted devices
                },
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  await ref
                      .read(sessionControllerProvider.notifier)
                      .signOutEverywhere();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sessão encerrada.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    // 3) Não autenticado — oferece Login/Registro
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
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: const Text('Entrar'),
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
