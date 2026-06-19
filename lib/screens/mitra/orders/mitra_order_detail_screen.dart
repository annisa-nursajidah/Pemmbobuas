import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/order_model.dart';
import '../../../services/firebase_service.dart';

class MitraOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const MitraOrderDetailScreen({super.key, required this.order});

  @override
  State<MitraOrderDetailScreen> createState() => _MitraOrderDetailScreenState();
}

class _MitraOrderDetailScreenState extends State<MitraOrderDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late String _currentStatus;

  static const _mitraGreen = Color(0xFF10B981);
  static const _mitraGreenDark = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (widget.order.id == null) return;
    setState(() => _isLoading = true);
    try {
      await _firebaseService.updateOrderStatus(widget.order.id!, newStatus);
      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  newStatus == 'proses'
                      ? 'Pesanan diterima! Segera hubungi pelanggan.'
                      : newStatus == 'selesai'
                          ? 'Pesanan ditandai selesai!'
                          : 'Pesanan ditolak.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: newStatus == 'batal'
                ? AppColors.errorRed
                : _mitraGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _callCustomer() {
    Clipboard.setData(ClipboardData(text: widget.order.phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor ${widget.order.phone} disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: _mitraGreen,
        foregroundColor: Colors.white,
        title: const Text('Detail Pesanan'),
        titleTextStyle: AppTextStyles.titleLarge
            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        actions: [
          // Badge status di appbar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _buildStatusChip(_currentStatus, large: true)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Layanan ─────────────────────────────────
            _buildSection(
              icon: Icons.home_repair_service_rounded,
              title: 'Layanan Dipesan',
              iconColor: _mitraGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.serviceTitle,
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Harga',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      Text(
                        'Rp ${_formatPrice(order.totalPrice)}',
                        style: AppTextStyles.titleLarge
                            .copyWith(color: _mitraGreen, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Info Pelanggan ────────────────────────────────
            _buildSection(
              icon: Icons.person_rounded,
              title: 'Data Pelanggan',
              iconColor: const Color(0xFF3B82F6),
              child: Column(
                children: [
                  _buildRow(Icons.person_outline_rounded, 'Nama',
                      order.customerName),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildRow(Icons.phone_outlined, 'Telepon', order.phone,
                      action: GestureDetector(
                        onTap: _callCustomer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _mitraGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.copy_rounded,
                                  size: 12, color: _mitraGreen),
                              const SizedBox(width: 4),
                              Text('Salin',
                                  style: AppTextStyles.caption.copyWith(
                                      color: _mitraGreen,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildRow(
                      Icons.location_on_outlined, 'Alamat', order.address),
                  if (order.notes.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    _buildRow(Icons.notes_rounded, 'Catatan', order.notes),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Status Pesanan ────────────────────────────────
            _buildSection(
              icon: Icons.timeline_rounded,
              title: 'Status Pesanan',
              iconColor: const Color(0xFF8B5CF6),
              child: _buildStatusTimeline(),
            ),

            const SizedBox(height: 24),

            // ── Tombol Aksi ───────────────────────────────────
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: _mitraGreen))
            else
              _buildActionButtons(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
    required Color iconColor,
  }) {
    return Container(
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value,
      {Widget? action}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 10),
        SizedBox(
          width: 64,
          child: Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w500)),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildStatusTimeline() {
    final steps = [
      {'status': 'pending', 'label': 'Pesanan Masuk', 'icon': Icons.inbox_rounded},
      {'status': 'proses', 'label': 'Diterima Mitra', 'icon': Icons.handyman_rounded},
      {'status': 'selesai', 'label': 'Selesai', 'icon': Icons.check_circle_rounded},
    ];

    int activeIndex = 0;
    if (_currentStatus == 'proses') activeIndex = 1;
    if (_currentStatus == 'selesai') activeIndex = 2;
    if (_currentStatus == 'batal') activeIndex = -1;

    if (_currentStatus == 'batal') {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded,
                color: AppColors.errorRed, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Pesanan Dibatalkan',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.errorRed)),
        ],
      );
    }

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isDone = index <= activeIndex;
        final isActive = index == activeIndex;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone
                            ? _mitraGreen
                            : AppColors.surfaceGrey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? _mitraGreen : AppColors.divider,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 16,
                        color: isDone ? Colors.white : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step['label'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isDone ? _mitraGreen : AppColors.textHint,
                        fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  height: 2,
                  width: 20,
                  color: index < activeIndex ? _mitraGreen : AppColors.divider,
                  margin: const EdgeInsets.only(bottom: 24),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    if (_currentStatus == 'selesai' || _currentStatus == 'batal') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _currentStatus == 'selesai'
              ? _mitraGreen.withOpacity(0.08)
              : AppColors.errorRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _currentStatus == 'selesai'
                ? _mitraGreen.withOpacity(0.3)
                : AppColors.errorRed.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentStatus == 'selesai'
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: _currentStatus == 'selesai'
                  ? _mitraGreen
                  : AppColors.errorRed,
            ),
            const SizedBox(width: 8),
            Text(
              _currentStatus == 'selesai'
                  ? 'Pesanan telah selesai'
                  : 'Pesanan telah ditolak',
              style: AppTextStyles.titleMedium.copyWith(
                color: _currentStatus == 'selesai'
                    ? _mitraGreen
                    : AppColors.errorRed,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentStatus == 'pending') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(
                'Terima Pesanan',
                'Apakah Anda yakin ingin menerima pesanan ini?',
                'proses',
                _mitraGreen,
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Terima Pesanan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mitraGreen,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showConfirmDialog(
                'Tolak Pesanan',
                'Apakah Anda yakin ingin menolak pesanan ini?',
                'batal',
                AppColors.errorRed,
              ),
              icon: const Icon(Icons.close_rounded, color: AppColors.errorRed),
              label: const Text('Tolak Pesanan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      );
    }

    if (_currentStatus == 'proses') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showConfirmDialog(
            'Tandai Selesai',
            'Tandai pesanan ini sebagai selesai?',
            'selesai',
            _mitraGreen,
          ),
          icon: const Icon(Icons.done_all_rounded),
          label: const Text('Tandai Selesai'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _mitraGreenDark,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showConfirmDialog(
      String title, String content, String newStatus, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(content, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(title,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, {bool large = false}) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'selesai':
        color = _mitraGreen;
        label = 'Selesai';
        icon = Icons.check_circle_rounded;
        break;
      case 'proses':
        color = const Color(0xFF3B82F6);
        label = 'Diproses';
        icon = Icons.autorenew_rounded;
        break;
      case 'batal':
        color = AppColors.errorRed;
        label = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 10, vertical: large ? 6 : 4),
      decoration: BoxDecoration(
        color: large ? Colors.white.withOpacity(0.2) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: large ? Border.all(color: Colors.white38) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: large ? 14 : 12,
              color: large ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: large ? Colors.white : color,
                  fontWeight: FontWeight.w600)),
        ],
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
