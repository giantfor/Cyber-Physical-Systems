#!/usr/bin/env python3
import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

# Jika ingin mengirim notifikasi smartphone, masukkan token Pushover di sini.
PUSHOVER_TOKEN = ''
PUSHOVER_USER = ''

ALERT_STORAGE_PATH = os.path.join(os.path.dirname(__file__), '..', 'smartphone-webhook-app', 'latest_alert.json')

try:
    import requests
except ImportError:
    requests = None

HOST = '0.0.0.0'
PORT = 8000

class NotificationHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        try:
            data = json.loads(body.decode('utf-8'))
        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid JSON')
            return

        message = data.get('message', 'No message')
        print(f'[ALERT] {message}')
        self.save_latest_alert(message)

        if PUSHOVER_TOKEN and PUSHOVER_USER and requests:
            self.send_pushover(message)

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status': 'ok', 'message': message}).encode('utf-8'))

    def save_latest_alert(self, message: str):
        try:
            alerts = []
            if os.path.exists(ALERT_STORAGE_PATH):
                with open(ALERT_STORAGE_PATH, 'r', encoding='utf-8') as f:
                    existing = json.load(f)
                    alerts = existing.get('alerts', [])

            alerts.insert(0, message)
            alerts = alerts[:20]
            alert_data = {
                'alerts': alerts,
                'last_timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            os.makedirs(os.path.dirname(ALERT_STORAGE_PATH), exist_ok=True)
            with open(ALERT_STORAGE_PATH, 'w', encoding='utf-8') as f:
                json.dump(alert_data, f)
        except Exception as exc:
            print(f'[WARN] Tidak dapat menyimpan alert: {exc}')

    def send_pushover(self, message: str):
        if not requests:
            print('[WARN] requests tidak tersedia, tidak bisa kirim Pushover')
            return
        payload = {
            'token': PUSHOVER_TOKEN,
            'user': PUSHOVER_USER,
            'message': message,
            'title': 'Smart Door Alert',
            'priority': 1,
        }
        resp = requests.post('https://api.pushover.net/1/messages.json', data=payload)
        print(f'[PUSHOVER] status={resp.status_code} body={resp.text}')

    def log_message(self, format, *args):
        return

if __name__ == '__main__':
    server = HTTPServer((HOST, PORT), NotificationHandler)
    print(f'[SERVER] Menjalankan server notifikasi di http://{HOST}:{PORT}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[SERVER] Berhenti')
        server.server_close()
