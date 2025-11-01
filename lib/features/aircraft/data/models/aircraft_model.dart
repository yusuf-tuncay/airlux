import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'aircraft_model.g.dart'; // Uncomment after running: flutter pub run build_runner build

/// Uçak/Helikopter tipi enum
enum AircraftType {
  jet,
  helicopter,
  turboprop,
}

/// Uçak modeli
@JsonSerializable()
class AircraftModel {
  final String id;
  final String name;
  final String manufacturer;
  final AircraftType type;
  final int passengerCapacity;
  final double pricePerHour;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  AircraftModel({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.type,
    required this.passengerCapacity,
    required this.pricePerHour,
    required this.description,
    required this.imageUrls,
    required this.specifications,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  /// Firestore'dan model oluştur
  factory AircraftModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AircraftModel(
      id: doc.id,
      name: data['name'] as String,
      manufacturer: data['manufacturer'] as String,
      type: AircraftType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => AircraftType.jet,
      ),
      passengerCapacity: data['passengerCapacity'] as int,
      pricePerHour: (data['pricePerHour'] as num).toDouble(),
      description: data['description'] as String,
      imageUrls: List<String>.from(data['imageUrls'] as List),
      specifications: Map<String, dynamic>.from(data['specifications'] as Map),
      isAvailable: data['isAvailable'] as bool? ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a kaydetmek için Map'e çevir
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'manufacturer': manufacturer,
      'type': type.toString().split('.').last,
      'passengerCapacity': passengerCapacity,
      'pricePerHour': pricePerHour,
      'description': description,
      'imageUrls': imageUrls,
      'specifications': specifications,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// JSON'dan model oluştur
  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    // TODO: Generate with build_runner: flutter pub run build_runner build
    return AircraftModel(
      id: json['id'] as String,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String,
      type: AircraftType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AircraftType.jet,
      ),
      passengerCapacity: json['passengerCapacity'] as int,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      specifications: Map<String, dynamic>.from(json['specifications'] as Map),
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    // TODO: Generate with build_runner
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'type': type.toString().split('.').last,
      'passengerCapacity': passengerCapacity,
      'pricePerHour': pricePerHour,
      'description': description,
      'imageUrls': imageUrls,
      'specifications': specifications,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

