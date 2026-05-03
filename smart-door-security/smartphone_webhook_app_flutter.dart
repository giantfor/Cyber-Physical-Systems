import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartDoorWebhookApp());
}

class SmartDoorWebhookApp extends StatelessWidget {
  const SmartDoorWebhookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Door Alert',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5CFF),
          brightness: Brightness.light,
        ),
      ),
      home: const AlertDashboardPage(),
    );
  }
}

class AlertItem {
  final String title;
  final String message;
  final DateTime time;
  final AlertType type;

  const AlertItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });
}

enum AlertType { safe, warning, danger, info }

class AlertDashboardPage extends StatefulWidget {
  const AlertDashboardPage({super.key});

  @override
  State<AlertDashboardPage> createState() => _AlertDashboardPageState();
}

class _AlertDashboardPageState extends State<AlertDashboardPage> {
  bool isDoorLocked = true;
  bool isConnected = true;
  int battery = 86;
  int signal = 94;

  final List<AlertItem> alerts = [
    AlertItem(
      title: 'Pintu Terkunci',
      message: 'Sistem mengunci pintu utama secara otomatis.',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      type: AlertType.safe,
    ),
    AlertItem(
      title: 'Data LoRa Diterima',
      message: 'Gateway menerima paket sensor dari ESP32 node.',
      time: DateTime.now().subtract(const Duration(minutes: 8)),
      type: AlertType.info,
    ),
    AlertItem(
      title: 'Gerakan Terdeteksi',
      message: 'Sensor PIR mendeteksi aktivitas di area pintu.',
      time: DateTime.now().subtract(const Duration(minutes: 16)),
      type: AlertType.warning,
    ),
  ];

  Timer? simulator;

  @override
  void initState() {
    super.initState();

    // Simulator alert lokal.
    // Untuk webhook sungguhan, bagian ini bisa diganti dengan Firebase Messaging,
    // WebSocket, MQTT client, atau polling API dari server.
    simulator = Timer.periodic(const Duration(seconds: 12), (_) {
      _addIncomingAlert();
    });
  }

  @override
  void dispose() {
    simulator?.cancel();
    super.dispose();
  }

  void _addIncomingAlert() {
    final simulatedAlerts = [
      AlertItem(
        title: 'Webhook Alert Masuk',
        message: 'Server mengirim notifikasi baru ke aplikasi.',
        time: DateTime.now(),
        type: AlertType.info,
      ),
      AlertItem(
        title: 'Pintu Dibuka',
        message: 'Reed switch mendeteksi pintu dalam kondisi terbuka.',
        time: DateTime.now(),
        type: AlertType.warning,
      ),
      AlertItem(
        title: 'Akses Mencurigakan',
        message: 'Percobaan akses tidak dikenal terdeteksi.',
        time: DateTime.now(),
        type: AlertType.danger,
      ),
    ];

    simulatedAlerts.shuffle();

    setState(() {
      alerts.insert(0, simulatedAlerts.first);
      if (alerts.length > 8) alerts.removeLast();
    });
  }

  void _toggleDoorLock() {
    setState(() {
      isDoorLocked = !isDoorLocked;
      alerts.insert(
        0,
        AlertItem(
          title: isDoorLocked ? 'Pintu Dikunci' : 'Pintu Dibuka',
          message: isDoorLocked
              ? 'Perintah kunci berhasil dikirim dari aplikasi.'
              : 'Perintah buka kunci berhasil dikirim dari aplikasi.',
          time: DateTime.now(),
          type: isDoorLocked ? AlertType.safe : AlertType.warning,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: _HeaderCard(isConnected: isConnected),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DoorStatusCard(
                  isDoorLocked: isDoorLocked,
                  battery: battery,
                  signal: signal,
                  onToggle: _toggleDoorLock,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alert Terbaru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addIncomingAlert,
                      icon: const Icon(Icons.add_alert_rounded),
                      label: const Text('Simulasi'),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _AlertTile(alert: alerts[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isConnected;

  const _HeaderCard({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF071A33), Color(0xFF0B3D75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071A33).withOpacity(0.20),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Door Security',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Smartphone Webhook Alert App',
                      style: TextStyle(
                        color: Color(0xFF9EEAFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusPill(
                icon: Icons.cloud_done_rounded,
                label: isConnected ? 'Online' : 'Offline',
                color: isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              const _StatusPill(
                icon: Icons.sensors_rounded,
                label: 'LoRa Aktif',
                color: Color(0xFF22D3EE),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoorStatusCard extends StatelessWidget {
  final bool isDoorLocked;
  final int battery;
  final int signal;
  final VoidCallback onToggle;

  const _DoorStatusCard({
    required this.isDoorLocked,
    required this.battery,
    required this.signal,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isDoorLocked ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [statusColor, const Color(0xFF0B5CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isDoorLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDoorLocked ? 'Pintu Terkunci' : 'Pintu Terbuka',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDoorLocked
                          ? 'Status aman, sensor aktif.'
                          : 'Periksa kondisi pintu sekarang.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Baterai',
                  value: '$battery%',
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBox(
                  icon: Icons.wifi_tethering_rounded,
                  label: 'Sinyal',
                  value: '$signal%',
                  color: const Color(0xFF0B5CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onToggle,
              icon: Icon(isDoorLocked ? Icons.lock_open_rounded : Icons.lock_rounded),
              label: Text(isDoorLocked ? 'Buka Kunci' : 'Kunci Pintu'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B5CFF),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertItem alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final config = _alertConfig(alert.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(config.icon, color: config.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatTime(alert.time),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  _AlertConfig _alertConfig(AlertType type) {
    switch (type) {
      case AlertType.safe:
        return const _AlertConfig(Icons.check_circle_rounded, Color(0xFF22C55E));
      case AlertType.warning:
        return const _AlertConfig(Icons.warning_amber_rounded, Color(0xFFF59E0B));
      case AlertType.danger:
        return const _AlertConfig(Icons.error_rounded, Color(0xFFEF4444));
      case AlertType.info:
        return const _AlertConfig(Icons.notifications_active_rounded, Color(0xFF0B5CFF));
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AlertConfig {
  final IconData icon;
  final Color color;

  const _AlertConfig(this.icon, this.color);
}
