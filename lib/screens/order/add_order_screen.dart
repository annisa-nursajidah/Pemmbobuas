import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../models/service_model.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';

class AddOrderScreen extends StatefulWidget {
  final ServiceModel service;
  final ServicePackage? selectedPackage;

  const AddOrderScreen({
    super.key,
    required this.service,
    this.selectedPackage,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill nama & nomor dari data user yang login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = '0${user.phone}';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final userId = context.read<UserProvider>().userId;
      final harga = widget.selectedPackage?.price ?? widget.service.price;
      final order = OrderModel(
        userId: userId,
        serviceId: widget.service.id,
        serviceTitle: widget.selectedPackage != null
            ? '${widget.service.title} - ${widget.selectedPackage!.name}'
            : widget.service.title,
        mitraName: widget.service.mitraName, // ← simpan nama mitra
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        status: 'pending',
        totalPrice: harga,
      );
      await _firebaseService.addOrder(order);
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pesanan berhasil dikirim! Mitra akan segera menghubungi Anda.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.escrowGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesanan: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          s.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColors.lightBlue,
                            child: const Icon(Icons.home_repair_service_rounded,
                                color: AppColors.accentBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.mitraName,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${_formatPrice(s.price)}',
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.accentBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Data Pemesan', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nama
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap Anda',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        if (val.trim().length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nomor HP
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        if (val.length < 10) {
                          return 'Nomor telepon minimal 10 digit';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                          return 'Hanya boleh angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Alamat
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Jl. nama jalan, No. xx, Kelurahan, Kota',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        if (val.trim().length < 10) {
                          return 'Alamat terlalu singkat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catatan
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
                        hintText:
                            'Contoh: 2 unit AC, lantai 2, pakai tangga...',
                        prefixIcon: Icon(Icons.notes_rounded),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.skyBlue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran',
                              style: AppTextStyles.titleMedium),
                          Text(
                            'Rp ${_formatPrice(widget.selectedPackage?.price ?? s.price)}',
                            style: AppTextStyles.titleLarge
                                .copyWith(color: AppColors.accentBlue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Kirim Pesanan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
