import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _iconFromString(String? iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle_outline_rounded;
      case 'local_offer':
        return Icons.local_offer_outlined;
      case 'star':
        return Icons.star_outline_rounded;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorFromIcon(String? iconName) {
    switch (iconName) {
      case 'check_circle':
        return AppColors.escrowGreen;
      case 'local_offer':
        return const Color(0xFF7C3AED);
      case 'star':
        return AppColors.starYellow;
      case 'chat':
        return AppColors.accentBlue;
      default:
        return AppColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().userId;
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getNotificationsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.accentBlue),
            );
          }

          final notifs = snapshot.data ?? [];

          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Belum ada notifikasi',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Notifikasi pesanan dan promo akan muncul di sini',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final notif = notifs[index];
              final isRead = notif['isRead'] as bool? ?? true;
              final iconName = notif['icon'] as String?;

              return InkWell(
                onTap: () async {
                  if (!isRead) {
                    await service.markNotificationRead(notif['id']);
                  }
                },
                child: Container(
                  color: isRead ? null : AppColors.lightBlue.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              _colorFromIcon(iconName).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconFromString(iconName),
                          color: _colorFromIcon(iconName),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['title'] ?? '',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['body'] ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
