import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../main_scaffold.dart';

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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Akun berhasil dibuat! Selamat datang!'),
          backgroundColor: AppColors.escrowGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
          (route) => false,
        );
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
              const SizedBox(height: 32),

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
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Daftar Sekarang',
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
