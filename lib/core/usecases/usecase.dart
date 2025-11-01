import 'package:equatable/equatable.dart';
import '../failures/failures.dart';

/// Base UseCase interface
/// Tüm use case'ler bu interface'i implement eder
abstract class UseCase<TResult, TParams> {
  Future<Either<Failure, TResult>> call(TParams params);
}

/// Parametre almayan use case
abstract class UseCaseNoParams<TResult> {
  Future<Either<Failure, TResult>> call();
}

/// Use case parametreleri için base class
abstract class Params extends Equatable {
  const Params();
}

/// Parametre almayan use case için empty params
class NoParams extends Params {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Either type - Success veya Failure döner
class Either<L, R> {
  final L? left;
  final R? right;
  final bool isLeft;

  Either._(this.left, this.right, this.isLeft);

  factory Either.left(L value) => Either._(value, null, true);
  factory Either.right(R value) => Either._(null, value, false);

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return isLeft ? onLeft(left as L) : onRight(right as R);
  }
}
