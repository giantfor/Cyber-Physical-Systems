#include <SPI.h>
#include <LoRa.h>
#include <WiFi.h>
#include <HTTPClient.h>

// WiFi credentials
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Alamat server notifikasi local
const char* NOTIFICATION_SERVER_URL = "http://192.168.1.100:8000/alert";

// LoRa pin connection (sesuaikan board Anda)
#define LORA_SCK 5
#define LORA_MISO 19
#define LORA_MOSI 27
#define LORA_SS 18
#define LORA_RST 14
#define LORA_DIO0 26
#define LORA_BAND 915E6

void setup() {
  Serial.begin(115200);
  delay(1000);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("[WIFI] Menghubungkan ke WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("[WIFI] Terhubung, IP: ");
  Serial.println(WiFi.localIP());

  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  if (!LoRa.begin(LORA_BAND)) {
    Serial.println("[ERROR] Gagal inisialisasi LoRa");
    while (true) {
      delay(1000);
    }
  }
  LoRa.receive();
  Serial.println("[INFO] Gateway LoRa siap menerima paket");
}

void loop() {
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    String packet = "";
    while (LoRa.available()) {
      packet += (char)LoRa.read();
    }

    Serial.print("[RECV] ");
    Serial.println(packet);
    sendAlertToServer(packet);
  }
}

void sendAlertToServer(const String& message) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[WARN] WiFi tidak terhubung, mencoba reconnect...");
    WiFi.reconnect();
    delay(1000);
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("[ERROR] Gagal reconnect WiFi");
      return;
    }
  }

  HTTPClient http;
  http.begin(NOTIFICATION_SERVER_URL);
  http.addHeader("Content-Type", "application/json");

  String payload = "{\"message\":\"" + message + "\"}";
  int statusCode = http.POST(payload);

  Serial.print("[HTTP] POST ");
  Serial.print(NOTIFICATION_SERVER_URL);
  Serial.print(" -> ");
  Serial.println(statusCode);

  if (statusCode > 0) {
    Serial.print("[HTTP] response: ");
    Serial.println(http.getString());
  } else {
    Serial.print("[ERROR] HTTP POST gagal: ");
    Serial.println(http.errorToString(statusCode).c_str());
  }

  http.end();
}
