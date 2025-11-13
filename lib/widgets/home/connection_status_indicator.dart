import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: mqtt.isConnected
            ? const Color(0xFF1976D2).withOpacity(0.1) // ✅ Blue background
            : mqtt.hasError
                ? Colors.red[50]
                : Colors.orange[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: mqtt.isConnected
              ? const Color(0xFF1976D2) // ✅ Blue border
              : mqtt.hasError
                  ? Colors.red
                  : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mqtt.isConnected
                  ? const Color(0xFF1976D2) // ✅ Blue dot
                  : mqtt.hasError
                      ? Colors.red
                      : Colors.orange,
            ),
          ),
          const SizedBox(width: 10),

          // Status Text
          Text(
            mqtt.isConnected
                ? 'Connected'
                : mqtt.hasError
                    ? 'Connection Error'
                    : 'Reconnecting...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: mqtt.isConnected
                  ? const Color(0xFF1976D2) // ✅ Blue text
                  : mqtt.hasError
                      ? Colors.red[700]
                      : Colors.orange[700],
            ),
          ),

          // Loading indicator (when reconnecting)
          if (!mqtt.isConnected && !mqtt.hasError) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
