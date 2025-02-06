import 'package:json_annotation/json_annotation.dart';

part 'notification_settings.g.dart';

const defaultCoffeeTimes = ['09:00', '14:00', '17:00'];
const defaultHoroscopeTimes = ['08:00'];

List<String> _timeListFromJson(dynamic times) {
  if (times == null) return defaultCoffeeTimes;

  if (times is List) {
    final validTimes = times
        .expand((time) {
          String cleanTime =
              time.toString().replaceAll(RegExp(r'[\[\]"\\]'), '').trim();

          if (cleanTime.contains(',')) {
            return cleanTime.split(',').map((t) => t.trim());
          }
          return [cleanTime];
        })
        .where((time) =>
            time.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(time))
        .toList();

    return validTimes.isEmpty ? defaultCoffeeTimes : validTimes;
  }

  if (times is String) {
    String cleanTime = times.replaceAll(RegExp(r'[\[\]"\\]'), '').trim();

    if (cleanTime.contains(',')) {
      return cleanTime
          .split(',')
          .map((t) => t.trim())
          .where((time) =>
              time.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(time))
          .toList();
    }

    if (cleanTime.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(cleanTime)) {
      return [cleanTime];
    }
  }

  return defaultCoffeeTimes;
}

List<String> _timeListToJson(List<String> times) {
  return times
      .where(
          (time) => time.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(time))
      .map((time) => time.trim())
      .toList();
}

@JsonSerializable()
class NotificationSettings {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'coffee_reminder_enabled')
  final bool coffeeReminderEnabled;

  @JsonKey(name: 'horoscope_reminder_enabled')
  final bool horoscopeReminderEnabled;

  @JsonKey(
    name: 'coffee_reminder_time',
    fromJson: _timeListFromJson,
    toJson: _timeListToJson,
  )
  final List<String> coffeeReminderTime;

  @JsonKey(
    name: 'horoscope_reminder_time',
    fromJson: _timeListFromJson,
    toJson: _timeListToJson,
  )
  final List<String> horoscopeReminderTime;

  @JsonKey(name: 'fortune_notifications')
  final bool fortuneNotifications;

  @JsonKey(name: 'horoscope_notifications')
  final bool horoscopeNotifications;

  @JsonKey(name: 'tarot_notifications')
  final bool tarotNotifications;

  @JsonKey(name: 'is_sent')
  final bool isSent;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const NotificationSettings({
    required this.id,
    required this.userId,
    this.coffeeReminderEnabled = true,
    this.horoscopeReminderEnabled = true,
    this.coffeeReminderTime = const ['09:00'],
    this.horoscopeReminderTime = const ['09:00'],
    this.fortuneNotifications = true,
    this.horoscopeNotifications = true,
    this.tarotNotifications = true,
    this.isSent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  static NotificationSettings getDefaultSettings(String userId) {
    return NotificationSettings(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      coffeeReminderEnabled: true,
      horoscopeReminderEnabled: true,
      coffeeReminderTime: defaultCoffeeTimes,
      horoscopeReminderTime: defaultHoroscopeTimes,
      fortuneNotifications: true,
      horoscopeNotifications: true,
      tarotNotifications: true,
      isSent: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? coffeeReminderEnabled,
    bool? horoscopeReminderEnabled,
    List<String>? coffeeReminderTime,
    List<String>? horoscopeReminderTime,
    bool? fortuneNotifications,
    bool? horoscopeNotifications,
    bool? tarotNotifications,
    bool? isSent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      coffeeReminderEnabled:
          coffeeReminderEnabled ?? this.coffeeReminderEnabled,
      horoscopeReminderEnabled:
          horoscopeReminderEnabled ?? this.horoscopeReminderEnabled,
      coffeeReminderTime: coffeeReminderTime ?? this.coffeeReminderTime,
      horoscopeReminderTime:
          horoscopeReminderTime ?? this.horoscopeReminderTime,
      fortuneNotifications: fortuneNotifications ?? this.fortuneNotifications,
      horoscopeNotifications:
          horoscopeNotifications ?? this.horoscopeNotifications,
      tarotNotifications: tarotNotifications ?? this.tarotNotifications,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
