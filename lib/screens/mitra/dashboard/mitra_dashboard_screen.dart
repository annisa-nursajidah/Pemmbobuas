import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/order_model.dart';
import '../../../services/firebase_service.dart';
import '../orders/mitra_order_detail_screen.dart';

class MitraDashboardScreen extends StatefulWidget {
  const MitraDashboardScreen({super.key});

  @override
  State<MitraDashboardScreen> createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State<MitraDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isOnline = true;

  static const _mitraGreen = Color(0xFF10B981);
  static const _mitraGreenDark = Color(0xFF059669);

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}Jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}Rb';
    }
    return price.toStringAsFixed(0);
  }

  String _formatPriceFull(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final mitraName = user?.name ?? '';

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: _firebaseService.getMitraOrdersStream(mitraName),
          builder: (context, snapshot) {
            final orders = snapshot.data ?? [];

            // Hitung statistik dari data real
            final totalPesanan = orders.length;
            final pesananBaru =
                orders.where((o) => o.status == 'pending').length;
            final pesananSelesai =
                orders.where((o) => o.status == 'selesai').length;
            final pesananBatal =
                orders.where((o) => o.status == 'batal').length;
            final totalPendapatan = orders
                .where((o) => o.status == 'selesai')
                .fold(0.0, (sum, o) => sum + o.totalPrice);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header hijau ─────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_mitraGreen, _mitraGreenDark],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, Mitra! 👋',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.8)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.name ?? 'Mitra',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            // Online toggle
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isOnline = !_isOnline),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isOnline
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isOnline
                                            ? _mitraGreen
                                            : Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isOnline ? 'Online' : 'Offline',
                                      style: AppTextStyles.caption.copyWith(
                                        color: _isOnline
                                            ? _mitraGreen
                                            : Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.build_circle_outlined,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user?.keahlian.isNotEmpty == true
                                  ? user!.keahlian
                                  : 'Penyedia Jasa',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withOpacity(0.75)),
                            ),
                            if (user?.city.isNotEmpty == true) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                user!.city,
                                style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.75)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stat cards dari data real
                        Row(
                          children: [
                            _buildStatCard(
                              totalPesanan.toString(),
                              'Total Pesanan',
                              Icons.receipt_rounded,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              pesananBaru.toString(),
                              'Pesanan Baru',
                              Icons.fiber_new_rounded,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              'Rp ${_formatPrice(totalPendapatan)}',
                              'Pendapatan',
                              Icons.account_balance_wallet_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Ringkasan status ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ringkasan Pesanan',
                        style: AppTextStyles.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Baru',
                                pesananBaru.toString(),
                                Icons.fiber_new_rounded,
                                const Color(0xFF3B82F6))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSummaryCard(
                                'Selesai',
                                pesananSelesai.toString(),
                                Icons.check_circle_rounded,
                                _mitraGreen)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildSummaryCard(
                                'Dibatalkan',
                                pesananBatal.toString(),
                                Icons.cancel_rounded,
                                AppColors.errorRed)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Pesanan masuk terbaru ─────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pesanan Masuk Terbaru',
                            style: AppTextStyles.titleLarge),
                        if (orders.isNotEmpty)
                          Text(
                            '${orders.length} pesanan',
                            style: AppTextStyles.caption
                                .copyWith(color: _mitraGreen),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child:
                            CircularProgressIndicator(color: _mitraGreen),
                      ),
                    )
                  else if (orders.isEmpty)
                    _buildEmptyOrders()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: orders.take(5).length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MitraOrderDetailScreen(
                                order: orders[index]),
                          ),
                        ),
                        child: _buildOrderCard(orders[index]),
                      ),
                    ),

                  // ── Total pendapatan card ─────────────────────
                  if (orders.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_mitraGreen, _mitraGreenDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.payments_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Pendapatan',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white.withOpacity(0.8))),
                                  Text(
                                    'Rp ${_formatPriceFull(totalPendapatan)}',
                                    style: AppTextStyles.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Selesai',
                                    style: AppTextStyles.caption.copyWith(
                                        color: Colors.white.withOpacity(0.7))),
                                Text('$pesananSelesai pesanan',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withOpacity(0.75)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.headlineMedium.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _mitraGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.home_repair_service_rounded,
                color: _mitraGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.serviceTitle,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(order.customerName,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(order.address,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatPriceFull(order.totalPrice)}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: _mitraGreen, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'selesai':
        color = _mitraGreen;
        label = 'Selesai';
        break;
      case 'batal':
        color = AppColors.errorRed;
        label = 'Batal';
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'Baru';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('Belum ada pesanan masuk',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('Pesanan dari pelanggan akan muncul di sini',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
