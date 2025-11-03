import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/aircraft_model.dart';

// Aviation Blue color palette
const Color _aviationBlue = Color(0xFF0F1E2E); // Gece mavisi - Arka plan
const Color _iceGray = Color(0xFFB4BEC9); // Buz grisi - Vurgu
const Color _lightGold = Color(0xFFD6C37D); // Açık altın - Accent

final LinearGradient _aviationGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_iceGray, _lightGold],
);

/// Ana sayfa - Uçak listesi
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<AircraftModel> _aircrafts = DummyData.getDummyAircrafts();
  List<AircraftModel> _filteredAircrafts = [];
  final TextEditingController _searchController = TextEditingController();

  // Filtreleme
  AircraftType? _selectedType;
  String _sortBy = 'price'; // price, rating, name

  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredAircrafts = _aircrafts;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    );
    _fadeController!.forward();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredAircrafts = _aircrafts.where((aircraft) {
        // Arama filtresi
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            searchQuery.isEmpty ||
            aircraft.name.toLowerCase().contains(searchQuery) ||
            aircraft.manufacturer.toLowerCase().contains(searchQuery) ||
            aircraft.type.toString().toLowerCase().contains(searchQuery);

        // Tip filtresi
        final matchesType =
            _selectedType == null || aircraft.type == _selectedType;

        return matchesSearch && matchesType;
      }).toList();

      // Sıralama
      _sortAircrafts();
    });
  }

  void _sortAircrafts() {
    switch (_sortBy) {
      case 'price':
        _filteredAircrafts.sort(
          (a, b) => a.pricePerHour.compareTo(b.pricePerHour),
        );
        break;
      case 'rating':
        _filteredAircrafts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        _filteredAircrafts.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to corresponding page
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.search);
        break;
      case 2:
        context.go(RouteNames.bookings);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
      case 4:
        context.go(RouteNames.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return ResponsiveScaffold(
      title: null, // Custom AppBar yapacağız
      bottomNavIndex: _selectedIndex,
      onBottomNavTap: _onNavTap,
      body: _fadeAnimation != null
          ? FadeTransition(
              opacity: _fadeAnimation!,
              child: _buildBody(context, isMobile),
            )
          : _buildBody(context, isMobile),
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    return CustomScrollView(
      slivers: [
        // Premium Header Section
        SliverToBoxAdapter(child: _buildHeader(context, isMobile)),

        // Filters & Search
        SliverToBoxAdapter(child: _buildFiltersSection(context, isMobile)),

        // Results Count
        if (_filteredAircrafts.length != _aircrafts.length)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredAircrafts.length} sonuç bulundu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),

        // Aircraft Grid/List
        _filteredAircrafts.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState())
            : isMobile
            ? _buildMobileSliverList()
            : _buildDesktopSliverGrid(),

        // Footer
        SliverToBoxAdapter(child: _buildFooter(isMobile)),
      ],
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.secondaryDark],
        ),
        border: Border(
          top: BorderSide(color: _lightGold.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: isMobile ? _buildMobileFooter() : _buildDesktopFooter(),
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo & Brand
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_lightGold, _lightGold]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _lightGold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.flight_takeoff_rounded,
                color: AppColors.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Airlux',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Premium Aviation',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Links
        _buildFooterSection(
          title: 'Hizmetler',
          items: [
            'Özel Jet Kiralama',
            'Helikopter Kiralama',
            'VIP Transfer',
            'Kurumsal Çözümler',
          ],
        ),
        const SizedBox(height: 24),
        _buildFooterSection(
          title: 'Şirket',
          items: ['Hakkımızda', 'Galeri', 'İletişim', 'Kariyer'],
        ),
        const SizedBox(height: 24),
        _buildFooterSection(
          title: 'Destek',
          items: [
            'Yardım Merkezi',
            'Gizlilik Politikası',
            'Kullanım Şartları',
            'SSS',
          ],
        ),
        const SizedBox(height: 32),

        // Social Media
        _buildSocialMedia(),
        const SizedBox(height: 32),

        // Copyright
        const Divider(color: AppColors.borderMedium),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '© 2024 Airlux. Tüm hakları saklıdır.',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFooter() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Brand Section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_lightGold, _lightGold],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _lightGold.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: AppColors.primaryDark,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Airlux',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Premium Aviation Services',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lüks havacılık deneyimi sunarak, özel jet ve helikopter kiralama hizmetleriyle hayallerinizi gerçeğe dönüştürüyoruz.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSocialMedia(),
                ],
              ),
            ),
            const SizedBox(width: 48),

            // Services
            Expanded(
              child: _buildFooterSection(
                title: 'Hizmetler',
                items: [
                  'Özel Jet Kiralama',
                  'Helikopter Kiralama',
                  'VIP Transfer',
                  'Kurumsal Çözümler',
                ],
              ),
            ),

            // Company
            Expanded(
              child: _buildFooterSection(
                title: 'Şirket',
                items: ['Hakkımızda', 'Galeri', 'İletişim', 'Kariyer'],
              ),
            ),

            // Support
            Expanded(
              child: _buildFooterSection(
                title: 'Destek',
                items: [
                  'Yardım Merkezi',
                  'Gizlilik Politikası',
                  'Kullanım Şartları',
                  'SSS',
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Divider(color: AppColors.borderMedium),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '© 2024 Airlux. Tüm hakları saklıdır.',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Text(
                  'info@airlux.com',
                  style: TextStyle(
                    color: _lightGold.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '+90 (212) 555 0123',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _iceGray,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to page
                },
                child: Text(
                  item,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMedia() {
    final socialItems = [
      (Icons.facebook, 'Facebook'),
      (Icons.camera_alt, 'Instagram'),
      (Icons.link, 'LinkedIn'),
      (Icons.alternate_email, 'Twitter'),
    ];

    return Row(
      children: socialItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // TODO: Open social media link
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderMedium.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  item.$1,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 32,
        isMobile ? 16 : 24,
        isMobile ? 20 : 32,
        isMobile ? 20 : 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lüks uçak ve helikopter filomuzu keşfedin',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Profile Icon
              Container(
                width: isMobile ? 40 : 48,
                height: isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _lightGold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  color: AppColors.backgroundCard.withValues(alpha: 0.5),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: _lightGold,
                  size: isMobile ? 20 : 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 16,
      ),
      color: AppColors.backgroundCard.withValues(alpha: 0.3),
      child: Column(
        children: [
          // Search Bar - Premium Design
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderMedium.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Uçak, helikopter veya üretici ara...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _lightGold.withValues(alpha: 0.7),
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Filters & Sort
          Row(
            children: [
              // Filter Button
              Expanded(child: _buildFilterChips(isMobile)),
              const SizedBox(width: 12),
              // Sort Button
              _buildSortButton(context, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeChip('Tümü', null, isMobile),
          const SizedBox(width: 8),
          _buildTypeChip('Jet', AircraftType.jet, isMobile),
          const SizedBox(width: 8),
          _buildTypeChip('Helikopter', AircraftType.helicopter, isMobile),
          const SizedBox(width: 8),
          _buildTypeChip('Turboprop', AircraftType.turboprop, isMobile),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, AircraftType? type, bool isMobile) {
    final isSelected = _selectedType == type;
    return _TypeChipWidget(
      label: label,
      type: type,
      isMobile: isMobile,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedType = isSelected ? null : type;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildSortButton(BuildContext context, bool isMobile) {
    return _SortButtonWidget(
      isMobile: isMobile,
      sortBy: _sortBy,
      onSortSelected: (value) {
        setState(() {
          _sortBy = value;
          _sortAircrafts();
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filtreleri değiştirerek tekrar deneyin',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSliverList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final aircraft = _filteredAircrafts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAircraftCard(aircraft, context),
          );
        }, childCount: _filteredAircrafts.length),
      ),
    );
  }

  Widget _buildDesktopSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isTablet(context) ? 2 : 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: Responsive.isTablet(context) ? 0.8 : 0.75,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final aircraft = _filteredAircrafts[index];
          return _buildAircraftCard(aircraft, context);
        }, childCount: _filteredAircrafts.length),
      ),
    );
  }

  Widget _buildAircraftCard(AircraftModel aircraft, BuildContext context) {
    return _PremiumAircraftCard(
      aircraft: aircraft,
      onTap: () {
        context.push('/aircraft/${aircraft.id}');
      },
    );
  }
}

/// Premium Aircraft Card with hover effects and animations
class _PremiumAircraftCard extends StatefulWidget {
  final AircraftModel aircraft;
  final VoidCallback onTap;

  const _PremiumAircraftCard({required this.aircraft, required this.onTap});

  @override
  State<_PremiumAircraftCard> createState() => _PremiumAircraftCardState();
}

class _PremiumAircraftCardState extends State<_PremiumAircraftCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.005).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHoverEnter() {
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _handleHoverExit() {
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.aircraft.specifications['range'] as String? ?? 'N/A';

    return MouseRegion(
      onEnter: (_) => _handleHoverEnter(),
      onExit: (_) => _handleHoverExit(),
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _isHovered
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.backgroundCard,
                          AppColors.backgroundCard.withValues(alpha: 0.98),
                          AppColors.primaryDarkLight.withValues(alpha: 0.15),
                        ],
                      )
                    : null,
                color: !_isHovered ? AppColors.backgroundCard : null,
                border: Border.all(
                  color: _isHovered
                      ? _lightGold.withValues(alpha: 0.25)
                      : AppColors.borderMedium.withValues(alpha: 0.2),
                  width: _isHovered ? 1.2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? _lightGold.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: _elevationAnimation.value + 12,
                    offset: Offset(0, _elevationAnimation.value + 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: _lightGold.withValues(alpha: 0.1),
                  highlightColor: _lightGold.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section with enhanced design
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            // Background Image
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryDarkLight,
                                    AppColors.secondaryDark,
                                    AppColors.primaryDark,
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: widget.aircraft.imageUrls.isNotEmpty
                                    ? AnimatedOpacity(
                                        opacity: _isHovered ? 0.9 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              widget.aircraft.imageUrls.first,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primaryDarkLight,
                                                  AppColors.secondaryDark,
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      _lightGold.withValues(
                                                        alpha: 0.6,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors
                                                          .primaryDarkLight,
                                                      AppColors.secondaryDark,
                                                    ],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    widget.aircraft.type ==
                                                            AircraftType
                                                                .helicopter
                                                        ? Icons.flight_rounded
                                                        : Icons
                                                              .flight_takeoff_rounded,
                                                    size: 72,
                                                    color: _lightGold
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryDarkLight,
                                              AppColors.secondaryDark,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            widget.aircraft.type ==
                                                    AircraftType.helicopter
                                                ? Icons.flight_rounded
                                                : Icons.flight_takeoff_rounded,
                                            size: 72,
                                            color: _lightGold.withValues(
                                              alpha: 0.25,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            // Animated Gradient Overlay
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    _isHovered
                                        ? _lightGold.withValues(alpha: 0.08)
                                        : AppColors.backgroundCard.withValues(
                                            alpha: 0.7,
                                          ),
                                    AppColors.backgroundCard.withValues(
                                      alpha: 0.95,
                                    ),
                                  ],
                                  stops: const [0.0, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),

                            // Availability Badge with pulse effect
                            if (widget.aircraft.isAvailable)
                              Positioned(
                                top: 14,
                                right: 14,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: _isHovered ? 12 : 8,
                                        spreadRadius: _isHovered ? 2 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Müsait',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Type Badge with enhanced design
                            Positioned(
                              top: 14,
                              left: 14,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? _lightGold.withValues(alpha: 0.25)
                                      : _lightGold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: _lightGold.withValues(
                                      alpha: _isHovered ? 0.8 : 0.5,
                                    ),
                                    width: _isHovered ? 1.5 : 1,
                                  ),
                                  boxShadow: _isHovered
                                      ? [
                                          BoxShadow(
                                            color: _lightGold.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _getTypeLabel(widget.aircraft.type),
                                  style: TextStyle(
                                    color: _aviationBlue,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Enhanced Info Section
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name with hover effect
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: _isHovered ? 19.5 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.4,
                                  height: 1.2,
                                ),
                                child: Text(
                                  widget.aircraft.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Manufacturer
                              Text(
                                widget.aircraft.manufacturer,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const Spacer(),

                              // Specifications Row
                              Row(
                                children: [
                                  // Range
                                  Expanded(
                                    child: _buildSpecItem(
                                      icon: Icons.flight_takeoff_rounded,
                                      value: range,
                                      label: 'Menzil',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Capacity
                                  Expanded(
                                    child: _buildSpecItem(
                                      icon: Icons.people_rounded,
                                      value:
                                          '${widget.aircraft.passengerCapacity}',
                                      label: 'Kişi',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Rating and Price Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Rating with enhanced design
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _lightGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _lightGold.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: _lightGold,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.aircraft.rating
                                              .toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _lightGold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${widget.aircraft.reviewCount})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textTertiary
                                                .withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price with premium gradient
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        _aviationGradient.createShader(bounds),
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: TextStyle(
                                        fontSize: _isHovered ? 19 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                      child: Text(
                                        '\$${(widget.aircraft.pricePerHour / 1000).toStringAsFixed(0)}K/saat',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderMedium.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textTertiary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(AircraftType type) {
    switch (type) {
      case AircraftType.jet:
        return 'Jet';
      case AircraftType.helicopter:
        return 'Helikopter';
      case AircraftType.turboprop:
        return 'Turboprop';
    }
  }
}

/// Type Chip Widget with hover effect
class _TypeChipWidget extends StatefulWidget {
  final String label;
  final AircraftType? type;
  final bool isMobile;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChipWidget({
    required this.label,
    required this.type,
    required this.isMobile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TypeChipWidget> createState() => _TypeChipWidgetState();
}

class _TypeChipWidgetState extends State<_TypeChipWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 14 : 18,
            vertical: widget.isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _lightGold
                : _isHovered
                ? _lightGold.withValues(alpha: 0.15)
                : AppColors.primaryDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? _lightGold
                  : _isHovered
                  ? _lightGold.withValues(alpha: 0.6)
                  : AppColors.borderMedium.withValues(alpha: 0.5),
              width: _isHovered && !widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _lightGold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : _isHovered
                ? [
                    BoxShadow(
                      color: _lightGold.withValues(alpha: 0.2),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected
                  ? AppColors.primaryDark
                  : _isHovered
                  ? _lightGold
                  : AppColors.textSecondary,
              fontSize: widget.isMobile ? 12 : 13,
              fontWeight: widget.isSelected || _isHovered
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sort Button Widget with hover effect
class _SortButtonWidget extends StatefulWidget {
  final bool isMobile;
  final String sortBy;
  final Function(String) onSortSelected;

  const _SortButtonWidget({
    required this.isMobile,
    required this.sortBy,
    required this.onSortSelected,
  });

  @override
  State<_SortButtonWidget> createState() => _SortButtonWidgetState();
}

class _SortButtonWidgetState extends State<_SortButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 14 : 18,
            vertical: widget.isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? _lightGold.withValues(alpha: 0.15)
                : AppColors.primaryDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? _lightGold.withValues(alpha: 0.6)
                  : AppColors.borderMedium.withValues(alpha: 0.5),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _lightGold.withValues(alpha: 0.2),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                color: _isHovered
                    ? _lightGold
                    : _lightGold.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Sırala',
                style: TextStyle(
                  color: _isHovered ? _lightGold : AppColors.textSecondary,
                  fontSize: widget.isMobile ? 12 : 13,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        onSelected: widget.onSortSelected,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'price',
            child: Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 18,
                  color: widget.sortBy == 'price'
                      ? _lightGold
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Text('Fiyat (Düşük → Yüksek)'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'rating',
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color: widget.sortBy == 'rating'
                      ? _lightGold
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Text('Değerlendirme (Yüksek → Düşük)'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'name',
            child: Row(
              children: [
                Icon(
                  Icons.sort_by_alpha,
                  size: 18,
                  color: widget.sortBy == 'name'
                      ? _lightGold
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Text('İsim (A → Z)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
