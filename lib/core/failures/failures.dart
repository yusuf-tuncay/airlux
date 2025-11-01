import 'package:equatable/equatable.dart';

/// Base Failure sınıfı
/// Tüm hata durumları bu sınıftan türetilir
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server hatası
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network hatası
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache hatası
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication hatası
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation hatası
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Permission hatası
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Not Found hatası
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

