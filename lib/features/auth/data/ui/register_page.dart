import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/core/validation/validators.dart';
import 'package:handscore/core/theme/app_colors.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';
import 'package:handscore/features/auth/data/ui/mfa_page.dart';

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
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;

  // controle de validação
  bool _submitted = false;
  final Map<String, bool> _touched = {
    'name': false,
    'email': false,
    'password': false,
    'confirm': false,
  };

  void _markTouched(String key) {
    if (!_touched[key]!) {
      setState(() => _touched[key] = true);
    }
  }

  bool _shouldValidate(String key) => _submitted || _touched[key] == true;

  @override
  void initState() {
    super.initState();
    // listeners apenas para atualizar força da senha em tempo real (opcional)
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // força de senha simples (0..5)
  int _passwordScore(String v) {
    int s = 0;
    if (v.length >= 6) s++;
    if (RegExp(r'[A-Z]').hasMatch(v)) s++;
    if (RegExp(r'[a-z]').hasMatch(v)) s++;
    if (RegExp(r'\d').hasMatch(v)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=+;]').hasMatch(v)) s++;
    return s;
  }

  String _passwordHint(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Senha fraca';
      case 2:
      case 3:
        return 'Senha razoável';
      default:
        return 'Senha forte';
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirm.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.flow == AuthFlow.loading;

    // navegação reativa
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.flow == AuthFlow.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
      if (next.flow == AuthFlow.mfaNeeded) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MfaPage()));
      }
      if (next.flow == AuthFlow.authenticated && mounted) {
        Navigator.of(context).pop();
      }
    });

    final pwScore = _passwordScore(_password.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              autovalidateMode: AutovalidateMode.disabled, // controle manual
              child: Column(
                children: [
                  // Nome
                  TextFormField(
                    controller: _name,
                    onTap: () => _markTouched('name'),
                    onChanged: (_) => _markTouched('name'),
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      errorText: state.fieldErrors['name']?.first,
                    ),
                    validator: (v) {
                      if (!_shouldValidate('name')) return null;
                      return Validators.required(v);
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Email
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
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Senha
                  TextFormField(
                    controller: _password,
                    onTap: () => _markTouched('password'),
                    onChanged: (_) => _markTouched('password'),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      errorText: state.fieldErrors['password']?.first,
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed: isLoading ? null : () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (v) {
                      if (!_shouldValidate('password')) return null;
                      return Validators.minLen(v, 6);
                    },
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),

                  // Força da senha (opcional)
                  const SizedBox(height: 8),
                  if (_password.text.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (pwScore.clamp(0, 5)) / 5,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_passwordHint(pwScore), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Confirmar senha
                  TextFormField(
                    controller: _confirm,
                    onTap: () => _markTouched('confirm'),
                    onChanged: (_) => _markTouched('confirm'),
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      errorText: state.fieldErrors['password_confirmation']?.first,
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirm ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed:
                            isLoading ? null : () => setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    validator: (v) {
                      if (!_shouldValidate('confirm')) return null;
                      final err = Validators.minLen(v, 6);
                      if (err != null) return err;
                      if (v != _password.text) return 'As senhas não coincidem';
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 20),

                  // Botão Registrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkButtonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: Text(isLoading ? 'Enviando...' : 'Registrar'),
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
