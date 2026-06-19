import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../main_scaffold.dart';
import '../mitra/mitra_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keahlianController = TextEditingController();
  final _cityController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _selectedRole = 'pelanggan'; // 'pelanggan' atau 'mitra'

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _keahlianController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _phoneController.text.trim();

      // Cek apakah nomor sudah terdaftar
      final isRegistered = await _firebaseService.isPhoneRegistered(phone);
      if (!mounted) return;

      if (isRegistered) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Nomor telepon ini sudah terdaftar. Silakan masuk dengan akun Anda.';
        });
        return;
      }

      // Buat akun baru di Firestore
      final user = await _firebaseService.createUser(
        name: _nameController.text.trim(),
        phone: phone,
        password: _passwordController.text.trim(),
        role: _selectedRole,
        keahlian: _keahlianController.text.trim(),
        city: _cityController.text.trim(),
      );

      if (!mounted) return;

      // Set session user
      context.read<UserProvider>().setUser(user);

      // Seed data demo untuk user baru
      await _firebaseService.seedNotifications(user.id);
      await _firebaseService.seedChats(user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedRole == 'mitra'
              ? 'Akun Mitra berhasil dibuat! Selamat bergabung!'
              : 'Akun berhasil dibuat! Selamat datang!'),
          backgroundColor: AppColors.escrowGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        // Redirect berdasarkan role
        final destination = user.isMitra
            ? const MitraScaffold()
            : const MainScaffold();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan. Periksa koneksi internet Anda.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Buat Akun Baru', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Daftar sekarang dan temukan jasa terbaik di sekitar Anda',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ── PILIHAN ROLE ─────────────────────────────────
              _buildLabel('Daftar Sebagai'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.person_rounded,
                      label: 'Pelanggan',
                      subtitle: 'Cari & pesan jasa',
                      isSelected: _selectedRole == 'pelanggan',
                      color: AppColors.accentBlue,
                      onTap: () => setState(() => _selectedRole = 'pelanggan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.handyman_rounded,
                      label: 'Mitra',
                      subtitle: 'Tawarkan jasamu',
                      isSelected: _selectedRole == 'mitra',
                      color: const Color(0xFF10B981),
                      onTap: () => setState(() => _selectedRole = 'mitra'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama lengkap Anda',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: AppColors.textHint),
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
                    const SizedBox(height: 20),

                    // Nomor HP
                    _buildLabel('Nomor Telepon'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: AppColors.textHint),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        if (val.length < 10) {
                          return 'Nomor telepon minimal 10 digit';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                          return 'Nomor telepon hanya berisi angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textHint),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (val.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Field tambahan jika Mitra ─────────────
                    if (_selectedRole == 'mitra') ...[
                      _buildLabel('Keahlian / Jenis Jasa'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _keahlianController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Service AC, Listrik, Laundry...',
                          prefixIcon: Icon(Icons.build_outlined,
                              color: AppColors.textHint),
                        ),
                        validator: (val) {
                          if (_selectedRole == 'mitra' &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Keahlian wajib diisi untuk Mitra';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Kota / Wilayah Kerja'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Surabaya, Jakarta...',
                          prefixIcon: Icon(Icons.location_on_outlined,
                              color: AppColors.textHint),
                        ),
                        validator: (val) {
                          if (_selectedRole == 'mitra' &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Kota wajib diisi untuk Mitra';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.errorRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.errorRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == 'mitra'
                            ? const Color(0xFF10B981)
                            : AppColors.accentBlue,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _selectedRole == 'mitra'
                                  ? 'Daftar Sebagai Mitra'
                                  : 'Daftar Sekarang',
                              style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Dengan mendaftar, Anda menyetujui Syarat & Ketentuan Sobat Beres',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.titleMedium);
  }
}

/// Widget kartu pilihan role
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.textHint.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : AppColors.textHint,
                  size: 24),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? color : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTextStyles.caption.copyWith(
                    color:
                        isSelected ? color.withOpacity(0.7) : AppColors.textHint),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
