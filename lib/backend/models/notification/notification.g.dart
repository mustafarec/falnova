// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isSent: json['is_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'is_read': instance.isRead,
      'is_sent': instance.isSent,
      'created_at': instance.createdAt.toIso8601String(),
      'user_id': instance.userId,
      'data': instance.data,
    };
