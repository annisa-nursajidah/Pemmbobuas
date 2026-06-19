import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../auth/login_screen.dart';
import 'mitra_reviews_screen.dart';

class MitraProfileScreen extends StatelessWidget {
  const MitraProfileScreen({super.key});

  static const _mitraGreen = Color(0xFF10B981);
  static const _mitraGreenDark = Color(0xFF059669);

  final List<Map<String, dynamic>> _menuItems = const [
    {
      'icon': Icons.person_outline_rounded,
      'title': 'Edit Profil Mitra',
      'color': Color(0xFF3B82F6),
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'Rekening & Pencairan',
      'color': Color(0xFF10B981),
    },
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Laporan Pendapatan',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.reviews_outlined,
      'title': 'Ulasan Pelanggan',
      'color': Color(0xFFEC4899),
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Verifikasi & Dokumen',
      'color': Color(0xFF8B5CF6),
    },
    {
      'icon': Icons.headset_mic_outlined,
      'title': 'Bantuan & Dukungan',
      'color': Color(0xFF6B7280),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header hijau gradien ─────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_mitraGreen, _mitraGreenDark],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                child: Column(
                  children: [
                    // Avatar + info
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              backgroundImage:
                                  user?.avatarUrl.isNotEmpty == true
                                      ? NetworkImage(user!.avatarUrl)
                                      : null,
                              child: user?.avatarUrl.isNotEmpty != true
                                  ? const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 40)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _mitraGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.verified_rounded,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Mitra',
                                style: AppTextStyles.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.handyman_rounded,
                                            color: Colors.white, size: 11),
                                        const SizedBox(width: 4),
                                        Text('Mitra Terverifikasi',
                                            style: AppTextStyles.caption
                                                .copyWith(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (user?.keahlian.isNotEmpty == true)
                                Text(
                                  user!.keahlian,
                                  style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withOpacity(0.8)),
                                ),
                              if (user?.city.isNotEmpty == true)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: Colors.white70, size: 12),
                                    const SizedBox(width: 3),
                                    Text(
                                      user!.city,
                                      style: AppTextStyles.caption.copyWith(
                                          color: Colors.white.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.settings_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('4.9', 'Rating', Icons.star_rounded),
                          _buildDivider(),
                          _buildStatItem(
                              '38', 'Total Pesanan', Icons.receipt_rounded),
                          _buildDivider(),
                          _buildStatItem(
                              '2.1M', 'Pendapatan', Icons.payments_rounded),
                          _buildDivider(),
                          _buildStatItem('98%', 'Sukses', Icons.thumb_up_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Performance card ────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _mitraGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.trending_up_rounded,
                              color: _mitraGreen, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Performa Bulan Ini',
                            style: AppTextStyles.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildPerformanceBar('Tingkat Respons', 0.92, '92%', _mitraGreen),
                    const SizedBox(height: 10),
                    _buildPerformanceBar(
                        'Kepuasan Pelanggan', 0.96, '96%', const Color(0xFF3B82F6)),
                    const SizedBox(height: 10),
                    _buildPerformanceBar(
                        'Pesanan Selesai', 0.88, '88%', const Color(0xFFF59E0B)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Menu items ───────────────────────────────────
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
                              color: (item['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData,
                                color: item['color'] as Color, size: 20),
                          ),
                          title: Text(item['title'],
                              style: AppTextStyles.titleMedium),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: AppColors.textHint),
                          onTap: () {
                            if (item['title'] == 'Ulasan Pelanggan') {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const MitraReviewsScreen()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item["title"]} segera hadir!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
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

              // ── Keluar ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.errorRed, size: 18),
                  label: Text(
                    'Keluar dari Akun Mitra',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.errorRed),
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

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: Colors.white.withOpacity(0.75)),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 36, width: 1, color: Colors.white24);
  }

  Widget _buildPerformanceBar(
      String label, double value, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(percent,
                style: AppTextStyles.bodySmall
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content:
            const Text('Apakah Anda yakin ingin keluar dari akun Mitra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
