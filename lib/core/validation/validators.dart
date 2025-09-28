// lib/core/validation/validators.dart
class Validators {
  // Regex simples e eficiente p/ formato de e-mail comum (não 100% RFC, mas suficiente p/ app)
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? required(String? v, {String msg = 'Campo obrigatório'}) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  static String? email(String? v, {String msg = 'E-mail inválido'}) {
    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
    if (!_email.hasMatch(v.trim())) return msg;
    return null;
  }

  static String? minLen(String? v, int n, {String? msg}) {
    if (v == null || v.length < n) return msg ?? 'Mínimo $n caracteres';
    return null;
  }
}
