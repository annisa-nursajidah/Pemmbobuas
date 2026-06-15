import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                service.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  color: AppColors.lightBlue,
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    color: AppColors.accentBlue,
                    size: 36,
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 110,
                    height: 110,
                    color: AppColors.surfaceGrey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
                    Row(
                      children: [
                        _buildTag(service.category),
                        if (service.isEscrow) ...[
                          const SizedBox(width: 6),
                          _buildEscrowBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),

                    // Rating + Orders
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.starYellow, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          service.mitraRating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${service.totalOrders} pesanan',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Mitra name
                    Text(
                      service.mitraName,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Text(
                      'Mulai Rp ${_formatPrice(service.price)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accentBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEscrowBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined,
              size: 10, color: AppColors.escrowGreen),
          const SizedBox(width: 3),
          Text(
            'Escrow',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.escrowGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
