# Sobat Beres - Aplikasi Marketplace Jasa

**Aplikasi marketplace jasa berbasis Flutter yang menghubungkan pelanggan dengan penyedia jasa (mitra) terpercaya.**

---

## Informasi Proyek

| | |
|---|---|
| **Nama Aplikasi** | Sobat Beres |
| **Tema** | Marketplace Jasa (service marketplace) |
| **Firebase Project** | sobat-beres |
| **Package** | com.example.uaspemmob |

---

## Struktur Proyek

```
lib/
├── main.dart                         ← Entry point + Firebase init
├── firebase_options.dart             ← Firebase platform config
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           ← Color palette
│   │   └── app_text_styles.dart      ← Typography (Poppins)
│   └── theme/
│       └── app_theme.dart            ← Global ThemeData
├── models/
│   ├── service_model.dart            ← Model layanan (7 atribut)
│   └── order_model.dart              ← Model pesanan
├── services/
│   └── firebase_service.dart         ← Semua query Firestore
├── screens/
│   ├── splash_screen.dart
│   ├── main_scaffold.dart            ← BottomNavigationBar
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── explore/
│   │   └── explore_screen.dart       ← LIST UTAMA (ListView + GridView)
│   ├── service/
│   │   └── service_detail_screen.dart ← DETAIL DATA
│   ├── order/
│   │   ├── order_screen.dart
│   │   └── add_order_screen.dart     ← FORM + Firestore write
│   ├── chat/
│   │   └── chat_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    └── service_card.dart             ← Custom card widget
```

---

## Struktur Data Firebase (Cloud Firestore)

### Collection: `services`

**Deskripsi:** Menyimpan semua data layanan yang tersedia di aplikasi.

| Field | Tipe | Keterangan |
|---|---|---|
| `title` | String | Nama/judul layanan |
| `category` | String | Kategori layanan (Elektronik, Kebersihan, dll) |
| `mitraName` | String | Nama penyedia jasa |
| `mitraAvatarUrl` | String | URL foto profil mitra |
| `mitraRating` | Number | Rating mitra (0.0 - 5.0) |
| `totalOrders` | Number | Jumlah pesanan yang telah diselesaikan |
| `price` | Number | Harga mulai layanan (dalam Rupiah) |
| `description` | String | Deskripsi detail layanan |
| `imageUrl` | String | URL gambar layanan |
| `isEscrow` | Boolean | Apakah dilindungi sistem escrow |
| `responseTime` | String | Waktu respon mitra (contoh: "< 5 menit") |
| `city` | String | Kota lokasi mitra |
| `isFeatured` | Boolean | Apakah layanan unggulan |
| `packages` | Array | Daftar paket layanan dengan harga |

**Contoh dokumen:**
```json
{
  "title": "Service & Cuci AC - Bergaransi 3 Bulan",
  "category": "Elektronik",
  "mitraName": "Toni Raharjo",
  "mitraAvatarUrl": "https://i.pravatar.cc/150?img=11",
  "mitraRating": 4.9,
  "totalOrders": 1247,
  "price": 85000,
  "description": "Layanan service AC lengkap...",
  "imageUrl": "https://images.unsplash.com/...",
  "isEscrow": true,
  "responseTime": "< 5 menit",
  "city": "Surabaya",
  "isFeatured": true,
  "packages": [
    { "name": "Paket Standar", "price": 85000, "description": "Cuci 1 unit AC" },
    { "name": "Paket Premium", "price": 150000, "description": "Cuci + cek freon" }
  ]
}
```

---

### Collection: `orders`

**Deskripsi:** Menyimpan data pesanan yang dibuat pengguna melalui form.

| Field | Tipe | Keterangan |
|---|---|---|
| `serviceId` | String | ID layanan yang dipesan |
| `serviceTitle` | String | Nama layanan |
| `customerName` | String | Nama pelanggan |
| `phone` | String | Nomor telepon pelanggan |
| `address` | String | Alamat lengkap pelanggan |
| `notes` | String | Catatan tambahan (opsional) |
| `status` | String | Status pesanan (pending/selesai/batal) |
| `totalPrice` | Number | Total harga pesanan |
| `createdAt` | Timestamp | Waktu pesanan dibuat |

**Contoh dokumen:**
```json
{
  "serviceId": "abc123",
  "serviceTitle": "Service & Cuci AC",
  "customerName": "Ahmad Santoso",
  "phone": "08123456789",
  "address": "Jl. Merdeka No. 1, Surabaya",
  "notes": "2 unit AC di lantai 2",
  "status": "pending",
  "totalPrice": 85000,
  "createdAt": "2025-06-15T10:30:00Z"
}
```

---

## Fitur Utama

| No | Fitur | Keterangan |
|---|---|---|
| 1 | **Login & Register** | Form dengan validasi, mock auth |
| 2 | **Beranda** | Promo banner, kategori, layanan populer (StreamBuilder) |
| 3 | **Jelajah** | ListView + GridView, pencarian nama, filter kategori |
| 4 | **Detail Layanan** | Data dari list, info mitra, paket harga, favorit toggle |
| 5 | **Buat Pesanan** | Form dengan validasi, tulis ke Firestore, SnackBar |
| 6 | **Riwayat Pesanan** | Tab: Aktif / Selesai / Dibatalkan |
| 7 | **Chat** | List percakapan dengan mitra |
| 8 | **Profil** | Stats pengguna, menu pengaturan, logout |

---

## Ketentuan UAS yang Dipenuhi

| Kriteria | Status | Implementasi |
|---|---|---|
| Cloud Firestore | ✅ | `services` + `orders` collection |
| 20+ Data, 5+ Atribut | ✅ | 25 layanan, 7+ atribut |
| ListView.builder | ✅ | ExploreScreen |
| GridView.builder | ✅ | ExploreScreen (toggle) |
| Custom Card Widget | ✅ | `ServiceCard` |
| Halaman Detail | ✅ | `ServiceDetailScreen` |
| Data Passing | ✅ | `Navigator.push(MaterialPageRoute(builder: (_) => DetailScreen(service: s)))` |
| Min 3 Halaman | ✅ | 7 halaman |
| Pencarian | ✅ | Search by nama layanan + mitra |
| Filter Kategori | ✅ | Chip filter di ExploreScreen |
| Form + Validasi | ✅ | `AddOrderScreen` + `RegisterScreen` |
| GlobalKey FormState | ✅ | Di setiap form |
| SnackBar | ✅ | Setelah submit berhasil |
| setState | ✅ | Loading, favorit, filter, pencarian |
| ThemeData | ✅ | `AppTheme.lightTheme` |
| SafeArea | ✅ | Semua screen |
| Tidak ada overflow | ✅ | Semua ditest |
| Clean Code | ✅ | Terpisah: models/services/screens/widgets |

---

## Cara Menjalankan

```bash
# 1. Install dependencies
flutter pub get

# 2. Jalankan di emulator/device
flutter run

# Catatan: Data akan otomatis ter-seed ke Firestore
# saat pertama kali HomeScreen dimuat
```

---

## Dependencies Utama

```yaml
firebase_core: ^3.6.0        # Firebase initialization
cloud_firestore: ^5.4.4      # Cloud Firestore database
provider: ^6.1.2             # State management
google_fonts: ^6.2.1         # Font Poppins
shimmer: ^3.0.0              # Loading skeleton
cached_network_image: ^3.3.1 # Caching gambar
intl: ^0.19.0                # Format Rupiah
```

---

*UAS Pemrograman Mobile — Sobat Beres Flutter App*
