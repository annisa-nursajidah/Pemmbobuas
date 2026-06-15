import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  final List<Map<String, dynamic>> _chats = const [
    {
      'name': 'Toni Raharjo',
      'lastMsg': 'Baik pak, saya akan datang jam 10 pagi',
      'time': '10:30',
      'unread': 1,
      'avatar': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Siti Aminah',
      'lastMsg': 'Terima kasih sudah menggunakan jasa kami!',
      'time': 'Kemarin',
      'unread': 0,
      'avatar': 'https://i.pravatar.cc/150?img=21',
    },
    {
      'name': 'Ahmad Fauzi',
      'lastMsg': 'CCTV sudah terpasang dengan baik 🎉',
      'time': 'Senin',
      'unread': 0,
      'avatar': 'https://i.pravatar.cc/150?img=15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _chats.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 80, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('Belum ada percakapan',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _chats.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(chat['avatar']),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(chat['name'],
                            style: AppTextStyles.titleMedium),
                        Text(
                          chat['time'],
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat['lastMsg'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        if ((chat['unread'] as int) > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat['unread'].toString(),
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur chat segera hadir!'),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
