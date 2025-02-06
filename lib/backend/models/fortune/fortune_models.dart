/// Kahve falı durumları
enum FortuneStatus {
  pending('Bekliyor'),
  processing('İşleniyor'),
  completed('Tamamlandı'),
  failed('Başarısız');

  final String label;
  const FortuneStatus(this.label);
}

/// Kahve falı modeli
class FortuneReading {
  final String id;
  final String? imageUrl;
  final String interpretation;
  final DateTime createdAt;
  final bool isPremium;
  final String userId;
  final FortuneStatus status;

  const FortuneReading({
    required this.id,
    this.imageUrl,
    required this.interpretation,
    required this.createdAt,
    this.isPremium = false,
    required this.userId,
    this.status = FortuneStatus.pending,
  });

  /// JSON'dan FortuneReading oluştur
  factory FortuneReading.fromJson(Map<String, dynamic> json) {
    return FortuneReading(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String?,
      interpretation: json['interpretation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPremium: json['is_premium'] as bool? ?? false,
      userId: json['user_id'] as String,
      status: FortuneStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => FortuneStatus.pending,
      ),
    );
  }

  /// FortuneReading'i JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'interpretation': interpretation,
      'created_at': createdAt.toIso8601String(),
      'is_premium': isPremium,
      'user_id': userId,
      'status': status.name,
    };
  }

  /// Yeni değerlerle FortuneReading kopyası oluştur
  FortuneReading copyWith({
    String? id,
    String? imageUrl,
    String? interpretation,
    DateTime? createdAt,
    bool? isPremium,
    String? userId,
    FortuneStatus? status,
  }) {
    return FortuneReading(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      interpretation: interpretation ?? this.interpretation,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

/// Kullanıcı fal istatistikleri
class FortuneStats {
  final String userId;
  final int totalReadings;
  final int premiumReadings;
  final DateTime? lastReadingAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FortuneStats({
    required this.userId,
    this.totalReadings = 0,
    this.premiumReadings = 0,
    this.lastReadingAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan FortuneStats oluştur
  factory FortuneStats.fromJson(Map<String, dynamic> json) {
    return FortuneStats(
      userId: json['user_id'] as String,
      totalReadings: json['total_readings'] as int? ?? 0,
      premiumReadings: json['premium_readings'] as int? ?? 0,
      lastReadingAt: json['last_reading_at'] != null
          ? DateTime.parse(json['last_reading_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// FortuneStats'i JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_readings': totalReadings,
      'premium_readings': premiumReadings,
      'last_reading_at': lastReadingAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Yeni değerlerle FortuneStats kopyası oluştur
  FortuneStats copyWith({
    String? userId,
    int? totalReadings,
    int? premiumReadings,
    DateTime? lastReadingAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FortuneStats(
      userId: userId ?? this.userId,
      totalReadings: totalReadings ?? this.totalReadings,
      premiumReadings: premiumReadings ?? this.premiumReadings,
      lastReadingAt: lastReadingAt ?? this.lastReadingAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
