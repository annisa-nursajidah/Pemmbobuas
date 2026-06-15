import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
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
  final FirebaseService _firebaseService = FirebaseService();

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
          labelStyle: AppTextStyles.bodySmall
              .copyWith(fontWeight: FontWeight.w600, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: _firebaseService.getOrdersStream('Ahmad'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accentBlue));
            }

            final orders = snapshot.data ?? [];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                    orders.where((o) => o.status == 'pending').toList(),
                    'Belum ada pesanan aktif'),
                _buildOrderList(
                    orders.where((o) => o.status == 'selesai').toList(),
                    'Belum ada pesanan selesai'),
                _buildOrderList(
                    orders.where((o) => o.status == 'batal').toList(),
                    'Belum ada pesanan dibatalkan'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMsg) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(emptyMsg,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Cari layanan dan buat pesanan pertama Anda!',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_repair_service_rounded,
                  color: AppColors.accentBlue),
            ),
            title: Text(order.serviceTitle, style: AppTextStyles.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(order.customerName, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Text(
              'Rp ${_formatPrice(order.totalPrice)}',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.accentBlue),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return AppColors.escrowGreen;
      case 'batal':
        return AppColors.errorRed;
      default:
        return AppColors.starYellow;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Dibatalkan';
      default:
        return 'Menunggu Konfirmasi';
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
