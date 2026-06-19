import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';

// ── Halaman daftar percakapan ────────────────────────────────
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().userId;
    final fb = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fb.getChatsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
          }
          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Belum ada percakapan',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Chat dengan mitra akan muncul di sini',
                      style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, i) {
              final chat = chats[i];
              final unread = (chat['unread'] as int?) ?? 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.lightBlue,
                  backgroundImage: (chat['mitraAvatar'] ?? '').toString().isNotEmpty
                      ? NetworkImage(chat['mitraAvatar']) : null,
                  child: (chat['mitraAvatar'] ?? '').toString().isEmpty
                      ? const Icon(Icons.person_rounded, color: AppColors.accentBlue) : null,
                ),
                title: Text(chat['mitraName'] ?? 'Mitra', style: AppTextStyles.titleMedium),
                subtitle: Text(
                  chat['lastMsg'] ?? '',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: unread > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                        child: Text(unread.toString(),
                            style: AppTextStyles.caption.copyWith(color: Colors.white)),
                      )
                    : null,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatDetailPage(chat: chat))),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Halaman detail chat dengan pesan real Firestore ──────────
class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> chat;
  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _fb = FirebaseService();
  bool _isSending = false;

  late String _chatId;
  late String _userId;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chat['id'] as String;
    final provider = context.read<UserProvider>();
    _userId = provider.userId;
    _userName = provider.currentUser?.name ?? 'Pengguna';
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    _msgController.clear();
    setState(() => _isSending = true);

    try {
      await _fb.sendMessage(
        chatId: _chatId,
        senderId: _userId,
        senderName: _userName,
        isFromUser: true,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim pesan: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.lightBlue,
              backgroundImage: (widget.chat['mitraAvatar'] ?? '').toString().isNotEmpty
                  ? NetworkImage(widget.chat['mitraAvatar']) : null,
              child: (widget.chat['mitraAvatar'] ?? '').toString().isEmpty
                  ? const Icon(Icons.person_rounded, color: AppColors.accentBlue, size: 18) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chat['mitraName'] ?? 'Mitra',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.white)),
                Text('Mitra Sobat Beres',
                    style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Daftar pesan real-time ────────────────────────
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fb.getMessagesStream(_chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.waving_hand_rounded, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text('Mulai percakapan dengan ${widget.chat['mitraName']}',
                            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                // Auto scroll saat ada pesan baru
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg['isFromUser'] == true;
                    return _buildBubble(msg['text'] ?? '', isMe);
                  },
                );
              },
            ),
          ),

          // ── Input bar ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: AppTextStyles.bodyMedium,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _isSending ? AppColors.textHint : AppColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accentBlue : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMe ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
