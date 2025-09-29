import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/core/validation/validators.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/features/auth/data/ui/mfa_page.dart';
import 'package:handscore/core/theme/app_colors.dart';

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

  bool _submitted = false;
  final Map<String, bool> _touched = {'email': false, 'password': false};

  void _markTouched(String key) {
    if (!_touched[key]!) setState(() => _touched[key] = true);
  }

  bool _shouldValidate(String key) => _submitted || _touched[key] == true;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text.trim(), password: _password.text);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.flow == AuthFlow.loading;

    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.flow == AuthFlow.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
      if (next.flow == AuthFlow.mfaNeeded) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MfaPage()));
      }
      if (next.flow == AuthFlow.authenticated) {
        if (mounted) Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    onTap: () => _markTouched('email'),
                    onChanged: (_) => _markTouched('email'),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: state.fieldErrors['email']?.first,
                    ),
                    validator: (v) {
                      if (!_shouldValidate('email')) return null;
                      return Validators.email(v);
                    },
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username,
                    ],
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    onTap: () => _markTouched('password'),
                    onChanged: (_) => _markTouched('password'),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      errorText: state.fieldErrors['password']?.first,
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (v) {
                      if (!_shouldValidate('password')) return null;
                      return Validators.minLen(v, 6);
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkButtonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: Text(isLoading ? 'Entrando...' : 'Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
