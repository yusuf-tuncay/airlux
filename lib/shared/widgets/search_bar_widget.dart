import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

/// Premium Arama Bar Widget - Teknevia tarzı optimize edilmiş
class SearchBarWidget extends StatefulWidget {
  final Function(String departure, DateTime? date, int passengers)? onSearch;

  const SearchBarWidget({super.key, this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isHovered = false;

  final TextEditingController _departureController = TextEditingController();
  DateTime? _selectedDate;
  int _passengers = 1;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _departureController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC0C0C0), // Silver
              onPrimary: Color(0xFF0A0A0A), // Piano Black
              surface: Color(0xFF2C2C2C), // Graphite Grey
              onSurface: Color(0xFFEDEDED), // Soft White
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF2C2C2C), // Graphite Grey
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showPassengerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Yolcu Sayısı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yolcu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    _PassengerButton(
                      icon: Icons.remove_rounded,
                      onPressed: _passengers > 1
                          ? () {
                              setState(() {
                                _passengers--;
                              });
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_passengers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _PassengerButton(
                      icon: Icons.add_rounded,
                      onPressed: () {
                        setState(() {
                          _passengers++;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    widget.onSearch?.call(
      _departureController.text,
      _selectedDate,
      _passengers,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1000,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.15 + (_shadowAnimation.value * 0.15),
                    ),
                    blurRadius: 20 + (_shadowAnimation.value * 12),
                    offset: Offset(0, 8 + (_shadowAnimation.value * 6)),
                    spreadRadius: _shadowAnimation.value * 2,
                  ),
                ],
              ),
              child: isMobile
                  ? _buildMobileSearchBar()
                  : _buildDesktopSearchBar(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileSearchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 4),
          child: _buildSearchField(
            controller: _departureController,
            hint: 'Nereden kalkış yapacaksın?',
            icon: Icons.flight_takeoff_rounded,
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
        _buildDateField(),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
        _buildPassengerField(),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
        _buildSearchButton(isMobile: true),
      ],
    );
  }

  Widget _buildDesktopSearchBar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _buildSearchField(
              controller: _departureController,
              hint: 'Nereden kalkış yapacaksın?',
              icon: Icons.flight_takeoff_rounded,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 56,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        Expanded(child: _buildDateField()),
        Container(
          width: 1,
          height: 56,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        Expanded(child: _buildPassengerField()),
        _buildSearchButton(isMobile: false),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFF0A1A2E),
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFC0C0C0), // Silver
          size: 22,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      ),
    );
  }

  Widget _buildDateField() {
    final dateText = _selectedDate != null
        ? _formatDate(_selectedDate!)
        : 'Tarih seç';

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: const Color(0xFFC0C0C0), // Silver
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: _selectedDate != null
                      ? const Color(0xFF0A1A2E)
                      : Colors.grey.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: _selectedDate != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerField() {
    return InkWell(
      onTap: () => _showPassengerPicker(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(
              Icons.people_rounded,
              color: const Color(0xFFC0C0C0), // Silver
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_passengers ${_passengers == 1 ? 'Yolcu' : 'Yolcu'}',
                style: const TextStyle(
                  color: Color(0xFF0A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton({required bool isMobile}) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8E8E8), // Light silver
            Color(0xFFC0C0C0), // Silver
            Color(0xFFA8A8A8), // Dark silver
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0C0C0).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSearch,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 32 : 28,
              vertical: isMobile ? 18 : 20,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

/// Yolcu butonu widget'ı
class _PassengerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PassengerButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: onPressed != null
                ? const Color(0xFFC0C0C0).withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onPressed != null
                  ? const Color(0xFFC0C0C0).withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: onPressed != null
                ? const Color(0xFFC0C0C0) // Silver
                : Colors.grey.withValues(alpha: 0.4),
            size: 22,
          ),
        ),
      ),
    );
  }
}
