#include <SPI.h>
#include <LoRa.h>

// Pin koneksi LoRa (sesuaikan dengan board / modul Anda)
#define LORA_SCK 5
#define LORA_MISO 19
#define LORA_MOSI 27
#define LORA_SS 18
#define LORA_RST 14
#define LORA_DIO0 26
#define LORA_BAND 915E6

// Sensor / indikator
const int DOOR_SENSOR_PIN = 34;    // Reed switch pintu
const int PIR_PIN = 35;            // Sensor gerak PIR
const int BATTERY_PIN = 32;        // ADC untuk pemantauan baterai
const int STATUS_LED_PIN = 2;      // LED status built-in

const int NODE_ID = 1;
const unsigned long REPORT_INTERVAL = 30000; // 30 detik

bool lastDoorState = HIGH;
bool lastMotionState = LOW;
float lastVoltage = 0.0;
unsigned long lastReport = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(DOOR_SENSOR_PIN, INPUT_PULLUP);
  pinMode(PIR_PIN, INPUT);
  pinMode(STATUS_LED_PIN, OUTPUT);
  digitalWrite(STATUS_LED_PIN, LOW);

  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  if (!LoRa.begin(LORA_BAND)) {
    Serial.println("[ERROR] Gagal inisialisasi LoRa");
    while (true) {
      digitalWrite(STATUS_LED_PIN, millis() % 500 < 250);
      delay(100);
    }
  }

  Serial.println("[INFO] Node keamanan pintu LoRa siap");
  digitalWrite(STATUS_LED_PIN, HIGH);
  delay(500);
  digitalWrite(STATUS_LED_PIN, LOW);
}

void loop() {
  bool doorState = digitalRead(DOOR_SENSOR_PIN);
  bool motionState = digitalRead(PIR_PIN);
  float batteryVoltage = readBatteryVoltage();
  unsigned long now = millis();

  bool changed = (doorState != lastDoorState) || (motionState != lastMotionState);
  bool intervalElapsed = (now - lastReport) >= REPORT_INTERVAL;

  if (changed || intervalElapsed) {
    sendStatus(doorState, motionState, batteryVoltage);
    lastDoorState = doorState;
    lastMotionState = motionState;
    lastVoltage = batteryVoltage;
    lastReport = now;
  }

  delay(100);
}

float readBatteryVoltage() {
  const float VREF = 3.3;
  const float R1 = 100000.0; // ohm
  const float R2 = 100000.0; // ohm
  int raw = analogRead(BATTERY_PIN);
  float voltage = ((float)raw / 4095.0) * VREF;
  voltage = voltage * (R1 + R2) / R2;
  return voltage;
}

void sendStatus(bool doorState, bool motionState, float batteryVoltage) {
  String doorText = doorState == LOW ? "OPEN" : "CLOSED";
  String motionText = motionState ? "MOTION" : "CLEAR";

  String payload = "NODE=" + String(NODE_ID);
  payload += ";DOOR=" + doorText;
  payload += ";MOTION=" + motionText;
  payload += ";VOLT=" + String(batteryVoltage, 2);
  payload += ";TS=" + String(millis());

  Serial.println("[SEND] " + payload);
  LoRa.beginPacket();
  LoRa.print(payload);
  LoRa.endPacket();

  digitalWrite(STATUS_LED_PIN, HIGH);
  delay(100);
  digitalWrite(STATUS_LED_PIN, LOW);
}
