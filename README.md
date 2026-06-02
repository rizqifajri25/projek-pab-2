# PadelFinder

PadelFinder adalah aplikasi Flutter untuk mencari dan berbagi informasi lapangan padel di Kota Palembang. Proyek ini terdiri dari **mobile app** untuk pengguna dan **Flutter Web Admin Panel** untuk admin/moderator.

## Fitur Utama

### Mobile App
- Firebase Authentication email/password: register, login, logout, reset password.
- Home dengan Flutter Map, tile OpenStreetMap, marker lapangan, dan feed postingan terbaru.
- Search berdasarkan nama lapangan, alamat/lokasi, dan fasilitas.
- Detail lapangan dengan foto, alamat, peta, deskripsi, fasilitas, favorit, komentar, dan report.
- Posting lapangan baru dengan foto, koordinat GPS dari Geolocator, status `pending`, dan publik setelah `approved` admin.
- Favorit, CRUD komentar milik sendiri, report konten bermasalah, dan profil pengguna.

### Admin Panel
- Login admin dengan Firebase Authentication.
- Dashboard realtime berisi total user, lapangan, komentar, laporan, pending post, dan grafik aktivitas.
- Kelola user: aktifkan, nonaktifkan, hapus dokumen user.
- Kelola lapangan/postingan: filter pending/approved/rejected, approve, reject, edit placeholder.
- Moderasi komentar dan laporan dengan status `open`, `in progress`, `resolved`.
- Profil admin, reset password, dan logout.

## 1. Instalasi Flutter

1. Unduh Flutter Latest Stable dari <https://docs.flutter.dev/get-started/install>.
2. Tambahkan `flutter/bin` ke `PATH`.
3. Jalankan:

```bash
flutter doctor
```

Pastikan Android toolchain, Chrome, dan device target sudah hijau sesuai kebutuhan.

## 2. Instalasi Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase --version
```

## 3. Membuat Project Firebase

1. Buka Firebase Console.
2. Buat project, contoh: `padel-finder-palembang`.
3. Aktifkan Authentication dengan provider **Email/Password**.
4. Aktifkan Cloud Firestore mode production.
5. Aktifkan Firebase Storage.
6. Buat user admin pada Authentication, lalu buat dokumen `users/{uid}` dengan field:

```json
{
  "uid": "UID_ADMIN",
  "name": "Admin PadelFinder",
  "email": "admin@example.com",
  "role": "admin",
  "status": "active",
  "photoUrl": null,
  "createdAt": "serverTimestamp"
}
```

## 4. Konfigurasi Android

```bash
cd mobile_app
flutterfire configure --project=padel-finder-palembang --platforms=android,ios,web
```

Perintah tersebut akan menghasilkan `lib/firebase_options.dart` yang menggantikan placeholder bawaan. Untuk Android, pastikan `android/app/google-services.json` ada dan package name sesuai konfigurasi Firebase.

## 5. Konfigurasi Web

```bash
cd admin_panel
flutterfire configure --project=padel-finder-palembang --platforms=web
```

Pastikan `admin_panel/lib/firebase_options.dart` berisi konfigurasi web Firebase asli. File `firebase.json` sudah diarahkan untuk hosting dari `admin_panel/build/web`.

## 6. Menjalankan Mobile

```bash
cd mobile_app
flutter pub get
flutter run
```

Jika ingin menjalankan target Android tertentu:

```bash
flutter devices
flutter run -d <device-id>
```

## 7. Menjalankan Web Admin

```bash
cd admin_panel
flutter pub get
flutter run -d chrome
```

Login menggunakan akun yang dokumen `users/{uid}` memiliki `role: admin`.

## 8. Struktur Folder

```text
PadelFinder/
├── mobile_app/
│   ├── lib/
│   │   ├── core/          # theme, provider Firebase
│   │   ├── services/      # GPS dan local notifications
│   │   ├── models/        # AppUser, Court, Comment, Report
│   │   ├── repositories/  # Firebase Auth, Firestore, Storage access
│   │   ├── features/      # auth, home, search, detail, posting, favorites, profile
│   │   ├── widgets/       # reusable UI
│   │   └── routes/        # Go Router
│   ├── assets/
│   ├── android/
│   └── ios/
├── admin_panel/
│   ├── lib/
│   │   ├── core/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── features/      # auth, dashboard, users, courts, comments, reports, profile
│   │   ├── widgets/
│   │   └── routes/
│   ├── web/
│   └── assets/
├── firestore.rules
├── storage.rules
├── firebase.json
├── .firebaserc
├── README.md
└── docs/
```

## 9. Firestore Rules

Rules berada di `firestore.rules` dan mengatur:
- user hanya membaca/mengubah profil sendiri, admin dapat mengelola semua user;
- court publik hanya jika `approved`, owner dapat melihat posting sendiri, admin bisa approve/reject;
- favorite hanya milik user terkait;
- komentar bisa dibuat oleh user login dan dihapus oleh owner/admin;
- report dibaca/dikelola admin, dibuat oleh user login.

Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

## 10. Deployment Firebase Hosting

```bash
cd admin_panel
flutter pub get
flutter build web --release
cd ..
firebase deploy --only hosting
```

## 11. Build APK

```bash
cd mobile_app
flutter pub get
flutter build apk --release
```

Output berada di `mobile_app/build/app/outputs/flutter-apk/app-release.apk`.

## 12. Build Web

```bash
cd admin_panel
flutter pub get
flutter build web --release
```

Output berada di `admin_panel/build/web`.

## Catatan Production

- Ganti placeholder `firebase_options.dart` menggunakan FlutterFire CLI sebelum menjalankan aplikasi.
- Tambahkan index Firestore jika Firebase Console meminta saat query `where + orderBy` digunakan.
- Untuk penghapusan akun Authentication oleh admin, gunakan Cloud Functions/Admin SDK karena client SDK tidak boleh menghapus user lain secara langsung.
- Gunakan kompresi gambar dan validasi ukuran Storage sebelum rilis publik.
