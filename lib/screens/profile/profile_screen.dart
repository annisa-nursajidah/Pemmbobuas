import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<Map<String, dynamic>> _menuItems = const [
    {'icon': Icons.person_outline_rounded, 'title': 'Edit Profil'},
    {'icon': Icons.location_on_outlined, 'title': 'Alamat Saya'},
    {'icon': Icons.credit_card_outlined, 'title': 'Metode Pembayaran'},
    {'icon': Icons.receipt_long_outlined, 'title': 'Riwayat Transaksi'},
    {'icon': Icons.local_offer_outlined, 'title': 'Promo & Voucher'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header biru
              Container(
                width: double.infinity,
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // Avatar + info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              AppColors.white.withOpacity(0.3),
                          backgroundImage: const NetworkImage(
                            'https://i.pravatar.cc/150?img=3',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ahmad Santoso',
                                style: AppTextStyles.headlineMedium
                                    .copyWith(color: AppColors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+62 812-3456-7890',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.white.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Member sejak Mei 2024',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.white.withOpacity(0.65)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.settings_outlined,
                              color: AppColors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        _buildStatCard('24', 'Total\nPesanan'),
                        const SizedBox(width: 10),
                        _buildStatCard('4.8', 'Rating\nDiberikan'),
                        const SizedBox(width: 10),
                        _buildStatCard('2.4M', 'Total\nBelanja'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menu items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: _menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'],
                                color: AppColors.textSecondary, size: 20),
                          ),
                          title: Text(item['title'],
                              style: AppTextStyles.titleMedium),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: AppColors.textHint),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${item["title"]} segera hadir!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        if (index < _menuItems.length - 1)
                          const Divider(
                              height: 1,
                              color: AppColors.divider,
                              indent: 16,
                              endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Jadi Mitra
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: AppColors.white, size: 22),
                  ),
                  title: Text(
                    'Jadi Mitra',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.accentBlue),
                  ),
                  subtitle: Text('Bergabung dan dapatkan penghasilan lebih',
                      style: AppTextStyles.caption),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: AppColors.accentBlue),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fitur Jadi Mitra segera hadir!')),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Keluar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Keluar'),
                        content: const Text(
                            'Apakah Anda yakin ingin keluar dari akun?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.errorRed),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.errorRed, size: 18),
                  label: Text(
                    'Keluar',
                    style:
                        AppTextStyles.titleMedium.copyWith(color: AppColors.errorRed),
                  ),
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
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withOpacity(0.75)),
            ),
          ],
        ),
      ),
    );
  }
}
