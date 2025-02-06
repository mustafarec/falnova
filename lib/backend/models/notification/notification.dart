import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'body')
  final String body;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'is_sent')
  final bool isSent;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'data')
  final Map<String, dynamic>? data;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.isSent = false,
    required this.createdAt,
    required this.userId,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    bool? isSent,
    DateTime? createdAt,
    String? userId,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      data: data ?? this.data,
    );
  }
}
