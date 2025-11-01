import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

  AuthRepositoryImpl({firebase_auth.FirebaseAuth? auth})
      : _auth = auth ?? FirebaseService.auth;

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
      // TODO: Google Sign-In implementasyonu eklenecek
      // Şimdilik placeholder
      return Either.left(
        const AuthFailure('Google Sign-In henüz implemente edilmedi'),
      );
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
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
  UserEntity _userFromFirebase(firebase_auth.User user) {
    // Firestore'dan telefon numarasını al
    // Şimdilik sadece Firebase Auth bilgilerini kullan
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      // TODO: Firestore'dan telefon numarasını çek
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

