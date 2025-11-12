import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../services/mqtt_connection_state.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MqttService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(mqttService.connectionState),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mqttService.connectionState.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            mqttService.connectionState.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (mqttService.isConnecting) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(AppMqttConnectionState state) {
    switch (state) {
      case AppMqttConnectionState.connected:
        return const Color(0xFF4CAF50);
      case AppMqttConnectionState.connecting:
        return const Color(0xFFFFC107);
      case AppMqttConnectionState.disconnected:
        return const Color(0xFF9E9E9E);
      case AppMqttConnectionState.error:
        return const Color(0xFFF44336);
    }
  }
}
