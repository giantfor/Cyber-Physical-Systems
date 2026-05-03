#!/usr/bin/env python3
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

ALERT_FILE = os.path.join(os.path.dirname(__file__), 'latest_alert.json')

class WebhookAppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/' or self.path == '/index.html':
            self.send_file('index.html', 'text/html')
        elif self.path == '/alert':
            self.send_alert_json()
        else:
            self.send_response(404)
            self.end_headers()

    def send_file(self, filename, content_type):
        path = os.path.join(os.path.dirname(__file__), filename)
        try:
            with open(path, 'rb') as f:
                data = f.read()
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except FileNotFoundError:
            self.send_response(404)
            self.end_headers()

    def send_alert_json(self):
        alerts = []
        last_timestamp = ''
        if os.path.exists(ALERT_FILE):
            with open(ALERT_FILE, 'r', encoding='utf-8') as f:
                data = json.load(f)
                alerts = data.get('alerts', [])
                last_timestamp = data.get('last_timestamp', '')

        payload = {
            'alerts': alerts,
            'last_timestamp': last_timestamp,
        }

        body = json.dumps(payload).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return

if __name__ == '__main__':
    port = 8080
    server = HTTPServer(('0.0.0.0', port), WebhookAppHandler)
    print(f'[SMARTPHONE APP] Buka browser smartphone ke http://<server-ip>:{port}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[SMARTPHONE APP] Berhenti')
        server.server_close()
