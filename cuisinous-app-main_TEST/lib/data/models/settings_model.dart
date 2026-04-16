class Settings {
  final String id;
  final int? theme;
  final String languageCode;
  final String currency;
  final bool isWelcomed;
  final bool isGoogleAuthUser;
  final bool hasCompletedRegister;

  Settings({
    required this.id,
    this.theme,
    required this.languageCode,
    required this.currency,
    required this.isWelcomed,
    required this.isGoogleAuthUser,
    required this.hasCompletedRegister,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as String,
      theme: map['theme'] as int?,
      languageCode: map['language_code'] as String,
      currency: map['currency'] as String,
      isWelcomed: (map['is_welcomed'] as int) == 1,
      isGoogleAuthUser: (map['isGoogleAuthUser'] as int) == 1,
      hasCompletedRegister: (map['hasCompletedRegister'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': theme,
      'language_code': languageCode,
      'currency': currency,
      'is_welcomed': isWelcomed,
      'isGoogleAuthUser': isGoogleAuthUser,
      'hasCompletedRegister': hasCompletedRegister,
    };
  }

  Settings copyWith({
    String? id,
    String? userId,
    String? userType,
    int? theme,
    String? languageCode,
    String? currency,
    bool? isWelcomed,
    bool? isGoogleAuthUser,
    bool? hasCompletedRegister,
  }) {
    return Settings(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      currency: currency ?? this.currency,
      isWelcomed: isWelcomed ?? this.isWelcomed,
      isGoogleAuthUser: isGoogleAuthUser ?? this.isGoogleAuthUser,
      hasCompletedRegister: hasCompletedRegister ?? this.hasCompletedRegister,
    );
  }
}
