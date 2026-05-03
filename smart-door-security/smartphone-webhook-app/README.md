# Contoh Aplikasi Smartphone Webhook

Ini adalah contoh sederhana untuk menampilkan alert di smartphone melalui browser.
File ini menggunakan web app statis yang memeriksa endpoint JSON dan menampilkan pesan.

## Cara pakai
1. Jalankan `smartphone-webhook-app/server.py`.
2. Buka browser smartphone ke alamat yang ditampilkan, misalnya `http://192.168.1.100:8080`.
3. Setiap alert yang diterima disimpan dan ditampilkan di halaman.

## Struktur
- `index.html` - antarmuka web smartphone.
- `server.py` - server Python yang menyajikan halaman dan endpoint `GET /alert`.

## Fitur
- Menampilkan alert terakhir
- Menampilkan daftar semua alert terbaru
- Responsive untuk tampilan smartphone
