import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Responsive layout widget'ı
/// Cihaz tipine göre farklı layout'lar gösterir
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultraDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isUltraDesktop(context) && ultraDesktop != null) {
      return ultraDesktop!;
    }
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Scaffold wrapper with responsive layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int? bottomNavIndex;
  final Function(int)? onBottomNavTap;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavIndex,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: title != null
            ? AppBar(
                title: Text(title!),
                actions: actions,
              )
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavIndex != null && onBottomNavTap != null
            ? BottomNavigationBar(
                currentIndex: bottomNavIndex!,
                onTap: onBottomNavTap,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flight),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Bookings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
      ),
      tablet: Scaffold(
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
        ),
        body: Row(
          children: [
            // Side Navigation
            NavigationRail(
              selectedIndex: bottomNavIndex ?? 0,
              onDestinationSelected: onBottomNavTap ?? (_) {},
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.flight),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Body
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
      desktop: Scaffold(
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions,
        ),
        body: Row(
          children: [
            // Side Navigation
            NavigationRail(
              selectedIndex: bottomNavIndex ?? 0,
              onDestinationSelected: onBottomNavTap ?? (_) {},
              extended: true,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.flight),
                  selectedIcon: Icon(Icons.flight),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Body
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

