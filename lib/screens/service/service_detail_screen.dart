import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/service_model.dart';
import '../order/add_order_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;
  int _selectedPackageIndex = 0; // paket yang dipilih

  ServicePackage? get _selectedPackage {
    final pkgs = widget.service.packages;
    if (pkgs.isEmpty) return null;
    return pkgs[_selectedPackageIndex];
  }

  double get _selectedPrice =>
      _selectedPackage?.price ?? widget.service.price;

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  void _openChatWithMitra() {
    // Buat data chat sementara untuk mitra ini
    final chatData = {
      'mitraName': widget.service.mitraName,
      'mitraAvatar': widget.service.mitraAvatarUrl,
      'lastMsg': 'Halo, saya tertarik dengan layanan ${widget.service.title}',
      'unread': 0,
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatDetailPage(chat: chatData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image + AppBar
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.primaryBlue,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isFavorite
                            ? AppColors.errorRed
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    s.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.lightBlue,
                      child: const Icon(
                        Icons.home_repair_service_rounded,
                        size: 80,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Row(
                        children: [
                          _buildTag(s.category, AppColors.lightBlue,
                              AppColors.accentBlue),
                          const SizedBox(width: 8),
                          if (s.isEscrow)
                            _buildTag(
                              '🔒 Escrow Protection',
                              const Color(0xFFDCFCE7),
                              AppColors.escrowGreen,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(s.title, style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 16),

                      // Mitra Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.lightBlue,
                              backgroundImage: s.mitraAvatarUrl.isNotEmpty
                                  ? NetworkImage(s.mitraAvatarUrl)
                                  : null,
                              child: s.mitraAvatarUrl.isEmpty
                                  ? const Icon(Icons.person_rounded,
                                      color: AppColors.accentBlue)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(s.mitraName,
                                          style: AppTextStyles.titleMedium),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.accentBlue,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: AppColors.starYellow,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        s.mitraRating.toStringAsFixed(1),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('•',
                                          style: AppTextStyles.bodySmall),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${s.totalOrders} pesanan',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const SizedBox(width: 6),
                                      Text('•',
                                          style: AppTextStyles.bodySmall),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Respon ${s.responseTime}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Tombol Chat Mitra (berfungsi) ──────────────────
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _openChatWithMitra,
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text('Chat Mitra',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.accentBlue)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text('Deskripsi Layanan',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),
                      Text(s.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.6)),
                      const SizedBox(height: 20),

                      // ── Paket Layanan (bisa dipilih) ───────────────────
                      if (s.packages.isNotEmpty) ...[
                        Text('Paket Layanan',
                            style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 12),
                        ...s.packages.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final pkg = entry.value;
                          final isSelected = _selectedPackageIndex == idx;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPackageIndex = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.lightBlue
                                    : AppColors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Radio indicator
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accentBlue
                                            : AppColors.divider,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppColors.accentBlue
                                          : AppColors.white,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check_rounded,
                                            size: 12,
                                            color: AppColors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(pkg.name,
                                            style: AppTextStyles.titleMedium
                                                .copyWith(
                                              color: isSelected
                                                  ? AppColors.accentBlue
                                                  : AppColors.textPrimary,
                                            )),
                                        const SizedBox(height: 2),
                                        Text(pkg.description,
                                            style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatPrice(pkg.price)}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.accentBlue
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],

                      // Info tambahan
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(s.city, style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Bar sticky (harga update sesuai paket dipilih) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPackage != null
                            ? _selectedPackage!.name
                            : 'Mulai dari',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Rp ${_formatPrice(_selectedPrice)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddOrderScreen(
                            service: s,
                            selectedPackage: _selectedPackage,
                          ),
                        ),
                      ),
                      child: const Text('Pesan Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Halaman chat dengan mitra dari service detail ────────────────
class _ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> chat;
  const _ChatDetailPage({required this.chat});

  @override
  State<_ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<_ChatDetailPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {'text': widget.chat['lastMsg'] ?? 'Halo!', 'isMe': true},
      {
        'text':
            'Halo! Terima kasih sudah menghubungi kami. Ada yang bisa saya bantu?',
        'isMe': false
      },
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true});
      _msgController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightBlue,
              backgroundImage:
                  (widget.chat['mitraAvatar'] as String?)?.isNotEmpty == true
                      ? NetworkImage(widget.chat['mitraAvatar'])
                      : null,
              child: (widget.chat['mitraAvatar'] as String?)?.isNotEmpty != true
                  ? const Icon(Icons.person_rounded,
                      color: AppColors.accentBlue, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chat['mitraName'] ?? 'Mitra',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.white)),
                Text('Online',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withOpacity(0.75))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.accentBlue
                          : AppColors.surfaceGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      msg['text'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isMe ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      filled: true,
                      fillColor: AppColors.surfaceGrey,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
