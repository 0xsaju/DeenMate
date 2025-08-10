// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesImplAdapter extends TypeAdapter<_$UserPreferencesImpl> {
  @override
  final int typeId = 1;

  @override
  _$UserPreferencesImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$UserPreferencesImpl(
      language: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      city: fields[3] as String,
      country: fields[4] as String,
      timezone: fields[5] as String,
      calculationMethodId: fields[6] as String,
      madhhab: fields[7] as String,
      notificationsEnabled: fields[8] as bool,
      enabledPrayers: (fields[9] as List).cast<String>(),
      theme: fields[10] as String,
      onboardingCompleted: fields[11] as bool,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
      userName: fields[14] as String?,
      customCalculationParams: (fields[15] as Map?)?.cast<String, dynamic>(),
      locationPermissionGranted: fields[16] as bool?,
      notificationSound: fields[17] as String?,
      vibrationEnabled: fields[18] as bool?,
      notificationAdvanceMinutes: fields[19] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, _$UserPreferencesImpl obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.timezone)
      ..writeByte(6)
      ..write(obj.calculationMethodId)
      ..writeByte(7)
      ..write(obj.madhhab)
      ..writeByte(8)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.theme)
      ..writeByte(11)
      ..write(obj.onboardingCompleted)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.userName)
      ..writeByte(16)
      ..write(obj.locationPermissionGranted)
      ..writeByte(17)
      ..write(obj.notificationSound)
      ..writeByte(18)
      ..write(obj.vibrationEnabled)
      ..writeByte(19)
      ..write(obj.notificationAdvanceMinutes)
      ..writeByte(9)
      ..write(obj.enabledPrayers)
      ..writeByte(15)
      ..write(obj.customCalculationParams);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      language: json['language'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      country: json['country'] as String,
      timezone: json['timezone'] as String,
      calculationMethodId: json['calculationMethodId'] as String,
      madhhab: json['madhhab'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      enabledPrayers: (json['enabledPrayers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      theme: json['theme'] as String,
      onboardingCompleted: json['onboardingCompleted'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userName: json['userName'] as String?,
      customCalculationParams:
          json['customCalculationParams'] as Map<String, dynamic>?,
      locationPermissionGranted: json['locationPermissionGranted'] as bool?,
      notificationSound: json['notificationSound'] as String?,
      vibrationEnabled: json['vibrationEnabled'] as bool?,
      notificationAdvanceMinutes:
          (json['notificationAdvanceMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'language': instance.language,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
      'calculationMethodId': instance.calculationMethodId,
      'madhhab': instance.madhhab,
      'notificationsEnabled': instance.notificationsEnabled,
      'enabledPrayers': instance.enabledPrayers,
      'theme': instance.theme,
      'onboardingCompleted': instance.onboardingCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userName': instance.userName,
      'customCalculationParams': instance.customCalculationParams,
      'locationPermissionGranted': instance.locationPermissionGranted,
      'notificationSound': instance.notificationSound,
      'vibrationEnabled': instance.vibrationEnabled,
      'notificationAdvanceMinutes': instance.notificationAdvanceMinutes,
    };
