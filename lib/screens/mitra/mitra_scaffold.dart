import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/mitra_dashboard_screen.dart';
import 'orders/mitra_orders_screen.dart';
import 'services/mitra_services_screen.dart';
import 'profile/mitra_profile_screen.dart';

class MitraScaffold extends StatefulWidget {
  const MitraScaffold({super.key});

  @override
  State<MitraScaffold> createState() => _MitraScaffoldState();
}

class _MitraScaffoldState extends State<MitraScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MitraDashboardScreen(),
    MitraOrdersScreen(),
    MitraServicesScreen(),
    MitraProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard_rounded,
      'label': 'Dashboard',
    },
    {
      'icon': Icons.inbox_outlined,
      'activeIcon': Icons.inbox_rounded,
      'label': 'Pesanan',
    },
    {
      'icon': Icons.home_repair_service_outlined,
      'activeIcon': Icons.home_repair_service_rounded,
      'label': 'Layanan',
    },
    {
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
      'label': 'Profil',
    },
  ];

  static const _mitraGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _mitraGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: _mitraGreen,
            unselectedItemColor: AppColors.textHint,
            backgroundColor: AppColors.white,
            type: BottomNavigationBarType.fixed,
            items: _navItems
                .map((item) => BottomNavigationBarItem(
                      icon: Icon(item['icon'], size: 22),
                      activeIcon: Icon(item['activeIcon'], size: 22),
                      label: item['label'],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
