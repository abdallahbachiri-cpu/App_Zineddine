class NotificationModel {
  String? id;
  String? title;
  String? body;
  String? titleFr;
  String? bodyFr;
  String? senderId;
  String? orderId;
  Sender? sender;
  bool? isShow;
  String? createdAt;

  NotificationModel(
      {this.id,
      this.title,
      this.body,
      this.titleFr,
      this.bodyFr,
      this.senderId,
      this.orderId,
      this.sender,
      this.isShow,
      this.createdAt});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    titleFr = json['titleFr'];
    bodyFr = json['bodyFr'];
    senderId = json['senderId'];
    orderId = json['orderId'];
    sender =
        json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    isShow = json['isShow'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['titleFr'] = this.titleFr;
    data['bodyFr'] = this.bodyFr;
    data['senderId'] = this.senderId;
    data['orderId'] = this.orderId;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    data['isShow'] = this.isShow;
    data['createdAt'] = this.createdAt;
    return data;
  }

  String getLocalizedTitle(String languageCode) {
    if (languageCode == 'fr') {
      return titleFr ?? title ?? '';
    }
    return title ?? '';
  }

  String getLocalizedBody(String languageCode) {
    if (languageCode == 'fr') {
      return bodyFr ?? body ?? '';
    }
    return body ?? '';
  }
}

class Sender {
  String? id;
  String? firstName;
  String? lastName;
  String? email;

  Sender({this.id, this.firstName, this.lastName, this.email});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    return data;
  }
}