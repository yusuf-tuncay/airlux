import 'package:equatable/equatable.dart';

/// Aircraft entity - Domain katmanında kullanılır
class Aircraft extends Equatable {
  final String id;
  final String name;
  final String manufacturer;
  final int passengerCapacity;
  final double pricePerHour;
  final String description;
  final bool isAvailable;
  final double rating;

  const Aircraft({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.passengerCapacity,
    required this.pricePerHour,
    required this.description,
    required this.isAvailable,
    required this.rating,
  });

  @override
  List<Object> get props => [
        id,
        name,
        manufacturer,
        passengerCapacity,
        pricePerHour,
        description,
        isAvailable,
        rating,
      ];
}

