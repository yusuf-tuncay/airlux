import 'package:image_picker/image_picker.dart';
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

  /// Profil fotoğrafı yükle
  /// filePath: Mobil için dosya yolu, Web için XFile'dan alınacak
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String filePath,
    XFile? xFile, // Web için gerekli
  });

  /// Mevcut kullanıcı
  UserEntity? get currentUser;

  /// Auth durum değişikliklerini dinle
  Stream<UserEntity?> get authStateChanges;
}

