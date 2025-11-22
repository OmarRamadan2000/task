import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw AuthException('Failed to sign in with Google');
      }

      return UserModel.fromFirebaseUser(userCredential.user!, 'google');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign in failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Request only public_profile permission (email requires app review)
      final LoginResult result = await facebookAuth.login(
        permissions: ['public_profile'],
      );

      if (result.status != LoginStatus.success) {
        throw AuthException('Facebook sign in cancelled or failed');
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        throw AuthException('Failed to get Facebook access token');
      }

      final credential = firebase_auth.FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw AuthException('Failed to sign in with Facebook');
      }

      return UserModel.fromFirebaseUser(userCredential.user!, 'facebook');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Facebook sign in failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        facebookAuth.logOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      // Determine provider
      String provider = 'email';
      for (var info in user.providerData) {
        if (info.providerId.contains('google')) {
          provider = 'google';
          break;
        } else if (info.providerId.contains('facebook')) {
          provider = 'facebook';
          break;
        }
      }

      return UserModel.fromFirebaseUser(user, provider);
    } catch (e) {
      throw AuthException('Failed to get current user');
    }
  }
}
