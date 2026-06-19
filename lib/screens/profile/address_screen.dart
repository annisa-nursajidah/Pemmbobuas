import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().userId;
    final fb = FirebaseService();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(title: const Text('Alamat Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context, fb, userId),
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah Alamat',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fb.getAddressesStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
          }
          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 72, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Belum ada alamat', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Tambahkan alamat untuk mempercepat pemesanan',
                      style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: addresses.length,
            itemBuilder: (context, i) {
              final addr = addresses[i];
              final isDefault = addr['isDefault'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDefault ? AppColors.accentBlue : AppColors.cardBorder,
                    width: isDefault ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDefault ? AppColors.lightBlue : AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      addr['label'] == 'Rumah'
                          ? Icons.home_rounded
                          : addr['label'] == 'Kantor'
                              ? Icons.business_rounded
                              : Icons.location_on_rounded,
                      color: isDefault ? AppColors.accentBlue : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(addr['label'] ?? 'Alamat',
                          style: AppTextStyles.titleMedium),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Utama',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(addr['name'] ?? '', style: AppTextStyles.bodySmall),
                      Text(addr['address'] ?? '', style: AppTextStyles.caption, maxLines: 2),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                    onSelected: (val) async {
                      if (val == 'edit') {
                        _showAddressForm(context, fb, userId, existing: addr);
                      } else if (val == 'delete') {
                        await fb.deleteAddress(userId, addr['id']);
                      } else if (val == 'default') {
                        await fb.updateAddress(userId, addr['id'], {'isDefault': true});
                      }
                    },
                    itemBuilder: (_) => [
                      if (!isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Jadikan Utama')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
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

  void _showAddressForm(BuildContext context, FirebaseService fb, String userId,
      {Map<String, dynamic>? existing}) {
    final labelCtrl = TextEditingController(text: existing?['label'] ?? '');
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final addressCtrl = TextEditingController(text: existing?['address'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final formKey = GlobalKey<FormState>();
    String selectedLabel = existing?['label'] ?? 'Rumah';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModalState) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(existing != null ? 'Edit Alamat' : 'Tambah Alamat',
                        style: AppTextStyles.titleLarge),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Label
                Row(
                  children: ['Rumah', 'Kantor', 'Lainnya'].map((label) {
                    final isSelected = selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setModalState(() => selectedLabel = label);
                          labelCtrl.text = label;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.lightBlue : AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? AppColors.accentBlue : AppColors.divider),
                          ),
                          child: Text(label,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama Penerima',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    hintText: 'Jl. nama jalan, No. xx, Kecamatan, Kota',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final data = {
                        'label': selectedLabel,
                        'name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'address': addressCtrl.text.trim(),
                        'isDefault': existing?['isDefault'] ?? false,
                      };
                      if (existing != null) {
                        await fb.updateAddress(userId, existing['id'], data);
                      } else {
                        await fb.addAddress(userId, data);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(existing != null ? 'Simpan Perubahan' : 'Simpan Alamat'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
