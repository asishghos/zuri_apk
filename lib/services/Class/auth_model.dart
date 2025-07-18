class UserProfileResponse {
  final UserData data;
  final int closetStats;
  final List<NewAddition> newAdditions;
  final String msg;

  UserProfileResponse({
    required this.data,
    required this.closetStats,
    required this.newAdditions,
    required this.msg,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      data: UserData.fromJson(json['data']),
      closetStats: json['closetStats'],
      newAdditions: (json['newAdditions'] as List)
          .map((e) => NewAddition.fromJson(e))
          .toList(),
      msg: json['msg'],
    );
  }
}

class UserData {
  final String id;
  final String email;
  final String fullName;
  final String password;
  final String profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final UserBodyInfo userBodyInfo;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.userBodyInfo,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'],
      email: json['email'],
      fullName: json['fullName'],
      password: json['password'],
      profilePicture: json['profilePicture'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      userBodyInfo: UserBodyInfo.fromJson(json['userBodyInfo']),
    );
  }
}

class UserBodyInfo {
  final String bodyShape;
  final String undertone;
  final Height? height;

  UserBodyInfo({required this.bodyShape, required this.undertone, this.height});

  factory UserBodyInfo.fromJson(Map<String, dynamic> json) {
    return UserBodyInfo(
      bodyShape: json['bodyShape'],
      undertone: json['undertone'],
      height: json['height'] != null ? Height.fromJson(json['height']) : null,
    );
  }
}

class Height {
  final int feet;
  final int inches;

  Height({required this.feet, required this.inches});

  factory Height.fromJson(Map<String, dynamic> json) {
    return Height(feet: json['feet'], inches: json['inches']);
  }
}

class NewAddition {
  final String imageUrl;
  NewAddition({required this.imageUrl});
  factory NewAddition.fromJson(Map<String, dynamic> json) {
    return NewAddition(imageUrl: json['imageUrl']);
  }
}
