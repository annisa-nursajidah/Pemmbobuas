import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/service_model.dart';
import '../order/add_order_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image + AppBar
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.primaryBlue,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isFavorite
                            ? AppColors.errorRed
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    s.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.lightBlue,
                      child: const Icon(
                        Icons.home_repair_service_rounded,
                        size: 80,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Row(
                        children: [
                          _buildTag(s.category, AppColors.lightBlue,
                              AppColors.accentBlue),
                          const SizedBox(width: 8),
                          if (s.isEscrow)
                            _buildTag(
                              '🔒 Escrow Protection',
                              const Color(0xFFDCFCE7),
                              AppColors.escrowGreen,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(s.title, style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 16),

                      // Mitra Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.lightBlue,
                              backgroundImage: s.mitraAvatarUrl.isNotEmpty
                                  ? NetworkImage(s.mitraAvatarUrl)
                                  : null,
                              child: s.mitraAvatarUrl.isEmpty
                                  ? const Icon(Icons.person_rounded,
                                      color: AppColors.accentBlue)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(s.mitraName,
                                          style: AppTextStyles.titleMedium),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.accentBlue,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: AppColors.starYellow,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        s.mitraRating.toStringAsFixed(1),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('•',
                                          style: AppTextStyles.bodySmall),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${s.totalOrders} pesanan',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const SizedBox(width: 6),
                                      Text('•',
                                          style: AppTextStyles.bodySmall),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Respon ${s.responseTime}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chat button
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur chat segera hadir!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text('Chat Mitra',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.accentBlue)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text('Deskripsi Layanan',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),
                      Text(s.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.6)),
                      const SizedBox(height: 20),

                      // Paket Layanan
                      if (s.packages.isNotEmpty) ...[
                        Text('Paket Layanan',
                            style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 12),
                        ...s.packages.map((pkg) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.divider),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(pkg.name,
                                            style:
                                                AppTextStyles.titleMedium),
                                        const SizedBox(height: 4),
                                        Text(pkg.description,
                                            style:
                                                AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatPrice(pkg.price)}',
                                    style: AppTextStyles.titleMedium
                                        .copyWith(
                                            color: AppColors.accentBlue),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      // Info tambahan
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(s.city, style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Bar sticky
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mulai dari',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                      Text(
                        'Rp ${_formatPrice(s.price)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddOrderScreen(service: s),
                        ),
                      ),
                      child: const Text('Pesan Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
