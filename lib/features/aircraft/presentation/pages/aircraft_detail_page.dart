import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/dummy_data.dart';
import '../../data/models/aircraft_model.dart';

/// Uçak detay sayfası
class AircraftDetailPage extends StatelessWidget {
  final String aircraftId;

  const AircraftDetailPage({super.key, required this.aircraftId});

  AircraftModel? get _aircraft {
    try {
      return DummyData.getDummyAircrafts().firstWhere(
        (a) => a.id == aircraftId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aircraft = _aircraft;

    if (aircraft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Uçak Bulunamadı')),
        body: const Center(child: Text('Uçak bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(aircraft.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDarkLight, AppColors.secondaryDark],
                ),
              ),
              child: Center(
                child: Icon(
                  aircraft.type.toString().contains('helicopter')
                      ? Icons.flight
                      : Icons.flight_takeoff,
                  size: 120,
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    aircraft.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aircraft.manufacturer,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating & Price
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.gold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        aircraft.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${aircraft.reviewCount} değerlendirme)',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${aircraft.pricePerHour.toStringAsFixed(0)}/saat',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Açıklama',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aircraft.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  const Text(
                    'Özellikler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...aircraft.specifications.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Capacity
                  Row(
                    children: [
                      Icon(Icons.people, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        'Yolcu Kapasitesi: ${aircraft.passengerCapacity}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/booking/${aircraft.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Rezervasyon Yap',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
