import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN UP
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? university,
    String? bio,
  }) async {
    try {
      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception("User creation failed");
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create database profile
      final AppUser appUser =
      await _userService.createUserFromSignup(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name,
        phone: phone,
        university: university,
        bio: bio,
      );

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // LOGIN
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception("Login failed");
      }

      final AppUser? appUser =
      await _userService.getUserProfile(firebaseUser.uid);

      if (appUser == null) {
        throw Exception("User profile not found");
      }

      await _userService.updateLastSeen();

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      await _userService.updateLastSeen();
      _userService.clearCurrentUser();

      await _auth.signOut();
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("No logged-in user");
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception("Failed to send verification email");
    }
  }

  // RELOAD USER
  Future<void> reloadUser() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      throw Exception("Failed to reload user");
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("No logged-in user");
      }

      // Delete database data
      await _userService.deleteUserProfile(user.uid);

      // Delete auth account
      await user.delete();

      _userService.clearCurrentUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          "Please login again before deleting account",
        );
      }

      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception("Delete account failed: $e");
    }
  }

  // ERROR HANDLER
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered';

      case 'invalid-email':
        return 'Invalid email address';

      case 'weak-password':
        return 'Password should be at least 6 characters';

      case 'user-not-found':
        return 'No account found';

      case 'wrong-password':
        return 'Incorrect password';

      case 'network-request-failed':
        return 'Check your internet connection';

      case 'too-many-requests':
        return 'Too many attempts. Try again later';

      default:
        return 'Authentication failed';
    }
  }
}