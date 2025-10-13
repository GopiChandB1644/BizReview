import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }
  // Add this method to save username
  Future<String?> saveUserProfile({
    String? profileImage,
    String? username,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      Map<String, dynamic> data = {
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (profileImage != null) {
        data['profileImage'] = profileImage;
      }

      if (username != null) {
        data['username'] = username;
        data['displayName'] = username;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      return "Success";
    } catch (e) {
      print("Error saving user profile: $e");
      return null;
    }
  }
  Future<String?> pickAndUploadImage() async {
    try {
      print("Starting image picker...");

      // Try different approach - create new instance each time
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 400,
        maxWidth: 400,
        imageQuality: 60,
      );

      if (image == null) {
        print("No image selected");
        return null;
      }

      print("Image picked successfully: ${image.path}");

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No authenticated user");
        return null;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'profileImage': base64String,
        'email': user.email,
        'displayName': user.displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Image uploaded successfully");
      return base64String;
    } on PlatformException catch (e) {
      print("Platform exception: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<String?> getProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['profileImage'];
      }
      return null;
    } catch (e) {
      print("Error getting profile image: $e");
      return null;
    }
  }
}
