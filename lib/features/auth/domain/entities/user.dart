import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String provider; // 'google' or 'facebook'

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, provider];
}
