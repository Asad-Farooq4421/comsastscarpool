import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseDatabase _database =
      FirebaseDatabase.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  late final DatabaseReference _usersRef;

  // Singleton
  static final UserService _instance =
  UserService._internal();

  factory UserService() => _instance;

  UserService._internal() {
    _usersRef = _database.ref("users");
  }

  // Cached current user
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // Current Firebase user
  User get firebaseUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return user;
  }

  // Current UID
  String get currentUserId => firebaseUser.uid;

  // GET USER PROFILE
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final DatabaseEvent event =
      await _usersRef.child(uid).once();

      final data = event.snapshot.value;

      if (data == null) {
        return null;
      }

      if (data is Map) {
        final Map<String, dynamic> userMap =
        Map<String, dynamic>.from(data);

        final AppUser user =
        AppUser.fromJson(userMap, uid);

        // Cache current user
        if (uid == _auth.currentUser?.uid) {
          _currentUser = user;
        }

        return user;
      }

      return null;
    } catch (e) {
      debugPrint("Get user profile error: $e");
      return null;
    }
  }

  // SAVE USER
  Future<void> saveUserProfile(AppUser user) async {
    try {
      await _usersRef
          .child(user.uid)
          .set(user.toJson());

      _currentUser = user;
    } catch (e) {
      throw Exception("Failed to save profile");
    }
  }

  // UPDATE PROFILE
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _usersRef.child(uid).update(updates);

      // Refresh cache
      if (_currentUser?.uid == uid) {
        await getUserProfile(uid);
      }
    } catch (e) {
      throw Exception("Failed to update profile");
    }
  }

  // CREATE USER AFTER SIGNUP
  Future<AppUser> createUserFromSignup({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? university,
    String? bio,
  }) async {
    final AppUser newUser = AppUser(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      university: university ?? "COMSATS Islamabad",
      bio: bio,
      createdAt: DateTime.now(),
    );

    await saveUserProfile(newUser);

    return newUser;
  }

  // UPDATE LAST SEEN
  Future<void> updateLastSeen() async {
    try {
      await _usersRef.child(currentUserId).update({
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint("Update last seen error: $e");
    }
  }

  // DELETE USER PROFILE
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersRef.child(uid).remove();
    } catch (e) {
      throw Exception("Failed to delete user profile");
    }
  }

  // USER STREAM
  Stream<DatabaseEvent> getUserStream(String uid) {
    return _usersRef.child(uid).onValue;
  }

  // CLEAR CACHE
  void clearCurrentUser() {
    _currentUser = null;
  }
}