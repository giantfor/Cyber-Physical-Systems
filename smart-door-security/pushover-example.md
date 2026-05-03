# Contoh Konfigurasi Pushover

Pushover adalah layanan notifikasi push sederhana yang cocok untuk menerima alert di smartphone.

## 1. Daftar akun Pushover
- Buka https://pushover.net/ dan buat akun.
- Catat `User Key` dan `API Token/Key`.

## 2. Isi token di `server/notification_server.py`

Cari baris berikut:

```python
PUSHOVER_TOKEN = ''
PUSHOVER_USER = ''
```

ganti dengan nilai Anda:

```python
PUSHOVER_TOKEN = 'YOUR_API_TOKEN'
PUSHOVER_USER = 'YOUR_USER_KEY'
```

## 3. Instal library `requests`

Jalankan:

```bash
pip install requests
```

## 4. Periksa output notifikasi
- Jalankan server:

```bash
python3 smart-door-security/server/notification_server.py
```

- Gateway ESP32 akan mengirim POST ke server.
- Jika Pushover benar, Anda akan menerima notifikasi di smartphone dengan judul `Smart Door Alert`.

## 5. Contoh payload
`notification_server.py` mengirim payload ini ke Pushover:

```python
payload = {
    'token': PUSHOVER_TOKEN,
    'user': PUSHOVER_USER,
    'message': message,
    'title': 'Smart Door Alert',
    'priority': 1,
}
```

## 6. Saran penggunaan
- Gunakan prioritas `1` agar notifikasi tampil jelas.
- Anda bisa menambahkan `url` dan `url_title` jika ingin membuka halaman live camera atau dashboard.
- Contoh tambahan:

```python
payload['url'] = 'https://your-camera-url.local'
payload['url_title'] = 'Lihat Kamera'
```
