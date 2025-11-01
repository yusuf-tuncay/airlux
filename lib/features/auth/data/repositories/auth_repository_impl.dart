import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/failures/failures.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseService.auth,
       _googleSignIn = googleSignIn;

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Either.left(const AuthFailure('Kullanıcı oluşturulamadı'));
      }

      // Kullanıcı profilini güncelle
      await credential.user!.updateDisplayName(name);

      // Firestore'a kullanıcı bilgilerini kaydet
      try {
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: name,
          phoneNumber: phone,
          createdAt: DateTime.now(),
        );

        await FirebaseService.firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());
      } catch (e) {
        // Firestore yazma hatası (örneğin permission denied)
        // Auth başarılı olduğu için kullanıcı oluşturuldu
        // Firestore hatası önemli değil, kullanıcı giriş yapabilir
        debugPrint('Firestore write error (non-critical): $e');
      }

      return Either.right(_userFromFirebase(credential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Either.left(const AuthFailure('Giriş başarısız'));
      }

      return Either.right(_userFromFirebase(credential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Either.left(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // Web için Firebase Auth'un kendi Google Sign-In metodunu kullan
      // Bu, google_sign_in paketini kullanmadan doğrudan Firebase ile çalışır
      final firebase_auth.GoogleAuthProvider googleProvider =
          firebase_auth.GoogleAuthProvider();

      // Google Sign-In işlemini başlat
      final userCredential = await _auth.signInWithPopup(googleProvider);

      if (userCredential.user == null) {
        return Either.left(const AuthFailure('Google girişi başarısız'));
      }

      final user = userCredential.user!;

      // Kullanıcı bilgilerini Firestore'a kaydet (eğer yoksa)
      try {
        final userDoc = await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Yeni kullanıcı - Firestore'a kaydet
          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
          );

          await FirebaseService.firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toFirestore());
        } else {
          // Mevcut kullanıcı - son giriş zamanını güncelle
          await FirebaseService.firestore
              .collection('users')
              .doc(user.uid)
              .update({'lastLoginAt': Timestamp.fromDate(DateTime.now())});
        }
      } catch (e) {
        // Firestore yazma hatası kritik değil, giriş başarılı
        debugPrint('Firestore write error (non-critical): $e');
      }

      return Either.right(_userFromFirebase(user));
    } on firebase_auth.FirebaseAuthException catch (e) {
      // "popup-closed-by-user" hatası - kullanıcı popup'ı kapattı
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return Either.left(const AuthFailure('Google girişi iptal edildi'));
      }
      return Either.left(AuthFailure(_getErrorMessage(e.code)));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Firebase'den çıkış yap
      await _auth.signOut();

      // Google Sign-In'den de çıkış yap (eğer varsa - mobil platformlar için)
      // Web için Firebase Auth signOut yeterli
      final googleSignIn = _googleSignIn;
      if (googleSignIn != null) {
        try {
          await googleSignIn.signOut();
        } catch (e) {
          // Google Sign-In çıkış hatası kritik değil
          debugPrint('Google Sign-In signOut error (non-critical): $e');
        }
      }

      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _userFromFirebase(user) : null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? _userFromFirebase(user) : null;
    });
  }

  /// Firebase User'ı UserEntity'ye çevir
  /// Firestore'dan telefon numarasını da çeker (async olmadığı için null döner)
  UserEntity _userFromFirebase(firebase_auth.User user) {
    // Firestore'dan telefon numarası çekilemez (bu metod sync)
    // Telefon numarası kontrolü router veya UI katmanında yapılmalı
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      phone: null, // Firestore'dan çekilmeli (async işlem)
    );
  }

  /// Firebase hata kodlarını Türkçe mesajlara çevir
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu kullanıcı devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre.';
      case 'too-many-requests':
        return 'Çok fazla istek. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
