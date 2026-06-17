import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── USERS ────────────────────────────────────────────────

  /// Login: cari user by nomor HP dan password
  Future<UserModel?> getUserByPhone(String phone, String password) async {
    // Normalisasi nomor: hilangkan awalan 0 (input dari UI tanpa +62)
    final normalized = phone.startsWith('0') ? phone.substring(1) : phone;
    final snap = await _db
        .collection('users')
        .where('phone', isEqualTo: normalized)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }

  /// Cek apakah nomor sudah terdaftar
  Future<bool> isPhoneRegistered(String phone) async {
    final normalized = phone.startsWith('0') ? phone.substring(1) : phone;
    final snap = await _db
        .collection('users')
        .where('phone', isEqualTo: normalized)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Daftarkan user baru ke Firestore
  Future<UserModel> createUser({
    required String name,
    required String phone,
    required String password,
  }) async {
    final normalized = phone.startsWith('0') ? phone.substring(1) : phone;
    final ref = _db.collection('users').doc();
    final data = {
      'name': name,
      'phone': normalized,
      'password': password,
      'avatarUrl': 'https://i.pravatar.cc/150?u=$normalized',
      'memberSince': FieldValue.serverTimestamp(),
    };
    await ref.set(data);
    // Re-fetch untuk dapat Timestamp yang sudah diisi server
    final doc = await ref.get();
    return UserModel.fromFirestore(doc);
  }

  /// Seed 1 user demo untuk testing
  Future<void> seedDemoUser() async {
    final existing = await _db
        .collection('users')
        .where('phone', isEqualTo: '81234567890')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    await _db.collection('users').add({
      'name': 'Ahmad Santoso',
      'phone': '81234567890',
      'password': 'password123',
      'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      'memberSince': FieldValue.serverTimestamp(),
    });
  }

  // ── NOTIFICATIONS ────────────────────────────────────────

  /// Stream notifikasi user
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Seed notifikasi demo untuk user
  Future<void> seedNotifications(String userId) async {
    final existing = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final notifs = [
      {
        'userId': userId,
        'title': 'Pesanan Dikonfirmasi',
        'body': 'Pesanan Service AC Anda telah dikonfirmasi oleh Toni Raharjo',
        'icon': 'check_circle',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': userId,
        'title': 'Promo Spesial!',
        'body': 'Diskon 20% untuk semua layanan kebersihan hari ini',
        'icon': 'local_offer',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': userId,
        'title': 'Pesanan Selesai',
        'body': 'Pesanan Bersih-Bersih Rumah telah selesai. Berikan ulasan!',
        'icon': 'star',
        'isRead': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];
    for (final n in notifs) {
      batch.set(_db.collection('notifications').doc(), n);
    }
    await batch.commit();
  }

  /// Mark notifikasi sebagai sudah dibaca
  Future<void> markNotificationRead(String notifId) async {
    await _db
        .collection('notifications')
        .doc(notifId)
        .update({'isRead': true});
  }

  // ── CHATS ─────────────────────────────────────────────────

  /// Stream percakapan user
  Stream<List<Map<String, dynamic>>> getChatsStream(String userId) {
    return _db
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Seed beberapa chat demo untuk user
  Future<void> seedChats(String userId) async {
    final existing = await _db
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final chats = [
      {
        'userId': userId,
        'mitraName': 'Toni Raharjo',
        'mitraAvatar': 'https://i.pravatar.cc/150?img=11',
        'lastMsg': 'Baik pak, saya akan datang jam 10 pagi',
        'unread': 1,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': userId,
        'mitraName': 'Siti Aminah',
        'mitraAvatar': 'https://i.pravatar.cc/150?img=21',
        'lastMsg': 'Terima kasih sudah menggunakan jasa kami!',
        'unread': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];
    for (final c in chats) {
      batch.set(_db.collection('chats').doc(), c);
    }
    await batch.commit();
  }



  // ── SERVICES ────────────────────────────────────────────

  /// Stream semua layanan secara real-time
  Stream<List<ServiceModel>> getServicesStream() {
    return _db
        .collection('services')
        .orderBy('isFeatured', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  /// Stream layanan populer (featured)
  Stream<List<ServiceModel>> getFeaturedServicesStream() {
    return _db
        .collection('services')
        .where('isFeatured', isEqualTo: true)
        .limit(8)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  /// Stream layanan berdasarkan kategori
  Stream<List<ServiceModel>> getServicesByCategory(String category) {
    return _db
        .collection('services')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  /// Ambil semua layanan sekali (untuk pencarian lokal)
  Future<List<ServiceModel>> getAllServices() async {
    final snap = await _db.collection('services').get();
    return snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
  }

  /// Ambil semua kategori unik
  Future<List<String>> getCategories() async {
    final snap = await _db.collection('services').get();
    final categories = snap.docs
        .map((doc) => (doc.data())['category'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // ── ORDERS ──────────────────────────────────────────────

  /// Tambah pesanan baru ke Firestore
  Future<void> addOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toMap());
  }

  /// Stream pesanan berdasarkan userId
  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }


  // ── SEED DATA ───────────────────────────────────────────

  /// Seed 25 data layanan ke Firestore (jalankan sekali)
  Future<void> seedServices() async {
    final existing = await _db.collection('services').limit(1).get();
    if (existing.docs.isNotEmpty) return; // Sudah ada data

    final services = _getSeedData();
    final batch = _db.batch();
    for (final service in services) {
      final ref = _db.collection('services').doc();
      batch.set(ref, service);
    }
    await batch.commit();
  }

  List<Map<String, dynamic>> _getSeedData() {
    return [
      {
        'title': 'Service & Cuci AC - Bergaransi 3 Bulan',
        'category': 'Elektronik',
        'mitraName': 'Toni Raharjo',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=11',
        'mitraRating': 4.9,
        'totalOrders': 1247,
        'price': 85000.0,
        'description':
            'Layanan service AC lengkap dengan pembersihan filter, pengecekan freon, dan perawatan berkala. Didukung teknisi berpengalaman lebih dari 5 tahun.',
        'imageUrl': 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=600',
        'isEscrow': true,
        'responseTime': '< 5 menit',
        'city': 'Surabaya',
        'isFeatured': true,
        'packages': [
          {'name': 'Paket Standar', 'price': 85000.0, 'description': 'Cuci 1 unit AC'},
          {'name': 'Paket Premium', 'price': 150000.0, 'description': 'Cuci + cek freon 1 unit'},
        ],
      },
      {
        'title': 'Instalasi AC Baru - Semua Merek',
        'category': 'Elektronik',
        'mitraName': 'Rudi Santoso',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=12',
        'mitraRating': 4.7,
        'totalOrders': 892,
        'price': 250000.0,
        'description': 'Instalasi AC baru untuk semua merek dengan garansi pemasangan 6 bulan. Material pipa berkualitas.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': true,
        'responseTime': '< 10 menit',
        'city': 'Jakarta',
        'isFeatured': true,
        'packages': [
          {'name': 'Standard', 'price': 250000.0, 'description': 'Instalasi 1/2 PK - 1 PK'},
          {'name': 'Premium', 'price': 350000.0, 'description': 'Instalasi 1.5 PK - 2 PK'},
        ],
      },
      {
        'title': 'Bersih-Bersih Rumah - Profesional',
        'category': 'Kebersihan',
        'mitraName': 'Siti Aminah',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=21',
        'mitraRating': 4.8,
        'totalOrders': 2134,
        'price': 120000.0,
        'description': 'Jasa kebersihan rumah profesional menggunakan peralatan modern dan produk ramah lingkungan.',
        'imageUrl': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600',
        'isEscrow': true,
        'responseTime': '< 15 menit',
        'city': 'Bandung',
        'isFeatured': true,
        'packages': [
          {'name': 'Reguler (3 jam)', 'price': 120000.0, 'description': 'Bersih-bersih standar'},
          {'name': 'Deep Clean (6 jam)', 'price': 220000.0, 'description': 'Bersih menyeluruh termasuk sudut'},
        ],
      },
      {
        'title': 'Cuci Sofa & Karpet',
        'category': 'Kebersihan',
        'mitraName': 'Budi Pratama',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=13',
        'mitraRating': 4.6,
        'totalOrders': 567,
        'price': 75000.0,
        'description': 'Cuci sofa dan karpet menggunakan mesin ekstraktor. Sofa kering dalam 2-3 jam.',
        'imageUrl': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
        'isEscrow': false,
        'responseTime': '< 20 menit',
        'city': 'Surabaya',
        'isFeatured': false,
        'packages': [
          {'name': 'Sofa 2 Dudukan', 'price': 75000.0, 'description': 'Cuci + parfum'},
          {'name': 'Sofa 3 Dudukan', 'price': 100000.0, 'description': 'Cuci + parfum + proteksi'},
        ],
      },
      {
        'title': 'Perbaikan Instalasi Listrik Rumah',
        'category': 'Listrik',
        'mitraName': 'Joko Susilo',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=14',
        'mitraRating': 4.9,
        'totalOrders': 789,
        'price': 150000.0,
        'description': 'Teknisi listrik bersertifikat PLN. Menangani korsleting, MCB, instalasi baru, dan troubleshooting.',
        'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
        'isEscrow': true,
        'responseTime': '< 10 menit',
        'city': 'Jakarta',
        'isFeatured': true,
        'packages': [
          {'name': 'Diagnosis & Perbaikan', 'price': 150000.0, 'description': 'Cek + perbaiki 1 titik'},
          {'name': 'Instalasi Baru', 'price': 300000.0, 'description': 'Instalasi per titik stop kontak'},
        ],
      },
      {
        'title': 'Pasang CCTV Rumah & Kantor',
        'category': 'Elektronik',
        'mitraName': 'Ahmad Fauzi',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=15',
        'mitraRating': 4.7,
        'totalOrders': 345,
        'price': 500000.0,
        'description': 'Pemasangan CCTV HD, IP Camera, dan NVR/DVR. Include setting remote monitoring via smartphone.',
        'imageUrl': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=600',
        'isEscrow': true,
        'responseTime': '< 30 menit',
        'city': 'Bekasi',
        'isFeatured': false,
        'packages': [
          {'name': '1 Kamera', 'price': 500000.0, 'description': 'Pasang 1 unit CCTV + setting'},
          {'name': '4 Kamera', 'price': 1800000.0, 'description': 'Pasang 4 unit + DVR + HDD'},
        ],
      },
      {
        'title': 'Cat Dinding Kamar & Ruangan',
        'category': 'Renovasi',
        'mitraName': 'Hendra Wijaya',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=16',
        'mitraRating': 4.5,
        'totalOrders': 423,
        'price': 35000.0,
        'description': 'Jasa cat dinding profesional, rapi, dan bersih. Cat berkualitas, hasil tahan lama. Bisa sesuaikan warna.',
        'imageUrl': 'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=600',
        'isEscrow': false,
        'responseTime': '< 1 jam',
        'city': 'Tangerang',
        'isFeatured': false,
        'packages': [
          {'name': 'Per m²', 'price': 35000.0, 'description': 'Cat 1 lapis'},
          {'name': 'Per m² Premium', 'price': 55000.0, 'description': 'Cat 2 lapis + plamur'},
        ],
      },
      {
        'title': 'Pasang Wallpaper Dinding',
        'category': 'Renovasi',
        'mitraName': 'Dewi Lestari',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=22',
        'mitraRating': 4.8,
        'totalOrders': 312,
        'price': 45000.0,
        'description': 'Pemasangan wallpaper dinding rapi dan profesional. Bisa request motif dan bahan. Hasil tahan lama.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': true,
        'responseTime': '< 2 jam',
        'city': 'Depok',
        'isFeatured': false,
        'packages': [
          {'name': 'Per Roll', 'price': 45000.0, 'description': 'Pasang 1 roll wallpaper'},
          {'name': 'Paket Kamar', 'price': 350000.0, 'description': 'Pasang 1 kamar (5 roll)'},
        ],
      },
      {
        'title': 'Laundry Kilogram - Antar Jemput',
        'category': 'Laundry',
        'mitraName': 'Rahmat Hidayat',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=17',
        'mitraRating': 4.6,
        'totalOrders': 1893,
        'price': 7000.0,
        'description': 'Laundry cuci kering setrika dengan aroma wangi. Layanan antar jemput area kota. Selesai 2 hari.',
        'imageUrl': 'https://images.unsplash.com/photo-1567113379935-b33e4e90d0f1?w=600',
        'isEscrow': false,
        'responseTime': '< 5 menit',
        'city': 'Yogyakarta',
        'isFeatured': true,
        'packages': [
          {'name': 'Reguler (3 hari)', 'price': 7000.0, 'description': 'Per kg, min 3 kg'},
          {'name': 'Express (1 hari)', 'price': 12000.0, 'description': 'Per kg, min 3 kg'},
        ],
      },
      {
        'title': 'Cuci Sepatu Sneakers & Casual',
        'category': 'Laundry',
        'mitraName': 'Kevin Adriansyah',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=18',
        'mitraRating': 4.9,
        'totalOrders': 654,
        'price': 45000.0,
        'description': 'Cuci sepatu dengan teknik hand-wash khusus agar material tetap terjaga. Hasil bersih dan wangi.',
        'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
        'isEscrow': true,
        'responseTime': '< 5 menit',
        'city': 'Surabaya',
        'isFeatured': false,
        'packages': [
          {'name': 'Standar', 'price': 45000.0, 'description': '1 pasang, 3-4 hari'},
          {'name': 'Express', 'price': 75000.0, 'description': '1 pasang, 1 hari'},
        ],
      },
      {
        'title': 'Reparasi Kulkas - Semua Merek',
        'category': 'Elektronik',
        'mitraName': 'Dian Permana',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=19',
        'mitraRating': 4.7,
        'totalOrders': 432,
        'price': 200000.0,
        'description': 'Servis kulkas tidak dingin, bocor freon, tidak mau menyala. Teknisi berpengalaman 8 tahun.',
        'imageUrl': 'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?w=600',
        'isEscrow': true,
        'responseTime': '< 20 menit',
        'city': 'Jakarta',
        'isFeatured': false,
        'packages': [
          {'name': 'Diagnosis', 'price': 50000.0, 'description': 'Cek dan diagnosa masalah'},
          {'name': 'Service Lengkap', 'price': 200000.0, 'description': 'Diagnosa + perbaikan'},
        ],
      },
      {
        'title': 'Reparasi Mesin Cuci',
        'category': 'Elektronik',
        'mitraName': 'Yusuf Arifin',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=20',
        'mitraRating': 4.6,
        'totalOrders': 321,
        'price': 175000.0,
        'description': 'Perbaikan mesin cuci top loading dan front loading. Masalah mati total, bocor, drum tidak berputar.',
        'imageUrl': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=600',
        'isEscrow': false,
        'responseTime': '< 30 menit',
        'city': 'Bekasi',
        'isFeatured': false,
        'packages': [
          {'name': 'Service Ringan', 'price': 175000.0, 'description': 'Perbaikan tanpa ganti part'},
          {'name': 'Service Berat', 'price': 350000.0, 'description': 'Termasuk ganti part standar'},
        ],
      },
      {
        'title': 'Perbaikan Atap Bocor',
        'category': 'Renovasi',
        'mitraName': 'Surya Darma',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=23',
        'mitraRating': 4.5,
        'totalOrders': 234,
        'price': 400000.0,
        'description': 'Perbaikan atap bocor, ganti genteng, waterproofing, dan perbaikan talang. Bergaransi 1 tahun.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': true,
        'responseTime': '< 1 jam',
        'city': 'Surabaya',
        'isFeatured': false,
        'packages': [
          {'name': 'Pengecekan', 'price': 100000.0, 'description': 'Cek lokasi bocor'},
          {'name': 'Perbaikan Standar', 'price': 400000.0, 'description': 'Waterproofing titik bocor'},
        ],
      },
      {
        'title': 'Pasang Keramik & Granit',
        'category': 'Renovasi',
        'mitraName': 'Agus Mulyadi',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=24',
        'mitraRating': 4.7,
        'totalOrders': 567,
        'price': 80000.0,
        'description': 'Jasa pasang keramik lantai dan dinding, nat rapi, tepat ukuran. Pengalaman 10 tahun.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': false,
        'responseTime': '< 2 jam',
        'city': 'Bandung',
        'isFeatured': false,
        'packages': [
          {'name': 'Per m²', 'price': 80000.0, 'description': 'Pasang keramik standar'},
          {'name': 'Granit Per m²', 'price': 120000.0, 'description': 'Pasang granit premium'},
        ],
      },
      {
        'title': 'Jasa Fotografi Produk & Event',
        'category': 'Kreatif',
        'mitraName': 'Rizky Fadillah',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=25',
        'mitraRating': 4.9,
        'totalOrders': 198,
        'price': 500000.0,
        'description': 'Foto produk e-commerce, foto event keluarga, wisuda, dan pernikahan. Editing profesional.',
        'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
        'isEscrow': true,
        'responseTime': '< 1 jam',
        'city': 'Yogyakarta',
        'isFeatured': true,
        'packages': [
          {'name': 'Produk (10 foto)', 'price': 500000.0, 'description': '10 foto + editing'},
          {'name': 'Event (3 jam)', 'price': 1500000.0, 'description': 'Dokumentasi event 3 jam'},
        ],
      },
      {
        'title': 'Desain Undangan Digital & Pamflet',
        'category': 'Kreatif',
        'mitraName': 'Nina Kartika',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=26',
        'mitraRating': 4.8,
        'totalOrders': 445,
        'price': 100000.0,
        'description': 'Desain undangan pernikahan, ulang tahun, dan pamflet bisnis. Format digital dan cetak siap.',
        'imageUrl': 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=600',
        'isEscrow': false,
        'responseTime': '< 30 menit',
        'city': 'Jakarta',
        'isFeatured': false,
        'packages': [
          {'name': 'Undangan Digital', 'price': 100000.0, 'description': 'File JPG/PDF, 2x revisi'},
          {'name': 'Paket Lengkap', 'price': 250000.0, 'description': 'Undangan + amplop + name tag'},
        ],
      },
      {
        'title': 'Penitipan & Perawatan Hewan',
        'category': 'Penitipan',
        'mitraName': 'Citra Dewi',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=27',
        'mitraRating': 4.9,
        'totalOrders': 312,
        'price': 80000.0,
        'description': 'Penitipan anjing dan kucing dengan fasilitas lengkap. Makan 3x, mandi mingguan, bermain.',
        'imageUrl': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=600',
        'isEscrow': true,
        'responseTime': '< 1 jam',
        'city': 'Tangerang',
        'isFeatured': false,
        'packages': [
          {'name': 'Per Hari', 'price': 80000.0, 'description': 'Titip 1 hewan kecil'},
          {'name': 'Per Minggu', 'price': 450000.0, 'description': 'Titip 1 hewan kecil 7 hari'},
        ],
      },
      {
        'title': 'Servis Komputer & Laptop',
        'category': 'Elektronik',
        'mitraName': 'Farhan Nugraha',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=28',
        'mitraRating': 4.7,
        'totalOrders': 876,
        'price': 100000.0,
        'description': 'Servis laptop lemot, mati total, virus, install OS, upgrade RAM/SSD. Garansi 30 hari.',
        'imageUrl': 'https://images.unsplash.com/photo-1588702547954-4800f034c8a1?w=600',
        'isEscrow': true,
        'responseTime': '< 10 menit',
        'city': 'Semarang',
        'isFeatured': false,
        'packages': [
          {'name': 'Diagnosis', 'price': 50000.0, 'description': 'Cek dan laporan masalah'},
          {'name': 'Service Standar', 'price': 100000.0, 'description': 'Perbaikan + clean up'},
        ],
      },
      {
        'title': 'Pijat Refleksi & Relaksasi',
        'category': 'Kesehatan',
        'mitraName': 'Pak Slamet',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=29',
        'mitraRating': 4.8,
        'totalOrders': 2341,
        'price': 120000.0,
        'description': 'Pijat refleksi tradisional Jawa. Mengatasi pegal, stres, dan melancarkan peredaran darah.',
        'imageUrl': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600',
        'isEscrow': false,
        'responseTime': '< 15 menit',
        'city': 'Yogyakarta',
        'isFeatured': true,
        'packages': [
          {'name': '60 Menit', 'price': 120000.0, 'description': 'Refleksi + punggung'},
          {'name': '90 Menit', 'price': 170000.0, 'description': 'Full body massage'},
        ],
      },
      {
        'title': 'Les Privat Matematika & IPA',
        'category': 'Pendidikan',
        'mitraName': 'Bu Ratna Sari',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=30',
        'mitraRating': 4.9,
        'totalOrders': 567,
        'price': 150000.0,
        'description': 'Les privat SD-SMA untuk Matematika, Fisika, dan Kimia. Pengajar lulusan S1 Teknik Fisika ITS.',
        'imageUrl': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=600',
        'isEscrow': false,
        'responseTime': '< 30 menit',
        'city': 'Surabaya',
        'isFeatured': false,
        'packages': [
          {'name': 'Per Sesi (90 min)', 'price': 150000.0, 'description': '1 sesi les 90 menit'},
          {'name': 'Paket 10 Sesi', 'price': 1300000.0, 'description': 'Hemat 10% dari harga normal'},
        ],
      },
      {
        'title': 'Jasa Angkut & Pindah Barang',
        'category': 'Logistik',
        'mitraName': 'Pak Budi Angkut',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=31',
        'mitraRating': 4.5,
        'totalOrders': 432,
        'price': 200000.0,
        'description': 'Jasa angkut barang pindahan rumah dan kantor. Armada pickup, box truck tersedia. Tim 2-4 orang.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': true,
        'responseTime': '< 1 jam',
        'city': 'Jakarta',
        'isFeatured': false,
        'packages': [
          {'name': 'Pickup', 'price': 200000.0, 'description': 'Angkut dengan pickup + 2 orang'},
          {'name': 'Box Truck', 'price': 450000.0, 'description': 'Angkut dengan truck + 4 orang'},
        ],
      },
      {
        'title': 'Cuci Mobil & Motor Panggilan',
        'category': 'Otomotif',
        'mitraName': 'Doni Wahyu',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=32',
        'mitraRating': 4.7,
        'totalOrders': 1234,
        'price': 35000.0,
        'description': 'Cuci kendaraan di lokasi Anda. Peralatan lengkap dibawa teknisi. Motor & mobil tersedia.',
        'imageUrl': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600',
        'isEscrow': false,
        'responseTime': '< 10 menit',
        'city': 'Bandung',
        'isFeatured': false,
        'packages': [
          {'name': 'Motor', 'price': 35000.0, 'description': 'Cuci bersih + lap kering'},
          {'name': 'Mobil', 'price': 80000.0, 'description': 'Cuci body + vacuum interior'},
        ],
      },
      {
        'title': 'Ganti Oli & Tune Up Kendaraan',
        'category': 'Otomotif',
        'mitraName': 'Bengkel Mas Eko',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=33',
        'mitraRating': 4.6,
        'totalOrders': 876,
        'price': 85000.0,
        'description': 'Ganti oli, busi, filter, dan tune up kendaraan panggilan. Mekanik berpengalaman datang ke lokasi.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': true,
        'responseTime': '< 20 menit',
        'city': 'Surabaya',
        'isFeatured': false,
        'packages': [
          {'name': 'Ganti Oli Motor', 'price': 85000.0, 'description': 'Termasuk oli standar'},
          {'name': 'Tune Up Mobil', 'price': 350000.0, 'description': 'Cek & tune up lengkap'},
        ],
      },
      {
        'title': 'Pasang Stop Kontak & Saklar',
        'category': 'Listrik',
        'mitraName': 'Bambang Listrik',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=34',
        'mitraRating': 4.8,
        'totalOrders': 654,
        'price': 80000.0,
        'description': 'Pasang stop kontak, saklar, dan MCB baru. Material standar SNI. Garansi instalasi 6 bulan.',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'isEscrow': false,
        'responseTime': '< 15 menit',
        'city': 'Depok',
        'isFeatured': false,
        'packages': [
          {'name': 'Per Titik', 'price': 80000.0, 'description': 'Pasang 1 stop kontak/saklar'},
          {'name': 'Paket 5 Titik', 'price': 350000.0, 'description': 'Hemat 12% dari satuan'},
        ],
      },
      {
        'title': 'Deep Cleaning Kamar Mandi',
        'category': 'Kebersihan',
        'mitraName': 'Tim Bersih Pro',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=35',
        'mitraRating': 4.9,
        'totalOrders': 987,
        'price': 150000.0,
        'description': 'Pembersihan kamar mandi menyeluruh termasuk kloset, keran, cermin, dan dinding. Anti jamur.',
        'imageUrl': 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=600',
        'isEscrow': true,
        'responseTime': '< 15 menit',
        'city': 'Jakarta',
        'isFeatured': true,
        'packages': [
          {'name': '1 Kamar Mandi', 'price': 150000.0, 'description': 'Deep clean 1 toilet'},
          {'name': '2 Kamar Mandi', 'price': 270000.0, 'description': 'Deep clean 2 toilet'},
        ],
      },
      {
        'title': 'Konsultasi Desain Interior',
        'category': 'Kreatif',
        'mitraName': 'Rina Desainer',
        'mitraAvatarUrl': 'https://i.pravatar.cc/150?img=36',
        'mitraRating': 4.8,
        'totalOrders': 156,
        'price': 300000.0,
        'description': 'Konsultasi desain interior rumah, kafe, dan kantor. Termasuk 3D render dan RAB material.',
        'imageUrl': 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=600',
        'isEscrow': true,
        'responseTime': '< 2 jam',
        'city': 'Jakarta',
        'isFeatured': false,
        'packages': [
          {'name': 'Konsultasi (1 jam)', 'price': 300000.0, 'description': 'Online/offline + moodboard'},
          {'name': 'Paket Lengkap', 'price': 2500000.0, 'description': 'Desain + 3D render + RAB'},
        ],
      },
    ];
  }
}
