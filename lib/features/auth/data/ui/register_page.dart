import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/core/validation/validators.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/core/theme/app_colors.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // Em caso de erro, mostramos snackbar (além dos errorText inline). Não navegamos em erro.
    ref.listen(authControllerProvider, (prev, next) {
      if (next.flow == AuthFlow.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  errorText: state.fieldErrors['name']?.first, // 422 inline
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
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
                ),
                obscureText: true,
                validator: (v) => Validators.minLen(v, 6),
                autofillHints: const [AutofillHints.newPassword],
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
                                .register(
                                  name: _name.text.trim(),
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );

                            // ✅ Só fecha a tela se NÃO houve erro
                            final after = ref.read(authControllerProvider);
                            if (after.flow != AuthFlow.error && mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child: Text(
                    state.flow == AuthFlow.loading
                        ? 'Enviando...'
                        : 'Registrar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
