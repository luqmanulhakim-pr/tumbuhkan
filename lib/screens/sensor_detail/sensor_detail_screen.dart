import 'package:flutter/material.dart';

class SensorDetailScreen extends StatelessWidget {
  final String sensorName;
  final String sensorUnit;
  final IconData sensorIcon;
  final Color sensorColor;
  final String currentValue;

  const SensorDetailScreen({
    super.key,
    required this.sensorName,
    required this.sensorUnit,
    required this.sensorIcon,
    required this.sensorColor,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from database
    final dummyData = _getDummyData(sensorName);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(sensorIcon, color: sensorColor, size: 24),
            const SizedBox(width: 12),
            Text(
              sensorName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              // TODO: Refresh data from database
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Value Card
            _buildCurrentValueCard(currentValue),
            const SizedBox(height: 24),

            // Section Title
            const Text(
              'Daily Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Average Card
            _buildStatCard(
              label: 'Average',
              value: dummyData['average']!,
              unit: sensorUnit,
              icon: Icons.analytics,
              color: sensorColor,
              time: 'Last 24 hours',
            ),
            const SizedBox(height: 12),

            // Maximum Card
            _buildStatCard(
              label: 'Maximum',
              value: dummyData['max']!,
              unit: sensorUnit,
              icon: Icons.trending_up,
              color: Colors.red,
              time: dummyData['maxTime']!,
            ),
            const SizedBox(height: 12),

            // Minimum Card
            _buildStatCard(
              label: 'Minimum',
              value: dummyData['min']!,
              unit: sensorUnit,
              icon: Icons.trending_down,
              color: Colors.blue,
              time: dummyData['minTime']!,
            ),
            const SizedBox(height: 24),

            // Info Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Current Value Card
  // ============================================
  Widget _buildCurrentValueCard(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2), // ✅ Blue
            const Color(0xFF42A5F5), // ✅ Light Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.3), // ✅ Blue shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Value',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (sensorUnit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 10),
                  child: Text(
                    sensorUnit,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Updated: ${_getCurrentTime()}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Stat Card (Average, Min, Max)
  // ============================================
  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 4),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 16,
                            color: color.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Info Card
  // ============================================
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Statistics are calculated from data collected in the last 24 hours. Data will be updated from the database.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Get Dummy Data (TODO: Replace with database)
  // ============================================
  Map<String, String> _getDummyData(String sensorName) {
    // TODO: Fetch from database
    switch (sensorName) {
      case 'Temperature':
        return {
          'average': '24.5',
          'max': '28.3',
          'min': '21.2',
          'maxTime': 'Today at 14:30',
          'minTime': 'Today at 05:15',
        };
      case 'Humidity':
        return {
          'average': '65.0',
          'max': '78.5',
          'min': '52.0',
          'maxTime': 'Today at 06:00',
          'minTime': 'Today at 15:45',
        };
      case 'Moisture':
        return {
          'average': '70.0',
          'max': '85.0',
          'min': '55.0',
          'maxTime': 'Today at 08:00',
          'minTime': 'Today at 16:30',
        };
      case 'Light':
        return {
          'average': '150',
          'max': '220',
          'min': '80',
          'maxTime': 'Today at 12:00',
          'minTime': 'Today at 06:00',
        };
      case 'pH Level':
        return {
          'average': '6.2',
          'max': '6.8',
          'min': '5.8',
          'maxTime': 'Today at 10:30',
          'minTime': 'Today at 18:00',
        };
      case 'Nutrients':
        return {
          'average': '850',
          'max': '1050',
          'min': '650',
          'maxTime': 'Today at 09:00',
          'minTime': 'Today at 17:30',
        };
      default:
        return {
          'average': '0.0',
          'max': '0.0',
          'min': '0.0',
          'maxTime': 'N/A',
          'minTime': 'N/A',
        };
    }
  }

  // ============================================
  // Get Current Time
  // ============================================
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
