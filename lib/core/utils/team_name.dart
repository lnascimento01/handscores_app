String shortTeam(String name) {
  final t = name.trim();
  if (t.isEmpty) return t;
  // separa por espaço ou hífen — pega o primeiro token
  final parts = t.split(RegExp(r'[\s\-]+'));
  return parts.first;
}
