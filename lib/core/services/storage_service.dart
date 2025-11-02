import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../firebase/firebase_service.dart';

/// Storage service for file uploads
class StorageService {
  /// Upload profile photo to Firebase Storage
  /// Returns the download URL of the uploaded image
  static Future<String> uploadProfilePhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final ref = FirebaseService.storage
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      // Upload the file to Firebase Storage
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
          },
        ),
      );

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      rethrow;
    }
  }

  /// Upload file from bytes (for web)
  static Future<String> uploadProfilePhotoFromBytes({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    try {
      final ref = FirebaseService.storage
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      rethrow;
    }
  }

  /// Delete profile photo from Firebase Storage
  static Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = FirebaseService.storage
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting profile photo: $e');
      // Don't rethrow - if file doesn't exist, it's not a critical error
    }
  }
}

