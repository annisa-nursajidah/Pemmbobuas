import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/order_model.dart';
import '../../../services/firebase_service.dart';
import 'mitra_order_detail_screen.dart';

class MitraOrdersScreen extends StatefulWidget {
  const MitraOrdersScreen({super.key});

  @override
  State<MitraOrdersScreen> createState() => _MitraOrdersScreenState();
}

class _MitraOrdersScreenState extends State<MitraOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();

  static const _mitraGreen = Color(0xFF10B981);

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
    final user = context.read<UserProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: _mitraGreen,
        foregroundColor: Colors.white,
        title: const Text('Pesanan Masuk'),
        titleTextStyle: AppTextStyles.titleLarge
            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.bodySmall
              .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Proses'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firebaseService.getMitraOrdersStream(user?.name ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _mitraGreen),
            );
          }

          final allOrders = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(
                allOrders.where((o) => o.status == 'pending').toList(),
                'Belum ada pesanan baru',
                Icons.inbox_outlined,
              ),
              _buildOrderList(
                allOrders.where((o) => o.status == 'proses').toList(),
                'Tidak ada pesanan dalam proses',
                Icons.pending_actions_outlined,
              ),
              _buildOrderList(
                allOrders.where((o) => o.status == 'selesai').toList(),
                'Belum ada pesanan selesai',
                Icons.check_circle_outline_rounded,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(
      List<OrderModel> orders, String emptyMsg, IconData emptyIcon) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(emptyMsg,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Pesanan dari pelanggan akan tampil di sini',
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MitraOrderDetailScreen(order: order),
            ),
          ),
          child: _buildOrderCard(order),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
          // Header kartu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _mitraGreen.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _mitraGreen.withOpacity(0.12),
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
                      Text(
                          'Rp ${_formatPrice(order.totalPrice)}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: _mitraGreen, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),

          // Detail pesanan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                    Icons.person_outline_rounded, 'Pelanggan', order.customerName),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.phone_outlined, 'Telepon', order.phone),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.location_on_outlined, 'Alamat', order.address),
                if (order.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      Icons.notes_rounded, 'Catatan', order.notes),
                ],
                const SizedBox(height: 14),

                // Tombol aksi
                if (order.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _tolakPesanan(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                            side: const BorderSide(color: AppColors.errorRed),
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _terimaPesanan(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mitraGreen,
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('Terima'),
                        ),
                      ),
                    ],
                  ),

                // Tombol selesai untuk pesanan yang sedang diproses
                if (order.status == 'proses')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _selesaikanPesanan(order),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Tandai Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mitraGreen,
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.bodySmall),
        ),
      ],
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
      case 'proses':
        color = const Color(0xFF3B82F6);
        label = 'Proses';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _terimaPesanan(OrderModel order) async {
    try {
      await _firebaseService.updateOrderStatus(order.id!, 'proses');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Pesanan berhasil diterima! Status berubah ke Proses.'),
            backgroundColor: _mitraGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  void _tolakPesanan(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Pesanan?'),
        content: Text(
          'Apakah Anda yakin ingin menolak pesanan "${order.serviceTitle}" dari ${order.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firebaseService.updateOrderStatus(order.id!, 'batal');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Pesanan ditolak.'),
                      backgroundColor: AppColors.errorRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'),
                        backgroundColor: AppColors.errorRed),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      ),
    );
  }

  void _selesaikanPesanan(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tandai Selesai?'),
        content: const Text('Konfirmasi bahwa pekerjaan telah selesai dikerjakan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firebaseService.updateOrderStatus(order.id!, 'selesai');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('🎉 Pesanan ditandai selesai!'),
                      backgroundColor: _mitraGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'),
                        backgroundColor: AppColors.errorRed),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _mitraGreen),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
