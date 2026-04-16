class User {
  final String id;
  final String? oAuthAccessToken;
  final String? oAuthId;
  final String email;
  final bool isEmailConfirmed;
  final bool needsGoogleOnboarding;
  final bool isRegisteredFromGoogle;
  final String? type;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phoneNumber;
  final bool isActive;
  final String? profileImageUrl;

  User({
    required this.id,
    this.oAuthAccessToken,
    this.oAuthId,
    required this.email,
    required this.isEmailConfirmed,
    this.type,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phoneNumber,
    required this.isActive,
    this.profileImageUrl,
    required this.needsGoogleOnboarding,
    required this.isRegisteredFromGoogle,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      oAuthAccessToken: map['oAuthAccessToken'] as String?,
      oAuthId: map['oAuthId'] as String?,
      email: map['email'] as String,
      isEmailConfirmed: map['isEmailConfirmed'] as bool,
      type: map['type'] as String?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      middleName: map['middleName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      isActive: (map['isActive'] as int) == 1,
      profileImageUrl: map['profileImageUrl'] as String?,
      needsGoogleOnboarding: map['needsGoogleOnboarding'] as bool,
      isRegisteredFromGoogle: map['isRegisteredFromGoogle'] as bool,
    );
  }
  factory User.fromRemoteMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      isEmailConfirmed: map['isEmailConfirmed'] as bool,
      type: map['type'] as String?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      middleName: map['middleName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      isActive: map['isActive'],
      needsGoogleOnboarding: map['needsGoogleOnboarding'] as bool,
      profileImageUrl: map['profileImageUrl'] as String?,
      isRegisteredFromGoogle: map['isRegisteredFromGoogle'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'oAuthAccessToken': oAuthAccessToken,
      'oAuthId': oAuthId,
      'email': email,
      'isEmailConfirmed': isEmailConfirmed,
      'type': type,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'phoneNumber': phoneNumber,
      'isActive': isActive ? 1 : 0,
      'profileImageUrl': profileImageUrl,
      'needsGoogleOnboarding': needsGoogleOnboarding,
    };
  }

  User copyWith({
    String? id,
    String? oAuthAccessToken,
    String? oAuthId,
    String? email,
    bool? isEmailConfirmed,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    bool? isActive,
    String? profileImageUrl,
    String? type,
    bool? needsGoogleOnboarding,
    bool? isRegisteredFromGoogle,
  }) {
    return User(
      id: id ?? this.id,
      oAuthAccessToken: oAuthAccessToken ?? this.oAuthAccessToken,
      oAuthId: oAuthId ?? this.oAuthId,
      email: email ?? this.email,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      type: type ?? this.type,
      needsGoogleOnboarding:
          needsGoogleOnboarding ?? this.needsGoogleOnboarding,
      isRegisteredFromGoogle:
          isRegisteredFromGoogle ?? this.isRegisteredFromGoogle,
    );
  }
}
