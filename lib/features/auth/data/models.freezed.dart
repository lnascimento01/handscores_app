// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  @JsonKey(name: 'access_token')
  String? get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String? get refreshToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_in')
  int? get expiresIn => throw _privateConstructorUsedError;
  @JsonKey(name: 'mfa_required')
  bool get mfaRequired => throw _privateConstructorUsedError;
  @JsonKey(name: 'mfa_channels')
  List<String> get mfaChannels => throw _privateConstructorUsedError; // 👇 ADICIONE ESTA LINHA
  @JsonKey(name: 'challenge_id')
  int? get challengeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'trusted_device_challenge')
  bool get trustedDeviceChallenge => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
    LoginResponse value,
    $Res Function(LoginResponse) then,
  ) = _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'mfa_required') bool mfaRequired,
    @JsonKey(name: 'mfa_channels') List<String> mfaChannels,
    @JsonKey(name: 'challenge_id') int? challengeId,
    @JsonKey(name: 'trusted_device_challenge') bool trustedDeviceChallenge,
  });
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? expiresIn = freezed,
    Object? mfaRequired = null,
    Object? mfaChannels = null,
    Object? challengeId = freezed,
    Object? trustedDeviceChallenge = null,
  }) {
    return _then(
      _value.copyWith(
            accessToken: freezed == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            refreshToken: freezed == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresIn: freezed == expiresIn
                ? _value.expiresIn
                : expiresIn // ignore: cast_nullable_to_non_nullable
                      as int?,
            mfaRequired: null == mfaRequired
                ? _value.mfaRequired
                : mfaRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            mfaChannels: null == mfaChannels
                ? _value.mfaChannels
                : mfaChannels // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            challengeId: freezed == challengeId
                ? _value.challengeId
                : challengeId // ignore: cast_nullable_to_non_nullable
                      as int?,
            trustedDeviceChallenge: null == trustedDeviceChallenge
                ? _value.trustedDeviceChallenge
                : trustedDeviceChallenge // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
    _$LoginResponseImpl value,
    $Res Function(_$LoginResponseImpl) then,
  ) = __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'mfa_required') bool mfaRequired,
    @JsonKey(name: 'mfa_channels') List<String> mfaChannels,
    @JsonKey(name: 'challenge_id') int? challengeId,
    @JsonKey(name: 'trusted_device_challenge') bool trustedDeviceChallenge,
  });
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
    _$LoginResponseImpl _value,
    $Res Function(_$LoginResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? expiresIn = freezed,
    Object? mfaRequired = null,
    Object? mfaChannels = null,
    Object? challengeId = freezed,
    Object? trustedDeviceChallenge = null,
  }) {
    return _then(
      _$LoginResponseImpl(
        accessToken: freezed == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        refreshToken: freezed == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresIn: freezed == expiresIn
            ? _value.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
        mfaRequired: null == mfaRequired
            ? _value.mfaRequired
            : mfaRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        mfaChannels: null == mfaChannels
            ? _value._mfaChannels
            : mfaChannels // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        challengeId: freezed == challengeId
            ? _value.challengeId
            : challengeId // ignore: cast_nullable_to_non_nullable
                  as int?,
        trustedDeviceChallenge: null == trustedDeviceChallenge
            ? _value.trustedDeviceChallenge
            : trustedDeviceChallenge // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl({
    @JsonKey(name: 'access_token') this.accessToken,
    @JsonKey(name: 'refresh_token') this.refreshToken,
    @JsonKey(name: 'expires_in') this.expiresIn,
    @JsonKey(name: 'mfa_required') this.mfaRequired = false,
    @JsonKey(name: 'mfa_channels')
    final List<String> mfaChannels = const <String>[],
    @JsonKey(name: 'challenge_id') this.challengeId,
    @JsonKey(name: 'trusted_device_challenge')
    this.trustedDeviceChallenge = false,
  }) : _mfaChannels = mfaChannels;

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @override
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @override
  @JsonKey(name: 'mfa_required')
  final bool mfaRequired;
  final List<String> _mfaChannels;
  @override
  @JsonKey(name: 'mfa_channels')
  List<String> get mfaChannels {
    if (_mfaChannels is EqualUnmodifiableListView) return _mfaChannels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mfaChannels);
  }

  // 👇 ADICIONE ESTA LINHA
  @override
  @JsonKey(name: 'challenge_id')
  final int? challengeId;
  @override
  @JsonKey(name: 'trusted_device_challenge')
  final bool trustedDeviceChallenge;

  @override
  String toString() {
    return 'LoginResponse(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, mfaRequired: $mfaRequired, mfaChannels: $mfaChannels, challengeId: $challengeId, trustedDeviceChallenge: $trustedDeviceChallenge)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.mfaRequired, mfaRequired) ||
                other.mfaRequired == mfaRequired) &&
            const DeepCollectionEquality().equals(
              other._mfaChannels,
              _mfaChannels,
            ) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.trustedDeviceChallenge, trustedDeviceChallenge) ||
                other.trustedDeviceChallenge == trustedDeviceChallenge));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    expiresIn,
    mfaRequired,
    const DeepCollectionEquality().hash(_mfaChannels),
    challengeId,
    trustedDeviceChallenge,
  );

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(this);
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse({
    @JsonKey(name: 'access_token') final String? accessToken,
    @JsonKey(name: 'refresh_token') final String? refreshToken,
    @JsonKey(name: 'expires_in') final int? expiresIn,
    @JsonKey(name: 'mfa_required') final bool mfaRequired,
    @JsonKey(name: 'mfa_channels') final List<String> mfaChannels,
    @JsonKey(name: 'challenge_id') final int? challengeId,
    @JsonKey(name: 'trusted_device_challenge')
    final bool trustedDeviceChallenge,
  }) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String? get accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  String? get refreshToken;
  @override
  @JsonKey(name: 'expires_in')
  int? get expiresIn;
  @override
  @JsonKey(name: 'mfa_required')
  bool get mfaRequired;
  @override
  @JsonKey(name: 'mfa_channels')
  List<String> get mfaChannels; // 👇 ADICIONE ESTA LINHA
  @override
  @JsonKey(name: 'challenge_id')
  int? get challengeId;
  @override
  @JsonKey(name: 'trusted_device_challenge')
  bool get trustedDeviceChallenge;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) {
  return _RegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequest {
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'password_confirmation')
  String get passwordConfirmation => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(
    RegisterRequest value,
    $Res Function(RegisterRequest) then,
  ) = _$RegisterRequestCopyWithImpl<$Res, RegisterRequest>;
  @useResult
  $Res call({
    String name,
    String email,
    String password,
    @JsonKey(name: 'password_confirmation') String passwordConfirmation,
  });
}

