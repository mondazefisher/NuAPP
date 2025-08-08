import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nourishlens/models/models.dart';
import 'package:nourishlens/services/nutrition_service.dart';
import 'package:nourishlens/services/storage_service.dart';

class DailySummaryScreen extends StatefulWidget {
  final DailyNutrition? nutrition;

  const DailySummaryScreen({super.key, this.nutrition});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  DailyNutrition? _nutrition;
  NutritionGoals? _goals;
  List<DeficiencyAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final nutrition = widget.nutrition ?? 
        await NutritionService.calculateDailyNutrition(DateTime.now());
    
    final profile = await StorageService.getUserProfile();
    final goals = NutritionGoals.getDefaultGoals(profile);
    
    final alerts = NutritionService.getDeficiencyAlerts(nutrition, goals);
    
    setState(() {
      _nutrition = nutrition;
      _goals = goals;
      _alerts = alerts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMacrosChart(),
                  const SizedBox(height: 24),
                  _buildDeficiencyAlerts(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMacrosChart() {
    if (_nutrition == null || _goals == null) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Macronutrients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _buildPieChartSections(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildMacrosLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final totalCalories = _nutrition!.totalCalories;
    final proteinCals = _nutrition!.totalProtein * 4;
    final carbsCals = _nutrition!.totalCarbs * 4;
    final fatCals = _nutrition!.totalFat * 9;

    return [
      PieChartSectionData(
        color: Theme.of(context).colorScheme.primary,
        value: proteinCals,
        title: '${(proteinCals / totalCalories * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Theme.of(context).colorScheme.secondary,
        value: carbsCals,
        title: '${(carbsCals / totalCalories * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Theme.of(context).colorScheme.tertiary,
        value: fatCals,
        title: '${(fatCals / totalCalories * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildMacrosLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          color: Theme.of(context).colorScheme.primary,
          label: 'Protein',
          value: '${_nutrition!.totalProtein.round()}g',
        ),
        _buildLegendItem(
          color: Theme.of(context).colorScheme.secondary,
          label: 'Carbs',
          value: '${_nutrition!.totalCarbs.round()}g',
        ),
        _buildLegendItem(
          color: Theme.of(context).colorScheme.tertiary,
          label: 'Fat',
          value: '${_nutrition!.totalFat.round()}g',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDeficiencyAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Goals Progress',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final alert = _alerts[index];
            return _buildAlertCard(alert);
          },
        ),
      ],
    );
  }

  Widget _buildAlertCard(DeficiencyAlert alert) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (alert.status) {
      case DeficiencyStatus.met:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Goal Met';
        break;
      case DeficiencyStatus.close:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Close to Goal';
        break;
      case DeficiencyStatus.low:
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error;
        statusText = 'Below Goal';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.nutrient,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${alert.current.round()} ${alert.unit}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${alert.percentage}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${alert.target.round()} ${alert.unit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: alert.percentage / 100,
              backgroundColor: statusColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
            if (alert.status == DeficiencyStatus.low) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSuggestion(alert.nutrient),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSuggestion(String nutrient) {
    switch (nutrient) {
      case 'Protein':
        return 'Try adding chicken breast, salmon, or eggs to boost your protein intake.';
      case 'Calcium':
        return 'Consider dairy products like milk or yogurt, or leafy greens like spinach.';
      case 'Iron':
        return 'Include spinach, lean red meat, or fortified cereals in your meals.';
      case 'Vitamin C':
        return 'Add citrus fruits, broccoli, or bell peppers to your diet.';
      case 'Vitamin D':
        return 'Try fatty fish like salmon, fortified milk, or consider supplements.';
      case 'Fiber':
        return 'Include more whole grains, fruits, and vegetables in your meals.';
      default:
        return 'Consider foods rich in ${nutrient.toLowerCase()} to meet your daily goal.';
    }
  }
}