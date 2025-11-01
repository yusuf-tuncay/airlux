import 'package:equatable/equatable.dart';

/// User domain entity
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, name, phone, photoUrl];
}

