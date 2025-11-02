import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../aircraft/data/models/aircraft_model.dart';

/// Rezervasyon sayfası
class BookingPage extends StatefulWidget {
  final String aircraftId;

  const BookingPage({
    super.key,
    required this.aircraftId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  AircraftModel? _aircraft;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Login kontrolü - eğer kullanıcı giriş yapmamışsa login'e yönlendir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseService.currentUser;
      if (user == null && mounted) {
        context.go(RouteNames.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon yapmak için lütfen giriş yapın'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _loadAircraft();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadAircraft() {
    try {
      setState(() {
        _aircraft = DummyData.getDummyAircrafts().firstWhere(
              (a) => a.id == widget.aircraftId,
            );
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  double _calculateTotal() {
    if (_aircraft == null || _startDate == null || _endDate == null) {
      return 0.0;
    }

    final duration = _endDate!.difference(_startDate!);
    final hours = duration.inHours;
    return hours * _aircraft!.pricePerHour;
  }

  Future<void> _handleBooking() async {
    if (_aircraft == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // TODO: Create booking in Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking created successfully!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_aircraft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: Text('Aircraft not found')),
      );
    }

    final totalPrice = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Book Aircraft')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aircraft Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.flight,
                      size: 48,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _aircraft!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _aircraft!.manufacturer,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_aircraft!.pricePerHour.toStringAsFixed(0)}/hour',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Start Date
            const Text(
              'Start Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectStartDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _startDate == null
                    ? 'Select start date'
                    : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // End Date
            const Text(
              'End Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectEndDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _endDate == null
                    ? 'Select end date'
                    : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Any special requests or notes...',
              ),
            ),
            const SizedBox(height: 32),

            // Total Price
            if (totalPrice > 0) ...[
              Card(
                color: AppColors.backgroundCard,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment placeholder
            Text(
              '* Payment integration will be added with Stripe',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

