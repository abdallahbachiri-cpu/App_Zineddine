import 'dart:convert';

class Media {
  final String id;
  final String url;
  final String fileType;

  Media({required this.id, required this.url, required this.fileType});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'url': url, 'fileType': fileType};
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      id: map['id'] as String,
      url: map['url'] as String,
      fileType: map['fileType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Media.fromJson(String source) =>
      Media.fromMap(json.decode(source) as Map<String, dynamic>);
}
