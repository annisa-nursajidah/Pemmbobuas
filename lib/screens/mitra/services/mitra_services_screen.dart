import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/service_model.dart';
import '../../../services/firebase_service.dart';
import 'add_edit_service_screen.dart';

class MitraServicesScreen extends StatelessWidget {
  const MitraServicesScreen({super.key});

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
        title: const Text('Layanan Saya'),
        titleTextStyle: AppTextStyles.titleLarge
            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Layanan',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddEditServiceScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddEditServiceScreen())),
        backgroundColor: _mitraGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah Layanan',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: fb.getMitraServicesStream(mitraName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mitraGreen));
          }
          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: services.length,
            itemBuilder: (ctx, i) => _buildServiceCard(ctx, services[i]),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  service.imageUrl,
                  height: 120, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120, color: AppColors.surfaceGrey,
                    child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: 40),
                  ),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _mitraGreen, borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Aktif',
                            style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                if (service.isFeatured)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text('Unggulan', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(service.category, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(service.city, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mulai dari', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                        Text('Rp ${_formatPrice(service.price)}',
                            style: AppTextStyles.titleMedium.copyWith(color: _mitraGreen)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 3),
                        Text(service.mitraRating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Text('(${service.totalOrders})', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AddEditServiceScreen(existingService: service))),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.divider),
                          minimumSize: const Size(0, 40),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Promosi layanan segera hadir!'),
                              behavior: SnackBarBehavior.floating),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mitraGreen, minimumSize: const Size(0, 40),
                        ),
                        icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                        label: const Text('Promosi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_repair_service_outlined, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('Belum ada layanan', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Tambahkan layanan pertamamu untuk mulai menerima pesanan',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddEditServiceScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: _mitraGreen, minimumSize: const Size(0, 48)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Layanan Pertama'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double p) => p.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
