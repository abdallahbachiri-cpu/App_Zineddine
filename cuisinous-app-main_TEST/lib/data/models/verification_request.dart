import 'dart:convert';

class VerificationRequest {
  final String id;
  final String foodStoreId;
  final String foodStoreName;
  final String status;
  final String? adminComment;
  final List<String> documentIds;
  final String? verifiedBy;
  final String? verifiedAt;

  VerificationRequest({
    required this.id,
    required this.foodStoreId,
    required this.foodStoreName,
    required this.status,
    this.adminComment,
    required this.documentIds,
    this.verifiedBy,
    this.verifiedAt,
  });

  VerificationRequest copyWith({
    String? id,
    String? foodStoreId,
    String? foodStoreName,
    String? status,
    String? adminComment,
    List<String>? documentIds,
    String? verifiedBy,
    String? verifiedAt,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      foodStoreId: foodStoreId ?? this.foodStoreId,
      foodStoreName: foodStoreName ?? this.foodStoreName,
      status: status ?? this.status,
      adminComment: adminComment ?? this.adminComment,
      documentIds: documentIds ?? this.documentIds,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'foodStoreId': foodStoreId,
      'foodStoreName': foodStoreName,
      'status': status,
      'adminComment': adminComment,
      'documentIds': documentIds,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt,
    };
  }

  factory VerificationRequest.fromMap(Map<String, dynamic> map) {
    return VerificationRequest(
      id: map['id'] as String,
      foodStoreId: map['foodStoreId'] as String,
      foodStoreName: map['foodStoreName'] as String,
      status: map['status'] as String,
      adminComment:
          map['adminComment'] != null ? map['adminComment'] as String : null,
      documentIds: List<String>.from(
        (map['documentIds'] as List<dynamic>).map<String>((x) => x as String),
      ),
      verifiedBy:
          map['verifiedByName'] != null
              ? map['verifiedByName'] as String
              : null,
      verifiedAt: map['updatedAt'] != null ? map['updatedAt'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerificationRequest.fromJson(String source) =>
      VerificationRequest.fromMap(json.decode(source) as Map<String, dynamic>);
}
