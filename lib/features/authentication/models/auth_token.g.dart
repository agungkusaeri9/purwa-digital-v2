// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthTokenImpl _$$AuthTokenImplFromJson(Map<String, dynamic> json) =>
    _$AuthTokenImpl(
      accessToken: json['token'] as String,
      expiresAt: json['expiresAt'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$AuthTokenImplToJson(_$AuthTokenImpl instance) =>
    <String, dynamic>{
      'token': instance.accessToken,
      'expiresAt': instance.expiresAt,
      'type': instance.type,
    };
