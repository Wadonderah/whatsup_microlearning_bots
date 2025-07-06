// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => AuthResult(
      user: json['user'] == null
          ? null
          : AppUser.fromJson(json['user'] as Map<String, dynamic>),
      error: json['error'] as String?,
      isSuccess: json['isSuccess'] as bool,
      type: $enumDecode(_$AuthResultTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$AuthResultToJson(AuthResult instance) =>
    <String, dynamic>{
      'user': instance.user,
      'error': instance.error,
      'isSuccess': instance.isSuccess,
      'type': _$AuthResultTypeEnumMap[instance.type]!,
    };

const _$AuthResultTypeEnumMap = {
  AuthResultType.signIn: 'sign_in',
  AuthResultType.signUp: 'sign_up',
  AuthResultType.signOut: 'sign_out',
  AuthResultType.passwordReset: 'password_reset',
  AuthResultType.emailVerification: 'email_verification',
};
