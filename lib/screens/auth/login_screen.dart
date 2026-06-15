import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../main_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
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
                'Masukkan nomor telepon untuk melanjutkan',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nomor Telepon',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // +62 prefix
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(height: 24),

                    // Tombol Lanjut
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
                          : Text('Lanjut',
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
                      'atau masuk dengan',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 20),

              // Google Button
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScaffold()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                  foregroundColor: AppColors.textPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google icon manual
                    _GoogleIcon(),
                    const SizedBox(width: 12),
                    Text('Google', style: AppTextStyles.titleMedium),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Register link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun?',
                        style: AppTextStyles.bodyMedium),
                    TextButton(
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

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.5, 1.7, true, bluePaint);
    // Red
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.8, 1.5, true, redPaint);
    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.1, 0.8, true, yellowPaint);
    // Green
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.2, 1.9, true, greenPaint);

    // White center
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
