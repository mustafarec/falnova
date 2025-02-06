// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      coffeeReminderEnabled: json['coffee_reminder_enabled'] as bool? ?? true,
      horoscopeReminderEnabled:
          json['horoscope_reminder_enabled'] as bool? ?? true,
      coffeeReminderTime: json['coffee_reminder_time'] == null
          ? const ['09:00']
          : _timeListFromJson(json['coffee_reminder_time']),
      horoscopeReminderTime: json['horoscope_reminder_time'] == null
          ? const ['09:00']
          : _timeListFromJson(json['horoscope_reminder_time']),
      fortuneNotifications: json['fortune_notifications'] as bool? ?? true,
      horoscopeNotifications: json['horoscope_notifications'] as bool? ?? true,
      tarotNotifications: json['tarot_notifications'] as bool? ?? true,
      isSent: json['is_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'coffee_reminder_enabled': instance.coffeeReminderEnabled,
      'horoscope_reminder_enabled': instance.horoscopeReminderEnabled,
      'coffee_reminder_time': _timeListToJson(instance.coffeeReminderTime),
      'horoscope_reminder_time':
          _timeListToJson(instance.horoscopeReminderTime),
      'fortune_notifications': instance.fortuneNotifications,
      'horoscope_notifications': instance.horoscopeNotifications,
      'tarot_notifications': instance.tarotNotifications,
      'is_sent': instance.isSent,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
