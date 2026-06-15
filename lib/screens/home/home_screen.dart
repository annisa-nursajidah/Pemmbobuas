import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/service_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/service_card.dart';
import '../service/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // Seed data otomatis ke Firestore jika belum ada
    _firebaseService.seedServices();
  }

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': Icons.apps_rounded},
    {'label': 'Elektronik', 'icon': Icons.electrical_services_rounded},
    {'label': 'Kebersihan', 'icon': Icons.cleaning_services_rounded},
    {'label': 'Renovasi', 'icon': Icons.construction_rounded},
    {'label': 'Listrik', 'icon': Icons.bolt_rounded},
    {'label': 'Laundry', 'icon': Icons.local_laundry_service_rounded},
    {'label': 'Otomotif', 'icon': Icons.directions_car_rounded},
    {'label': 'Kreatif', 'icon': Icons.palette_rounded},
  ];

  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'Diskon 20% Service AC',
      'subtitle': 'Berlaku hingga 30 Juni 2025',
      'color': AppColors.primaryBlue,
    },
    {
      'title': 'Gratis Ongkir Laundry',
      'subtitle': 'Min. order 5kg. Kode: GRATIS',
      'color': const Color(0xFF7C3AED),
    },
    {
      'title': 'Cashback Rp 50.000',
      'subtitle': 'Untuk pesanan pertama Anda',
      'color': const Color(0xFF059669),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, Ahmad! 👋',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.white.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mau cari jasa apa hari ini?',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: AppColors.white),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF97316),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    GestureDetector(
                      onTap: () {
                        // navigate to explore
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.textHint, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Cari jasa atau kategori...',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Promo Banner
            SliverToBoxAdapter(child: _buildPromoBanner()),

            // Kategori
            SliverToBoxAdapter(child: _buildCategorySection()),

            // Layanan Populer
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('Layanan Populer',
                    style: AppTextStyles.headlineMedium),
              ),
            ),

            // Stream dari Firestore
            StreamBuilder<List<ServiceModel>>(
              stream: _selectedCategoryIndex == 0
                  ? _firebaseService.getServicesStream()
                  : _firebaseService.getServicesByCategory(
                      _categories[_selectedCategoryIndex]['label']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _buildShimmerCard(),
                      childCount: 4,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 64, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text('Tidak ada layanan ditemukan',
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final services = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == services.length) {
                        return const SizedBox(height: 24);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        child: ServiceCard(
                          service: services[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(
                                  service: services[index]),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: services.length + 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    final controller = PageController(viewportFraction: 0.9);
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: PageView.builder(
          controller: controller,
          itemCount: _promos.length,
          itemBuilder: (context, index) {
            final promo = _promos[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: promo['color'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'PROMO',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          promo['title'],
                          style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo['subtitle'],
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.local_offer_rounded,
                      size: 60, color: Colors.white24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text('Kategori', style: AppTextStyles.headlineMedium),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategoryIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.divider,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.accentBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          cat['icon'],
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'],
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
