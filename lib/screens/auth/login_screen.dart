import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../main_scaffold.dart';
import '../mitra/mitra_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _firebaseService.getUserByPhone(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Nomor telepon atau password salah. Periksa kembali atau daftar akun baru.';
        });
        return;
      }

      // Set session user
      context.read<UserProvider>().setUser(user);

      // Seed data demo untuk user ini
      await _firebaseService.seedNotifications(user.id);
      await _firebaseService.seedChats(user.id);
      // Seed akun mitra demo jika belum ada
      await _firebaseService.seedMitraUser();

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Redirect berdasarkan role
      final destination = user.isMitra
          ? const MitraScaffold()
          : const MainScaffold();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Sobat Beres',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text('Masuk ke Akun Anda',
                  style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Masukkan nomor telepon dan password untuk melanjutkan',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nomor Telepon
                    Text('Nomor Telepon',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // +62 prefix
                        Container(
                          height: 52,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          alignment: Alignment.center,
                          child: Text('+62',
                              style: AppTextStyles.titleMedium),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: '812-3456-7890',
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Nomor telepon wajib diisi';
                              }
                              if (val.length < 9) {
                                return 'Nomor minimal 9 digit';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                                return 'Hanya angka yang diperbolehkan';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Password
                    Text('Password', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
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
                        if (val.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
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
                    ],

                    const SizedBox(height: 24),

                    // Tombol Masuk
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Masuk',
                              style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Divider
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'belum punya akun?',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 20),

              // Register link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Daftar Sekarang',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
