import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  final FirebaseService _fb = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<UserProvider>();
    final user = provider.currentUser!;
    try {
      await _fb.updateUserProfile(user.id, {'name': _nameCtrl.text.trim()});
      // Update lokal provider
      final updated = UserModel(
        id: user.id,
        name: _nameCtrl.text.trim(),
        phone: user.phone,
        password: user.password,
        avatarUrl: user.avatarUrl,
        memberSince: user.memberSince,
        role: user.role,
        keahlian: user.keahlian,
        city: user.city,
      );
      provider.setUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.escrowGreen,
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
    final user = context.watch<UserProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Edit Profil'),
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.lightBlue,
                      backgroundImage: user?.avatarUrl.isNotEmpty == true
                          ? NetworkImage(user!.avatarUrl) : null,
                      child: user?.avatarUrl.isNotEmpty != true
                          ? const Icon(Icons.person_rounded,
                              color: AppColors.accentBlue, size: 48)
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Nama
              _buildCard(children: [
                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap Anda',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                    if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 12),

              // Nomor HP (read only)
              _buildCard(children: [
                _buildLabel('Nomor Telepon'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, color: AppColors.textHint, size: 20),
                      const SizedBox(width: 12),
                      Text(user?.formattedPhone ?? '-',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      const Spacer(),
                      const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('  Nomor telepon tidak dapat diubah',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: AppTextStyles.titleMedium);
}
