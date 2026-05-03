# Smart Home Door Security System

Sistem ini adalah implementasi ide #1: sistem keamanan pintu berbasis CPS menggunakan ESP32, LoRa, sensor pintu, PIR, dan monitoring melalui server/handphone.

## Struktur folder

- `esp32_door_security_node/` - sketch ESP32 node untuk membaca sensor pintu, PIR, dan tegangan baterai.
- `esp32_lora_gateway/` - sketch ESP32 gateway untuk menerima data LoRa dan mengirimkannya ke server lokal melalui WiFi.
- `server/` - skrip Python sederhana untuk menerima webhook notifikasi dan mengirim alert ke smartphone (Pushover optional).

## Fitur

- Deteksi buka/tutup pintu
- Deteksi gerakan di dekat pintu dengan PIR
- Pemantauan tegangan baterai/energi aktual
- Komunikasi nirkabel jarak jauh menggunakan LoRa
- Gateway WiFi untuk mengirim data ke server atau aplikasi smartphone
- Notifikasi alert ke smartphone ketika pintu dibuka atau gerakan terdeteksi

## Hardware yang direkomendasikan

- ESP32 DevKit atau modul ESP32 lain
- Modul LoRa SX1276/78 (misalnya RFM95/96/98)
- Sensor magnet pintu (reed switch)
- Sensor PIR
- Resistor pembagi tegangan untuk pembacaan baterai
- LED/status indicator

## Petunjuk umum

1. Unggah sketch `esp32_door_security_node.ino` ke ESP32 sensor node.
2. Unggah sketch `esp32_lora_gateway.ino` ke ESP32 gateway yang terhubung ke WiFi.
3. Jalankan `server/notification_server.py` di komputer lokal atau server sederhana.
4. Atur `NOTIFICATION_SERVER_URL` pada sketch gateway untuk mengarah ke server Anda.
5. Buka `diagram-wiring.txt` untuk referensi wiring lengkap.
6. Gunakan `pushover-example.md` untuk konfigurasi notifikasi smartphone.
7. Jalankan `smartphone-webhook-app/server.py` untuk membuka dashboard webhook di browser smartphone.

## Wiring Diagram

Lihat file `diagram-wiring.txt` untuk ilustrasi wiring dalam format teks ASCII.

## Contoh Pushover

Lihat `pushover-example.md` untuk langkah konfigurasi `PUSHOVER_TOKEN`, `PUSHOVER_USER`, dan contoh payload.

## Aplikasi Smartphone Webhook Sederhana

Terdapat contoh aplikasi smartphone berbasis browser di folder `smartphone-webhook-app/`.
- `smartphone-webhook-app/index.html` : tampilan web untuk menampilkan alert.
- `smartphone-webhook-app/server.py` : server Python sederhana untuk menyajikan halaman dan endpoint JSON.

## Integrasi Kamera Smartphone

Skrip ini tidak langsung mengontrol kamera smartphone, tetapi proses alert memungkinkan Anda melakukan langkah berikut:

- Terima notifikasi di smartphone saat peristiwa terjadi
- Buka aplikasi kamera atau CCTV smartphone untuk melihat area pintu
- Atau sambungkan dengan aplikasi home security yang mendukung snapshot/journaling

Untuk integrasi lanjutan, Anda bisa membuat aplikasi smartphone yang menerima webhook kemudian membuka kamera atau memuat URL CCTV.
