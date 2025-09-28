// lib/core/network/pinning.dart
import 'dart:convert';
import 'dart:io';

HttpClient createPinnedHttpClient(List<String> allowedSpkiSha256) {
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    // Compare o SPKI (Subject Public Key Info) SHA256 do cert com a lista permitida
    final spki = cert.der; // simplificado — para SPKI exato, extrair PublicKey DER.
    final sha256 = base64.encode(spki); // placeholder; ideal: calc SHA-256 do SPKI DER e base64.
    return allowedSpkiSha256.contains(sha256);
  };
  return client;
}
