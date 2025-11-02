import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/aircraft_model.dart';

/// Ana sayfa - Uçak listesi
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<AircraftModel> _aircrafts = DummyData.getDummyAircrafts();
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
        final matchesSearch = searchQuery.isEmpty ||
            aircraft.name.toLowerCase().contains(searchQuery) ||
            aircraft.manufacturer.toLowerCase().contains(searchQuery) ||
            aircraft.type.toString().toLowerCase().contains(searchQuery);
        
        // Tip filtresi
        final matchesType = _selectedType == null || aircraft.type == _selectedType;
        
        return matchesSearch && matchesType;
      }).toList();
      
      // Sıralama
      _sortAircrafts();
    });
  }

  void _sortAircrafts() {
    switch (_sortBy) {
      case 'price':
        _filteredAircrafts.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
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
        SliverToBoxAdapter(
          child: _buildHeader(context, isMobile),
        ),
        
        // Filters & Search
        SliverToBoxAdapter(
          child: _buildFiltersSection(context, isMobile),
        ),
        
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
            ? SliverFillRemaining(
                child: _buildEmptyState(),
              )
            : isMobile
                ? _buildMobileSliverList()
                : _buildDesktopSliverGrid(),
        
        // Footer
        SliverToBoxAdapter(
          child: _buildFooter(isMobile),
        ),
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
          colors: [
            AppColors.primaryDark,
            AppColors.secondaryDark,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.goldMedium.withValues(alpha: 0.2),
            width: 1,
          ),
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldMedium,
                    AppColors.gold,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldMedium.withValues(alpha: 0.3),
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
          items: [
            'Hakkımızda',
            'Galeri',
            'İletişim',
            'Kariyer',
          ],
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
                            colors: [
                              AppColors.goldMedium,
                              AppColors.gold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldMedium.withValues(alpha: 0.3),
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
                items: [
                  'Hakkımızda',
                  'Galeri',
                  'İletişim',
                  'Kariyer',
                ],
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
                    color: AppColors.goldMedium.withValues(alpha: 0.8),
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
            color: AppColors.goldMedium,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
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
        )),
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
                    color: AppColors.goldMedium.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  color: AppColors.backgroundCard.withValues(alpha: 0.5),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.goldMedium,
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
                  color: AppColors.goldMedium.withValues(alpha: 0.7),
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
              Expanded(
                child: _buildFilterChips(isMobile),
              ),
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSliverList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final aircraft = _filteredAircrafts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAircraftCard(aircraft, context),
            );
          },
          childCount: _filteredAircrafts.length,
        ),
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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final aircraft = _filteredAircrafts[index];
            return _buildAircraftCard(aircraft, context);
          },
          childCount: _filteredAircrafts.length,
        ),
      ),
    );
  }

  Widget _buildAircraftCard(AircraftModel aircraft, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundCard,
        border: Border.all(
          color: AppColors.borderMedium.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/aircraft/${aircraft.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    // Background Image or Gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
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
                      child: aircraft.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: aircraft.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.goldMedium.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    aircraft.type == AircraftType.helicopter
                                        ? Icons.flight
                                        : Icons.flight_takeoff,
                                    size: 64,
                                    color: AppColors.gold.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                aircraft.type == AircraftType.helicopter
                                    ? Icons.flight
                                    : Icons.flight_takeoff,
                                size: 64,
                                color: AppColors.gold.withValues(alpha: 0.3),
                              ),
                            ),
                    ),
                    
                    // Availability Badge
                    if (aircraft.isAvailable)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Müsait',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Type Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldMedium.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.goldMedium.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getTypeLabel(aircraft.type),
                          style: TextStyle(
                            color: AppColors.goldMedium,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.backgroundCard.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Manufacturer
                      Text(
                        aircraft.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aircraft.manufacturer,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.goldMedium,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            aircraft.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${aircraft.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Passenger & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${aircraft.passengerCapacity}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.premiumGoldGradient.createShader(bounds),
                            child: Text(
                              '\$${aircraft.pricePerHour.toStringAsFixed(0)}/saat',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
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
                ? AppColors.goldMedium
                : _isHovered
                    ? AppColors.goldMedium.withValues(alpha: 0.15)
                    : AppColors.primaryDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.goldMedium
                  : _isHovered
                      ? AppColors.goldMedium.withValues(alpha: 0.6)
                      : AppColors.borderMedium.withValues(alpha: 0.5),
              width: _isHovered && !widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.goldMedium.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.goldMedium.withValues(alpha: 0.2),
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
                      ? AppColors.goldMedium
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
                ? AppColors.goldMedium.withValues(alpha: 0.15)
                : AppColors.primaryDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppColors.goldMedium.withValues(alpha: 0.6)
                  : AppColors.borderMedium.withValues(alpha: 0.5),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.goldMedium.withValues(alpha: 0.2),
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
                    ? AppColors.goldMedium
                    : AppColors.goldMedium.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Sırala',
                style: TextStyle(
                  color: _isHovered
                      ? AppColors.goldMedium
                      : AppColors.textSecondary,
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
                      ? AppColors.goldMedium
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
                      ? AppColors.goldMedium
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
                      ? AppColors.goldMedium
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

