import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String avatarUrl;
  final Timestamp? memberSince;
  final String role; // 'pelanggan' atau 'mitra'
  final String keahlian; // khusus mitra
  final String city; // khusus mitra

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    this.avatarUrl = '',
    this.memberSince,
    this.role = 'pelanggan',
    this.keahlian = '',
    this.city = '',
  });

  bool get isMitra => role == 'mitra';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      memberSince: data['memberSince'] as Timestamp?,
      role: data['role'] ?? 'pelanggan',
      keahlian: data['keahlian'] ?? '',
      city: data['city'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'avatarUrl': avatarUrl,
      'memberSince': memberSince ?? FieldValue.serverTimestamp(),
      'role': role,
      'keahlian': keahlian,
      'city': city,
    };
  }

  /// Format nomor untuk display (contoh: +62 812-3456-7890)
  String get formattedPhone {
    final p = phone.startsWith('0') ? phone.substring(1) : phone;
    return '+62 $p';
  }

  /// Bulan + tahun bergabung
  String get memberSinceLabel {
    if (memberSince == null) return 'Member';
    final dt = memberSince!.toDate();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return 'Member sejak ${months[dt.month - 1]} ${dt.year}';
  }
}
