import '../../../../core/usecases/usecase.dart';
import '../../../../core/failures/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Email ile kayıt ol
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  /// Email ile giriş yap
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Google ile giriş yap
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Çıkış yap
  Future<Either<Failure, void>> signOut();

  /// Mevcut kullanıcı
  UserEntity? get currentUser;

  /// Auth durum değişikliklerini dinle
  Stream<UserEntity?> get authStateChanges;
}

