import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/core/validation/validators.dart';
import 'package:handscore/core/theme/app_colors.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/features/auth/data/ui/mfa_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // Navega apenas em sucesso; exibe snackbar em erro (além dos errorText inline)
    ref.listen(authControllerProvider, (prev, next) {
      if (next.flow == AuthFlow.mfaNeeded) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MfaPage()));
      }
      if (next.flow == AuthFlow.authenticated) {
        // TODO: navegar para Home / fechar modal
      }
      if (next.flow == AuthFlow.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: state.fieldErrors['email']?.first, // 422 inline
                ),
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  errorText: state.fieldErrors['password']?.first, // 422 inline
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
              ),

              // erro geral opcional (além do snackbar)
              if (state.flow == AuthFlow.error && state.error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkButtonPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: state.flow == AuthFlow.loading
                      ? null
                      : () async {
                          if (_form.currentState!.validate()) {
                            await ref
                                .read(authControllerProvider.notifier)
                                .login(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                          }
                        },
                  child: Text(
                    state.flow == AuthFlow.loading ? 'Entrando...' : 'Entrar',
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: state.flow == AuthFlow.loading
                    ? null
                    : () => Navigator.of(context).pushNamed('/register'),
                child: const Text('Criar uma conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
