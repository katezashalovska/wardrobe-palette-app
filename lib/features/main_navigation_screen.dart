import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'wardrobe/wardrobe_screen.dart';
import 'scanner/scanner_screen.dart';
import 'palette/palette_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    WardrobeScreen(),
    ScannerScreen(),
    PaletteScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _screens[selectedIndex],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => ref.read(navigationProvider.notifier).state = index,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textBody.withOpacity(0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_outlined),
                ),
                activeIcon: Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.home, color: AppColors.primary),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.auto_awesome_outlined),
                ),
                activeIcon: Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary),
                ),
                label: 'Wardrobe',
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.camera_alt_outlined),
                ),
                activeIcon: Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.palette_outlined),
                ),
                activeIcon: Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.palette, color: AppColors.primary),
                ),
                label: 'Palette',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
