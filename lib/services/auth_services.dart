import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  //login with email & password:

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-credential') {
        return 'invalid-credential';
      }
      return e.message ?? 'Authentication failed';
    } catch (e) {
      print("Login error: $e");
      // Ignore PigeonUserDetails errors - they don't affect actual authentication
      if (e.toString().contains('PigeonUserDetails')) {
        return "Success";
      }
      return "Login failed: ${e.toString()}";
    }
  }
  //signup with email and password:

  Future<String?> signup(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message ?? 'Signup failed';
    } catch (e) {
      print("Signup error: $e");
      // Ignore PigeonUserDetails errors
      if (e.toString().contains('PigeonUserDetails')) {
        return "Success";
      }
      return "Signup failed: ${e.toString()}";
    }
  }

  //Google sign in:

  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return "Google sign-in cancelled";
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Firebase authentication failed";
    } catch (e) {
      print("Google sign-in error: $e");
      //return "Logout failed: ${e.toString()}";
      if (e.toString().contains('PigeonUserDetails')) {
        return "Google sign-in plugin error. Please try again.";
      }
      return "Google sign-in failed: ${e.toString()}";
    }
  }

  // Send password reset email:
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email address.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'missing-email') {
        return 'Please enter your email address.';
      }
      return e.message ?? 'Failed to send password reset email.';
    } catch (e) {
      print("Password reset error: $e");
      return "Failed to send reset email: ${e.toString()}";
    }
  }
}

