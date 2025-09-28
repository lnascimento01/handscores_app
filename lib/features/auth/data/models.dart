import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,

    @JsonKey(name: 'mfa_required') @Default(false) bool mfaRequired,
    @JsonKey(name: 'mfa_channels')
    @Default(<String>[])
    List<String> mfaChannels,

    // 👇 ADICIONE ESTA LINHA
    @JsonKey(name: 'challenge_id') int? challengeId,

    @JsonKey(name: 'trusted_device_challenge')
    @Default(false)
    bool trustedDeviceChallenge,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String name,
    required String email,
    required String password,
    @JsonKey(name: 'password_confirmation')
    required String passwordConfirmation,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
