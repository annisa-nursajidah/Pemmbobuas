import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../services/firebase_service.dart';

class MitraReviewsScreen extends StatelessWidget {
  const MitraReviewsScreen({super.key});

  static const _mitraGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final mitraName = context.read<UserProvider>().currentUser?.name ?? '';
    final fb = FirebaseService();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: _mitraGreen,
        foregroundColor: Colors.white,
        title: const Text('Ulasan Pelanggan'),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fb.getMitraReviewsStream(mitraName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mitraGreen));
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.reviews_outlined, size: 72, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Belum ada ulasan', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Ulasan akan muncul setelah pelanggan menyelesaikan pesanan',
                      style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Hitung rata-rata
          final avgRating = reviews.fold(0.0, (s, r) => s + ((r['rating'] ?? 0.0) as num).toDouble()) / reviews.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_mitraGreen, Color(0xFF059669)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating Rata-rata', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(avgRating.toStringAsFixed(1),
                                style: AppTextStyles.displayLarge.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${reviews.length} ulasan',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFFBBF24), size: 20,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ...reviews.map((r) => _buildReviewCard(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r) {
    final rating = (r['rating'] ?? 0.0 as num).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  (r['customerName'] ?? 'A')[0].toUpperCase(),
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentBlue),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['customerName'] ?? '', style: AppTextStyles.titleMedium),
                    Text(r['serviceTitle'] ?? '',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B), size: 16,
                )),
              ),
            ],
          ),
          if ((r['comment'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(r['comment'] ?? '',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
