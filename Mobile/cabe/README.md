# CaBe - Cari Beasiswa

Aplikasi Flutter untuk mempermudah pencarian beasiswa (CaBe). Proyek ini dibangun menggunakan **Flutter** dan menggunakan arsitektur berbasis fitur (*feature-driven architecture*) dengan **Riverpod** sebagai manajemen state.

---

## 🛠 Persiapan (Prerequisites)
Pastikan Anda sudah menginstal hal-hal berikut di komputer Anda:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.x atau yang sesuai dengan `pubspec.yaml`)
- [Git](https://git-scm.com/)
- IDE seperti VS Code atau Android Studio

---

## 🚀 Cara Clone Project

Ikuti langkah-langkah berikut untuk mengunduh (clone) dan menjalankan proyek ini di komputer lokal Anda:

1. **Clone repository**
   Buka terminal atau command prompt, lalu jalankan perintah berikut:
   ```bash
   git clone <URL_REPOSITORY_ANDA>
   ```
   *(Ganti `<URL_REPOSITORY_ANDA>` dengan URL git proyek ini, contoh: `https://github.com/username/cabe.git`)*

2. **Masuk ke folder proyek**
   ```bash
   cd cabe
   ```

3. **Unduh semua dependensi (packages)**
   Jalankan perintah ini untuk menginstal semua package yang dibutuhkan (seperti `flutter_riverpod`, `lucide_icons`, dll):
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi**
   Pastikan Anda sudah menyalakan Emulator Android / iOS Simulator, atau menyambungkan perangkat fisik, lalu ketik:
   ```bash
   flutter run
   ```

---

## 🌿 Cara Melakukan Perubahan dan Push ke Branch Baru

Untuk menjaga agar kode utama (branch `main`) tetap stabil, sangat disarankan untuk selalu membuat **branch baru** setiap kali Anda mengerjakan fitur baru atau memperbaiki bug.

Berikut adalah alur kerjanya:

### 1. Pastikan kode lokal Anda terbaru
Sebelum membuat branch baru, pastikan branch utama Anda sudah yang paling *up-to-date*:
```bash
git checkout main
git pull origin main
```

### 2. Buat Branch Baru
Buat branch baru dengan nama yang mendeskripsikan apa yang sedang Anda kerjakan.
Contoh: `feature/login`, `bugfix/bottom-nav`, atau `ui/home-screen`.
```bash
git checkout -b nama-branch-anda
```

### 3. Tambahkan Perubahan (Staging)
Setelah Anda selesai mengedit/menulis kode, simpan perubahan tersebut ke sistem Git:
```bash
# Menambahkan seluruh file yang berubah:
git add .

# ATAU menambahkan file spesifik saja:
git add lib/views/home_screen.dart
```

### 4. Buat Commit dengan Pesan Tertentu
Buat pesan *commit* yang jelas. Disarankan menggunakan konvensi **Conventional Commits** (seperti `feat:`, `fix:`, `docs:`, `style:`, dll).
```bash
git commit -m "feat: menambahkan layout bottom navigation dengan lucide icons"
```

### 5. Push Branch ke Remote Repository (Github/Gitlab)
Karena ini adalah branch baru yang belum ada di remote, Anda harus mem-*push* sekaligus mengatur upstream-nya:
```bash
git push -u origin nama-branch-anda
```

Untuk *push* selanjutnya di branch yang sama, Anda cukup mengetikkan:
```bash
git push
```

---

## 📝 Ketentuan Commit (Commit Convention)

Untuk menjaga histori Git tetap rapi dan mudah dibaca, kita menggunakan standar [Conventional Commits](https://www.conventionalcommits.org/). Harap mulai setiap pesan commit dengan salah satu awalan berikut:

- `feat:` -> Digunakan ketika Anda menambahkan **fitur baru** (contoh: `feat: add login screen`).
- `fix:` -> Digunakan ketika Anda **memperbaiki bug/error** (contoh: `fix: resolve crash on home page`).
- `ui:` -> Digunakan ketika Anda merubah/memperbarui **tampilan (UI) atau styling** tanpa merubah fungsionalitas utama (contoh: `ui: update primary button color`).
- `refactor:` -> Digunakan ketika Anda merestrukturisasi atau merapikan kode tanpa merubah fungsi/fiturnya (contoh: `refactor: extract bottom nav to a separate widget`).
- `docs:` -> Digunakan ketika ada perubahan pada **dokumentasi** seperti `README.md` (contoh: `docs: update project setup instructions`).
- `chore:` -> Digunakan untuk perubahan minor yang tidak terkait dengan kode aplikasi (contoh: `chore: update packages` atau `chore: setup riverpod`).

**Contoh Format Commit yang Benar:**
```bash
git commit -m "feat: membuat layout halaman profil pengguna"
```
*(Catatan: Gunakan pesan yang jelas, singkat, dan mendeskripsikan secara akurat apa yang Anda ubah).*

---

**Selamat Mengoding!** 🚀
