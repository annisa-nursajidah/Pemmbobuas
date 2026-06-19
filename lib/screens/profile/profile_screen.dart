import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../order/order_screen.dart';
import 'address_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final fb = FirebaseService();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header biru ──────────────────────────────────
              Container(
                width: double.infinity,
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // Avatar + info
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.white.withOpacity(0.3),
                                backgroundImage: user?.avatarUrl.isNotEmpty == true
                                    ? NetworkImage(user!.avatarUrl) : null,
                                child: user?.avatarUrl.isNotEmpty != true
                                    ? const Icon(Icons.person_rounded, color: AppColors.white, size: 36)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.name ?? 'Pengguna',
                                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white)),
                              const SizedBox(height: 4),
                              Text(user?.formattedPhone ?? '-',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8))),
                              const SizedBox(height: 2),
                              Text(user?.memberSinceLabel ?? 'Member',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.65))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit_outlined, color: AppColors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row — dari database
                    FutureBuilder<Map<String, dynamic>>(
                      future: fb.getUserOrderStats(user?.id ?? ''),
                      builder: (ctx, snap) {
                        final stats = snap.data;
                        final total = stats?['total'] ?? 0;
                        final selesai = stats?['selesai'] ?? 0;
                        final belanja = (stats?['totalBelanja'] ?? 0.0) as double;
                        final belanjaStr = belanja >= 1000000
                            ? '${(belanja / 1000000).toStringAsFixed(1)}Jt'
                            : belanja >= 1000
                                ? '${(belanja / 1000).toStringAsFixed(0)}Rb'
                                : belanja.toStringAsFixed(0);
                        return Row(
                          children: [
                            _buildStatCard(total.toString(), 'Total\nPesanan'),
                            const SizedBox(width: 10),
                            _buildStatCard(selesai.toString(), 'Selesai'),
                            const SizedBox(width: 10),
                            _buildStatCard(
                                belanja == 0 ? '-' : 'Rp $belanjaStr', 'Total\nBelanja'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Menu items ───────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(context, Icons.person_outline_rounded, 'Edit Profil',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                    const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                    _buildMenuItem(context, Icons.location_on_outlined, 'Alamat Saya',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddressScreen()))),
                    const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                    _buildMenuItem(context, Icons.receipt_long_outlined, 'Riwayat Transaksi',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const OrderScreen()))),
                    const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                    _buildMenuItem(context, Icons.credit_card_outlined, 'Metode Pembayaran',
                        onTap: () => _snack(context, 'Metode Pembayaran segera hadir!')),
                    const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                    _buildMenuItem(context, Icons.local_offer_outlined, 'Promo & Voucher',
                        onTap: () => _snack(context, 'Promo & Voucher segera hadir!')),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Keluar ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogout(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 18),
                  label: Text('Keluar',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.errorRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorRed),
                    foregroundColor: AppColors.errorRed,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.75))),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().logout();
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
