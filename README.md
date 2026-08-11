# DyslexAid

DyslexAid adalah aplikasi pendamping membaca interaktif berbasis mobile yang dirancang khusus untuk membantu penyandang disleksia dalam membaca dan memperluas perbendaharaan kosakata bahasa Indonesia. Aplikasi ini dibuat menggunakan kerangka kerja Flutter.

## Fitur Utama ✨

- 📷 **Pindai & Baca (OCR)**: Ekstrak teks dari buku fisik atau dokumen menggunakan kamera atau galeri foto (didukung oleh Google ML Kit).
- 📖 **Teks Ramah Disleksia**: Teks yang dikonversi dapat dibaca menggunakan *font* yang ramah disleksia (seperti OpenDyslexic atau Lexend). Pengguna dapat mengatur ukuran teks, spasi huruf, dan spasi antar kata sesuai kenyamanan mata mereka.
- 🔊 **Text-to-Speech (TTS) dengan Sorotan Teks**: Aplikasi dapat membacakan teks dengan suara (Text-to-Speech) sembari memberikan sorotan (highlight) pada kata yang sedang diucapkan, membantu pengguna untuk tetap fokus.
- 🧠 **Kamus & Pelacakan Kosakata**: Deteksi otomatis kata-kata baru, pencarian arti kata (KBBI), dan daftar kosakata yang dapat dipelajari.
- 🗂️ **Latihan Flashcard**: Fitur gamifikasi *Flashcard* berbasis *Spaced Repetition* ringan untuk mengingat dan melatih kata-kata baru.
- 🕰️ **Riwayat Membaca**: Menyimpan secara otomatis hasil pindaian dan teks yang sudah dibaca (disimpan lokal secara luring menggunakan Hive).
- 🎨 **Personalisasi Tema (Dynamic Theme)**: Mendukung kustomisasi warna aksen (*Ocean Breeze*, *Sunset Coral*, *Lavender Dream*, dll.) serta *Dark Mode* (Mode Gelap) dengan antarmuka bergaya *Glassmorphism* modern.

## Teknologi yang Digunakan 🛠️

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Kecerdasan Buatan / Machine Learning**: [Google ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition/v2/android)
- **Database Lokal**: [Hive](https://pub.dev/packages/hive) (NoSQL)
- **Audio / Suara**: [flutter_tts](https://pub.dev/packages/flutter_tts)
- **UI/UX**: Desain Glassmorphism kustom dengan dukungan warna adaptif dinamis (`ThemeData.colorScheme`).

## Instalasi & Menjalankan Aplikasi 🚀

1. Pastikan Anda telah menginstal **Flutter SDK** terbaru.
2. *Clone* repositori ini:
   ```bash
   git clone https://github.com/DavidLauda/DyslexAid.git
   ```
3. Pindah ke direktori proyek:
   ```bash
   cd DyslexAid/dyslexaid
   ```
4. Unduh semua dependensi yang dibutuhkan:
   ```bash
   flutter pub get
   ```
5. Hubungkan perangkat fisik Android/iOS Anda atau jalankan emulator.
6. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Lisensi
Proyek ini dibuat untuk membantu aksesibilitas pendidikan dan membaca.
