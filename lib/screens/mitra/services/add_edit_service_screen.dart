import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/service_model.dart';
import '../../../services/firebase_service.dart';

class AddEditServiceScreen extends StatefulWidget {
  final ServiceModel? existingService; // null = tambah baru

  const AddEditServiceScreen({super.key, this.existingService});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fb = FirebaseService();
  bool _isLoading = false;

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _responseCtrl;
  String _selectedCategory = 'AC & Elektronik';
  String _selectedCity = 'Surabaya';

  static const _mitraGreen = Color(0xFF10B981);

  static const _categories = [
    'AC & Elektronik', 'Kebersihan', 'Perbaikan Rumah', 'Desain Interior',
    'Taman & Kebun', 'Keamanan', 'Listrik & Plumbing', 'Lainnya',
  ];

  static const _cities = [
    'Surabaya', 'Jakarta', 'Bandung', 'Yogyakarta', 'Medan',
    'Semarang', 'Malang', 'Makassar',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingService;
    _titleCtrl = TextEditingController(text: s?.title ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _priceCtrl = TextEditingController(text: s?.price.toStringAsFixed(0) ?? '');
    _responseCtrl = TextEditingController(text: s?.responseTime ?? '< 1 jam');
    if (s != null) {
      _selectedCategory = _categories.contains(s.category) ? s.category : _categories.first;
      _selectedCity = _cities.contains(s.city) ? s.city : _cities.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _responseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<UserProvider>().currentUser!;
    final data = {
      'title': _titleCtrl.text.trim(),
      'category': _selectedCategory,
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0.0,
      'responseTime': _responseCtrl.text.trim(),
      'city': _selectedCity,
      'mitraName': user.name,
      'mitraAvatarUrl': user.avatarUrl,
      'imageUrl': 'https://source.unsplash.com/400x300/?home,repair',
      'isEscrow': true,
      'packages': [],
    };

    try {
      if (widget.existingService != null) {
        await _fb.updateService(widget.existingService!.id, data);
      } else {
        await _fb.addService(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingService != null
                ? 'Layanan berhasil diperbarui!' : 'Layanan berhasil ditambahkan!'),
            backgroundColor: _mitraGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingService != null;
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: _mitraGreen,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Layanan' : 'Tambah Layanan'),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Simpan',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(title: 'Info Layanan', children: [
                _buildTextField(_titleCtrl, 'Nama Layanan',
                    hint: 'contoh: Service & Cuci AC Bergaransi',
                    icon: Icons.home_repair_service_rounded,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                const SizedBox(height: 14),
                _buildDropdown('Kategori', _selectedCategory, _categories,
                    Icons.category_outlined,
                    onChanged: (v) => setState(() => _selectedCategory = v!)),
                const SizedBox(height: 14),
                _buildTextField(_descCtrl, 'Deskripsi Layanan',
                    hint: 'Jelaskan layanan yang Anda tawarkan secara detail...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
              ]),

              const SizedBox(height: 12),

              _buildCard(title: 'Harga & Lokasi', children: [
                _buildTextField(_priceCtrl, 'Harga Mulai Dari (Rp)',
                    hint: 'contoh: 85000',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Wajib diisi';
                      if (double.tryParse(v!.replaceAll('.', '')) == null) return 'Harga tidak valid';
                      return null;
                    }),
                const SizedBox(height: 14),
                _buildDropdown('Kota Layanan', _selectedCity, _cities,
                    Icons.location_on_outlined,
                    onChanged: (v) => setState(() => _selectedCity = v!)),
                const SizedBox(height: 14),
                _buildTextField(_responseCtrl, 'Waktu Respons',
                    hint: 'contoh: < 1 jam',
                    icon: Icons.timer_outlined),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                  label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Layanan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mitraGreen,
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
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
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {String? hint, IconData? icon, int maxLines = 1,
       TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: maxLines > 1
          ? TextCapitalization.sentences : TextCapitalization.words,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      IconData icon, {required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
