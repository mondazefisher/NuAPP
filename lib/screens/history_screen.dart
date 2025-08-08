import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nourishlens/models/models.dart';
import 'package:nourishlens/services/storage_service.dart';
import 'package:nourishlens/services/nutrition_service.dart';
import 'package:nourishlens/screens/daily_summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyNutrition> _history = [];
  bool _isLoading = true;
  String _selectedMetric = 'Calories';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final history = await StorageService.getDailyNutritionHistory();
    
    // Generate last 7 days if no data exists
    if (history.isEmpty) {
      final today = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        await NutritionService.calculateDailyNutrition(date);
      }
      final updatedHistory = await StorageService.getDailyNutritionHistory();
      setState(() {
        _history = updatedHistory.take(7).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _history = history.take(7).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Trends'),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadHistory,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarView(),
                  const SizedBox(height: 24),
                  _buildTrendChart(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Days',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (_history.isEmpty)
              _buildEmptyHistoryState()
            else
              ..._history.reversed.map((nutrition) => 
                  _buildDayCard(nutrition)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No nutrition data yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging meals to see your history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyNutrition nutrition) {
    final isToday = _isToday(nutrition.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isToday 
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailySummaryScreen(nutrition: nutrition),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    nutrition.date.day.toString(),
                    style: TextStyle(
                      color: isToday 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(nutrition.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isToday 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                      ),
                    ),
                    Text(
                      '${nutrition.totalCalories.round()} cal • ${nutrition.totalProtein.round()}g protein',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isToday 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isToday 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  underline: const SizedBox.shrink(),
                  items: ['Calories', 'Protein', 'Carbs', 'Fat']
                      .map((metric) => DropdownMenuItem(
                            value: metric,
                            child: Text(metric),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMetric = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getChartInterval(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _history.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getDayAbbr(_history[index].date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getChartSpots(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    return _history.asMap().entries.map((entry) {
      final index = entry.key;
      final nutrition = entry.value;
      double value;

      switch (_selectedMetric) {
        case 'Protein':
          value = nutrition.totalProtein;
          break;
        case 'Carbs':
          value = nutrition.totalCarbs;
          break;
        case 'Fat':
          value = nutrition.totalFat;
          break;
        default:
          value = nutrition.totalCalories;
      }

      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  double _getChartInterval() {
    switch (_selectedMetric) {
      case 'Protein':
      case 'Carbs':
      case 'Fat':
        return 20;
      default:
        return 500;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) return 'Today';
    
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';
  }

  String _getDayAbbr(DateTime date) {
    const dayAbbr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayAbbr[date.weekday - 1];
  }
}