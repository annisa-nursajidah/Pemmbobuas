import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _fb = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().userId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _fb.getOrdersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
          }
          final orders = snapshot.data ?? [];
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(orders.where((o) => o.status == 'pending' || o.status == 'proses').toList(), 'aktif'),
              _buildList(orders.where((o) => o.status == 'selesai').toList(), 'selesai'),
              _buildList(orders.where((o) => o.status == 'batal').toList(), 'batal'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders, String type) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              type == 'aktif' ? 'Belum ada pesanan aktif'
                  : type == 'selesai' ? 'Belum ada pesanan selesai'
                  : 'Belum ada pesanan dibatalkan',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColor = _statusColor(order.status);
    final statusLabel = _statusLabel(order.status);

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
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_repair_service_rounded,
                      color: AppColors.accentBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.serviceTitle,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(order.mitraName,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Detail
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(order.address,
                          style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text('Rp ${_formatPrice(order.totalPrice)}',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentBlue)),
                  ],
                ),

                // Tombol aksi untuk pelanggan
                if (order.status == 'proses') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _konfirmasiSelesai(order),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Konfirmasi Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.escrowGreen,
                        minimumSize: const Size(0, 42),
                      ),
                    ),
                  ),
                ],

                // Tombol beri ulasan untuk order selesai
                if (order.status == 'selesai') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showUlasanForm(order),
                      icon: const Icon(Icons.star_outline_rounded, size: 18, color: Color(0xFFF59E0B)),
                      label: Text('Beri Ulasan',
                          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFF59E0B))),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        minimumSize: const Size(0, 42),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiSelesai(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Selesai'),
        content: const Text('Apakah pesanan sudah selesai dikerjakan oleh mitra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Belum')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _fb.updateOrderStatus(order.id!, 'selesai');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Pesanan dikonfirmasi selesai! Jangan lupa beri ulasan 🌟'),
                    backgroundColor: AppColors.escrowGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                // Langsung buka form ulasan
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) _showUlasanForm(order);
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.escrowGreen),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }

  void _showUlasanForm(OrderModel order) {
    double rating = 5.0;
    final commentCtrl = TextEditingController();
    final user = context.read<UserProvider>().currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Beri Ulasan', style: AppTextStyles.titleLarge),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 4),
              Text(order.serviceTitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Bintang rating
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModal(() => rating = (i + 1).toDouble()),
                      child: Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 40,
                      ),
                    );
                  }),
                ),
              ),
              Center(
                child: Text(
                  rating == 5 ? 'Sangat Puas!' : rating == 4 ? 'Puas' : rating == 3 ? 'Cukup' : rating == 2 ? 'Kurang' : 'Buruk',
                  style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFFF59E0B)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ceritakan pengalamanmu dengan mitra ini...',
                  prefixIcon: Icon(Icons.comment_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _fb.addReview(
                      mitraName: order.mitraName,
                      orderId: order.id ?? '',
                      userId: user?.id ?? '',
                      customerName: user?.name ?? '',
                      rating: rating,
                      comment: commentCtrl.text.trim(),
                      serviceTitle: order.serviceTitle,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Ulasan berhasil dikirim! Terima kasih 🙏'),
                          backgroundColor: AppColors.escrowGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('Kirim Ulasan'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'selesai': return AppColors.escrowGreen;
      case 'batal': return AppColors.errorRed;
      case 'proses': return const Color(0xFF3B82F6);
      default: return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'selesai': return 'Selesai';
      case 'batal': return 'Dibatalkan';
      case 'proses': return 'Diproses';
      default: return 'Menunggu';
    }
  }

  String _formatPrice(double p) => p.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