/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res, $Val extends RegisterRequest>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? passwordConfirmation = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            passwordConfirmation: null == passwordConfirmation
                ? _value.passwordConfirmation
                : passwordConfirmation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterRequestImplCopyWith<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  factory _$$RegisterRequestImplCopyWith(
    _$RegisterRequestImpl value,
    $Res Function(_$RegisterRequestImpl) then,
  ) = __$$RegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String email,
    String password,
    @JsonKey(name: 'password_confirmation') String passwordConfirmation,
  });
}

/// @nodoc
class __$$RegisterRequestImplCopyWithImpl<$Res>
    extends _$RegisterRequestCopyWithImpl<$Res, _$RegisterRequestImpl>
    implements _$$RegisterRequestImplCopyWith<$Res> {
  __$$RegisterRequestImplCopyWithImpl(
    _$RegisterRequestImpl _value,
    $Res Function(_$RegisterRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? passwordConfirmation = null,
  }) {
    return _then(
      _$RegisterRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        passwordConfirmation: null == passwordConfirmation
            ? _value.passwordConfirmation
            : passwordConfirmation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestImpl implements _RegisterRequest {
  const _$RegisterRequestImpl({
    required this.name,
    required this.email,
    required this.password,
    @JsonKey(name: 'password_confirmation') required this.passwordConfirmation,
  });

  factory _$RegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String email;
  @override
  final String password;
  @override
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  @override
  String toString() {
    return 'RegisterRequest(name: $name, email: $email, password: $password, passwordConfirmation: $passwordConfirmation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.passwordConfirmation, passwordConfirmation) ||
                other.passwordConfirmation == passwordConfirmation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, password, passwordConfirmation);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      __$$RegisterRequestImplCopyWithImpl<_$RegisterRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestImplToJson(this);
  }
}

abstract class _RegisterRequest implements RegisterRequest {
  const factory _RegisterRequest({
    required final String name,
    required final String email,
    required final String password,
    @JsonKey(name: 'password_confirmation')
    required final String passwordConfirmation,
  }) = _$RegisterRequestImpl;

  factory _RegisterRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get email;
  @override
  String get password;
  @override
  @JsonKey(name: 'password_confirmation')
  String get passwordConfirmation;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
