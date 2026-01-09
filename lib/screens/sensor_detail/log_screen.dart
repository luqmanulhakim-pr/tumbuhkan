import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/log_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late LogService _logService;

  @override
  void initState() {
    super.initState();
    _logService = LogService();
    _logService.fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _logService,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: Consumer<LogService>(
          builder: (context, logService, _) {
            if (logService.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF29ABFF)),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(logService),
                  if (logService.error != null)
                    _buildErrorBanner(logService.error!),
                  _buildChartCard(
                    title: 'pH Level',
                    data: logService.getChartData('ph'),
                    logs: logService.logs,
                    color: const Color(0xFF9C27B0),
                    unit: '',
                    minY: 0,
                    maxY: 14,
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'TDS (Nutrisi)',
                    data: logService.getChartData('tds'),
                    logs: logService.logs,
                    color: const Color(0xFFFFC107),
                    unit: 'ppm',
                    minY: 0,
                    maxY: 2000,
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'Suhu Air',
                    data: logService.getChartData('temp_air'),
                    logs: logService.logs,
                    color: const Color(0xFF29ABFF),
                    unit: '°C',
                    minY: 15,
                    maxY: 35,
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'Suhu Udara',
                    data: logService.getChartData('temp_udara'),
                    logs: logService.logs,
                    color: const Color(0xFFFF5722),
                    unit: '°C',
                    minY: 15,
                    maxY: 40,
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'Kelembaban',
                    data: logService.getChartData('humidity'),
                    logs: logService.logs,
                    color: const Color(0xFF00BCD4),
                    unit: '%',
                    minY: 0,
                    maxY: 100,
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(
                    title: 'Intensitas Cahaya',
                    data: logService.getChartData('ldr'),
                    logs: logService.logs,
                    color: const Color(0xFF4CAF50),
                    unit: 'lux',
                    minY: 0,
                    maxY: 4000,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF29ABFF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Sensor Log',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _logService.fetchLogs(),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(LogService logService) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodButton('daily', 'Harian', logService),
          _buildPeriodButton('weekly', 'Mingguan', logService),
          _buildPeriodButton('monthly', 'Bulanan', logService),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
      String period, String label, LogService logService) {
    final isSelected = logService.selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => logService.setPeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF29ABFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.orange[800], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required List<double> data,
    required List<SensorLog> logs,
    required Color color,
    required String unit,
    required double minY,
    required double maxY,
  }) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No data for $title',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Calculate stats
    final avg = data.reduce((a, b) => a + b) / data.length;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Avg: ${avg.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip('Min', min, unit, Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip('Max', max, unit, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: data.length.toDouble() - 1,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      data.length,
                      (i) => FlSpot(i.toDouble(), data[i]),
                    ),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        String timestamp = '';
                        if (index >= 0 && index < logs.length) {
                          final dt = logs[index].createdAt;
                          timestamp =
                              '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} $unit\n$timestamp',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)} $unit',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
