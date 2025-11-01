import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase servisleri için base class
class FirebaseService {
  /// Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase'i başlat
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// Mevcut kullanıcı
  static User? get currentUser => auth.currentUser;

  /// Kullanıcı durumunu dinle
  static Stream<User?> get authStateChanges => auth.authStateChanges();
}

