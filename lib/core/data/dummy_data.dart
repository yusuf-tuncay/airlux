import '../../features/aircraft/data/models/aircraft_model.dart';

/// Test amaçlı dummy uçak verileri
class DummyData {
  /// Dummy uçak listesi
  static List<AircraftModel> getDummyAircrafts() {
    return [
      AircraftModel(
        id: '1',
        name: 'Gulfstream G650',
        manufacturer: 'Gulfstream Aerospace',
        type: AircraftType.jet,
        passengerCapacity: 19,
        pricePerHour: 15000,
        description:
            'Dünyanın en lüks özel jetlerinden biri. Uzun menzil, geniş kabin ve en yüksek konfor standartları.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': 'Mach 0.925',
          'range': '7,000 nm',
          'cruiseAltitude': '51,000 ft',
          'cabinLength': '13.3 m',
          'cabinHeight': '1.96 m',
          'cabinWidth': '2.59 m',
        },
        isAvailable: true,
        rating: 4.9,
        reviewCount: 127,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AircraftModel(
        id: '2',
        name: 'Bombardier Global 7500',
        manufacturer: 'Bombardier',
        type: AircraftType.jet,
        passengerCapacity: 19,
        pricePerHour: 18000,
        description:
            'En uzun menzilli özel jet. Dünya çapında non-stop uçuş kapasitesi.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': 'Mach 0.925',
          'range': '7,700 nm',
          'cruiseAltitude': '51,000 ft',
          'cabinLength': '13.8 m',
          'cabinHeight': '1.95 m',
          'cabinWidth': '2.49 m',
        },
        isAvailable: true,
        rating: 4.8,
        reviewCount: 95,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      AircraftModel(
        id: '3',
        name: 'Airbus H145',
        manufacturer: 'Airbus Helicopters',
        type: AircraftType.helicopter,
        passengerCapacity: 9,
        pricePerHour: 3500,
        description:
            'Premium helikopter deneyimi. Şehir içi ve kısa mesafe seyahatler için ideal.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': '140 kts',
          'range': '358 nm',
          'maxAltitude': '20,000 ft',
          'cabinCapacity': '9 passengers',
        },
        isAvailable: true,
        rating: 4.7,
        reviewCount: 68,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      AircraftModel(
        id: '4',
        name: 'Cessna Citation XLS+',
        manufacturer: 'Cessna',
        type: AircraftType.jet,
        passengerCapacity: 9,
        pricePerHour: 5500,
        description:
            'Orta sınıf özel jet. Verimli ve konforlu seyahat deneyimi.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': 'Mach 0.735',
          'range': '2,040 nm',
          'cruiseAltitude': '45,000 ft',
          'cabinLength': '5.79 m',
        },
        isAvailable: true,
        rating: 4.6,
        reviewCount: 152,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AircraftModel(
        id: '5',
        name: 'AgustaWestland AW139',
        manufacturer: 'Leonardo',
        type: AircraftType.helicopter,
        passengerCapacity: 15,
        pricePerHour: 4500,
        description:
            'Geniş kabinli helikopter. Grup seyahatleri için mükemmel.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': '165 kts',
          'range': '568 nm',
          'maxAltitude': '20,000 ft',
          'cabinCapacity': '15 passengers',
        },
        isAvailable: true,
        rating: 4.8,
        reviewCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AircraftModel(
        id: '6',
        name: 'Pilatus PC-24',
        manufacturer: 'Pilatus Aircraft',
        type: AircraftType.turboprop,
        passengerCapacity: 11,
        pricePerHour: 4200,
        description:
            'Tek motorlu turboprop. Kısa pistlerde iniş-kalkış yapabilme özelliği.',
        imageUrls: [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
        ],
        specifications: {
          'maxSpeed': '440 kts',
          'range': '2,000 nm',
          'cruiseAltitude': '45,000 ft',
          'cabinLength': '7.01 m',
        },
        isAvailable: true,
        rating: 4.5,
        reviewCount: 43,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}

