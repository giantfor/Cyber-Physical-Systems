# Cyber-Physical-Systems

Proyek Cyber Physical Systems - Implementasi sistem keamanan pintu berbasis ESP32, LoRa, dan sensor IoT.

## Deskripsi Proyek

Sistem Smart Door Security adalah implementasi ide sistem keamanan pintu berbasis CPS menggunakan ESP32, LoRa, sensor pintu, PIR, dan monitoring melalui server/handphone.

## Struktur Folder

- `smart-door-security/` - Folder utama proyek
  - `esp32_door_security_node/` - Sketch ESP32 node untuk membaca sensor pintu, PIR, dan tegangan baterai
  - `esp32_lora_gateway/` - Sketch ESP32 gateway untuk menerima data LoRa dan mengirimkannya ke server lokal melalui WiFi
  - `server/` - Skrip Python sederhana untuk menerima webhook notifikasi dan mengirim alert ke smartphone
  - `smartphone-webhook-app/` - Aplikasi smartphone berbasis browser untuk menampilkan alert

## Gambar Desain Sistem

### Arsitektur Sistem
<img width="1122" height="1402" alt="overview design" src="https://github.com/user-attachments/assets/6f9fc5f2-0525-442e-a790-3a955603caba" />


### Detailed Architecture
<img width="1672" height="941" alt="detail arsitektur" src="https://github.com/user-attachments/assets/aed296b6-9a96-4680-807c-b4e7e8ce01cc" />


### Diagram Wiring
<img width="1672" height="941" alt="Diagram wiring" src="https://github.com/user-attachments/assets/83778e1d-7929-4684-b5c2-9a72ecec74b7" />



## Fitur

- Deteksi buka/tutup pintu
- Deteksi gerakan di dekat pintu dengan PIR
- Pemantauan tegangan baterai/energi aktual
- Komunikasi nirkabel jarak jauh menggunakan LoRa
- Gateway WiFi untuk mengirim data ke server atau aplikasi smartphone
- Notifikasi alert ke smartphone ketika pintu dibuka atau gerakan terdeteksi

## Dashboard system
<img width="897" height="791" alt="Dashboard" src="https://github.com/user-attachments/assets/f99d3638-7aae-426d-b72e-caa68e39b625" />


## Hardware yang Direkomendasikan

- ESP32 DevKit atau modul ESP32 lain
- Modul LoRa SX1276/78 (misalnya RFM95/96/98)
- Sensor magnet pintu (reed switch)
- Sensor PIR
- Resistor pembagi tegangan untuk pembacaan baterai
- LED/status indicator

## Konfigurasi Gateway

Sebelum mengunggah sketch ke ESP32 gateway, pastikan Anda sudah mengisi nilai berikut di `esp32_lora_gateway/esp32_lora_gateway.ino`:

- `WIFI_SSID` : nama jaringan WiFi Anda
- `WIFI_PASSWORD` : kata sandi WiFi Anda
- `NOTIFICATION_SERVER_URL` : alamat server notifikasi yang menjalankan `server/notification_server.py`

Contoh:

```cpp
const char* WIFI_SSID = "MyHomeWiFi";
const char* WIFI_PASSWORD = "MyPassword123";
const char* NOTIFICATION_SERVER_URL = "http://192.168.1.100:8000/alert";
```

Pastikan komputer/server yang menjalankan `notification_server.py` memiliki alamat IP statis atau alamat yang dapat diakses dari ESP32 gateway.

## Petunjuk Umum

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

## Aplikasi Smartphone

<img width="1672" height="941" alt="Arsitektur Mobile" src="https://github.com/user-attachments/assets/160a234c-7b5d-4520-8b51-e40eca9abc83" />

## Mockup

<img width="941" height="1672" alt="mockup-1" src="https://github.com/user-attachments/assets/4431a379-ca7d-4288-ba19-26bf2c4150b9" />

