// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthToken _$AuthTokenFromJson(Map<String, dynamic> json) {
  return _AuthToken.fromJson(json);
}

/// @nodoc
mixin _$AuthToken {
  @JsonKey(name: 'token')
  String get accessToken => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this AuthToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthTokenCopyWith<AuthToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthTokenCopyWith<$Res> {
  factory $AuthTokenCopyWith(AuthToken value, $Res Function(AuthToken) then) =
      _$AuthTokenCopyWithImpl<$Res, AuthToken>;
  @useResult
  $Res call(
      {@JsonKey(name: 'token') String accessToken,
      String expiresAt,
      String type});
}

/// @nodoc
class _$AuthTokenCopyWithImpl<$Res, $Val extends AuthToken>
    implements $AuthTokenCopyWith<$Res> {
  _$AuthTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? expiresAt = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthTokenImplCopyWith<$Res>
    implements $AuthTokenCopyWith<$Res> {
  factory _$$AuthTokenImplCopyWith(
          _$AuthTokenImpl value, $Res Function(_$AuthTokenImpl) then) =
      __$$AuthTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'token') String accessToken,
      String expiresAt,
      String type});
}

/// @nodoc
class __$$AuthTokenImplCopyWithImpl<$Res>
    extends _$AuthTokenCopyWithImpl<$Res, _$AuthTokenImpl>
    implements _$$AuthTokenImplCopyWith<$Res> {
  __$$AuthTokenImplCopyWithImpl(
      _$AuthTokenImpl _value, $Res Function(_$AuthTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? expiresAt = null,
    Object? type = null,
  }) {
    return _then(_$AuthTokenImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthTokenImpl implements _AuthToken {
  const _$AuthTokenImpl(
      {@JsonKey(name: 'token') required this.accessToken,
      required this.expiresAt,
      required this.type});

  factory _$AuthTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthTokenImplFromJson(json);

  @override
  @JsonKey(name: 'token')
  final String accessToken;
  @override
  final String expiresAt;
  @override
  final String type;

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, expiresAt: $expiresAt, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthTokenImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, expiresAt, type);

  /// Create a copy of AuthToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthTokenImplCopyWith<_$AuthTokenImpl> get copyWith =>
      __$$AuthTokenImplCopyWithImpl<_$AuthTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthTokenImplToJson(
      this,
    );
  }
}

abstract class _AuthToken implements AuthToken {
  const factory _AuthToken(
      {@JsonKey(name: 'token') required final String accessToken,
      required final String expiresAt,
      required final String type}) = _$AuthTokenImpl;

  factory _AuthToken.fromJson(Map<String, dynamic> json) =
      _$AuthTokenImpl.fromJson;

  @override
  @JsonKey(name: 'token')
  String get accessToken;
  @override
  String get expiresAt;
  @override
  String get type;

  /// Create a copy of AuthToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthTokenImplCopyWith<_$AuthTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
