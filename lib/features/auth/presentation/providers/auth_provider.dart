import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Current User Provider
final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Auth Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
    _listenToAuthChanges();
  }

  void _loadCurrentUser() {
    final user = _authRepository.currentUser;
    state = AsyncValue.data(user);
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    }).onError((error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    });
  }

  /// Email ile kayıt ol
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Email ile giriş yap
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Google ile giriş yap
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Çıkış yap
  Future<void> signOut() async {
    final result = await _authRepository.signOut();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  /// Profil fotoğrafı yükle
  Future<void> uploadProfilePhoto(String filePath, {XFile? xFile}) async {
    final currentState = state;
    if (currentState.value == null) {
      return;
    }

    final currentUser = currentState.value!;
    state = const AsyncValue.loading();
    final result = await _authRepository.uploadProfilePhoto(
      filePath: filePath,
      xFile: xFile,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        // Hata sonrası mevcut kullanıcıyı geri yükle
        Future.delayed(const Duration(milliseconds: 500), () {
          _loadCurrentUser();
        });
      },
      (photoUrl) async {
        // Başarılı - Önce state'i güncelle, sonra Firebase'den doğrulayalım
        final updatedUser = UserEntity(
          id: currentUser.id,
          email: currentUser.email,
          name: currentUser.name,
          phone: currentUser.phone,
          photoUrl: photoUrl,
        );
        state = AsyncValue.data(updatedUser);
        
        // Firebase Auth'tan güncel bilgiyi çek (async)
        await Future.delayed(const Duration(milliseconds: 300));
        _loadCurrentUser();
      },
    );
  }
}

