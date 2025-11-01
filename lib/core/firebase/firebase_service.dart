import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firebase servisleri için base class
class FirebaseService {
  /// Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase'i başlat
  /// Not: Firebase initialization artık main.dart'ta yapılıyor
  /// Bu metod artık kullanılmıyor ama geriye dönük uyumluluk için bırakıldı
  @Deprecated('Firebase initialization artık main.dart\'ta yapılıyor')
  static Future<void> initialize() async {
    // Firebase zaten main.dart'ta initialize ediliyor
    // Bu metod artık gerekli değil
  }

  /// Mevcut kullanıcı
  static User? get currentUser => auth.currentUser;

  /// Kullanıcı durumunu dinle
  static Stream<User?> get authStateChanges => auth.authStateChanges();
}

