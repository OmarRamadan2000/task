import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.provider,
  });

  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser,
    String provider,
  ) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      provider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      provider: json['provider'],
    );
  }
}
