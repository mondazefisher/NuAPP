import 'package:nourishlens/models/models.dart';
import 'package:nourishlens/services/storage_service.dart';

class NutritionService {
  static final Map<String, FoodItem> _foodDatabase = {
    'apple': FoodItem(
      name: 'Apple',
      portionSize: 100,
      calories: 52,
      protein: 0.3,
      carbs: 14,
      fat: 0.2,
      fiber: 2.4,
      calcium: 6,
      iron: 0.1,
      vitaminC: 4.6,
      vitaminD: 0,
    ),
    'banana': FoodItem(
      name: 'Banana',
      portionSize: 100,
      calories: 89,
      protein: 1.1,
      carbs: 23,
      fat: 0.3,
      fiber: 2.6,
      calcium: 5,
      iron: 0.3,
      vitaminC: 8.7,
      vitaminD: 0,
    ),
    'chicken breast': FoodItem(
      name: 'Chicken Breast',
      portionSize: 100,
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
      fiber: 0,
      calcium: 15,
      iron: 0.9,
      vitaminC: 0,
      vitaminD: 0.2,
    ),
    'salmon': FoodItem(
      name: 'Salmon',
      portionSize: 100,
      calories: 208,
      protein: 25,
      carbs: 0,
      fat: 12,
      fiber: 0,
      calcium: 9,
      iron: 0.3,
      vitaminC: 0,
      vitaminD: 11,
    ),
    'broccoli': FoodItem(
      name: 'Broccoli',
      portionSize: 100,
      calories: 34,
      protein: 2.8,
      carbs: 7,
      fat: 0.4,
      fiber: 2.6,
      calcium: 47,
      iron: 0.7,
      vitaminC: 89,
      vitaminD: 0,
    ),
    'spinach': FoodItem(
      name: 'Spinach',
      portionSize: 100,
      calories: 23,
      protein: 2.9,
      carbs: 3.6,
      fat: 0.4,
      fiber: 2.2,
      calcium: 99,
      iron: 2.7,
      vitaminC: 28,
      vitaminD: 0,
    ),
    'rice': FoodItem(
      name: 'White Rice',
      portionSize: 100,
      calories: 130,
      protein: 2.7,
      carbs: 28,
      fat: 0.3,
      fiber: 0.4,
      calcium: 28,
      iron: 0.8,
      vitaminC: 0,
      vitaminD: 0,
    ),
    'milk': FoodItem(
      name: 'Milk',
      portionSize: 100,
      calories: 42,
      protein: 3.4,
      carbs: 5,
      fat: 1,
      fiber: 0,
      calcium: 113,
      iron: 0.03,
      vitaminC: 0,
      vitaminD: 1.3,
    ),
    'egg': FoodItem(
      name: 'Egg',
      portionSize: 100,
      calories: 155,
      protein: 13,
      carbs: 1.1,
      fat: 11,
      fiber: 0,
      calcium: 56,
      iron: 1.8,
      vitaminC: 0,
      vitaminD: 2,
    ),
    'bread': FoodItem(
      name: 'Whole Wheat Bread',
      portionSize: 100,
      calories: 247,
      protein: 13,
      carbs: 41,
      fat: 4.2,
      fiber: 7,
      calcium: 107,
      iron: 2.5,
      vitaminC: 0,
      vitaminD: 0,
    ),
  };

  static List<String> getSuggestedFoods() => _foodDatabase.keys.toList();

  static FoodItem? getFoodByName(String name) {
    final key = name.toLowerCase();
    return _foodDatabase[key];
  }

  static FoodItem createCustomFood(String name, {
    double calories = 100,
    double protein = 5,
    double carbs = 15,
    double fat = 5,
  }) => FoodItem(
    name: name,
    portionSize: 100,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: 2,
    calcium: 50,
    iron: 1,
    vitaminC: 5,
    vitaminD: 0,
  );

  static Future<DailyNutrition> calculateDailyNutrition(DateTime date) async {
    final photos = await StorageService.getMealPhotos();
    final dayPhotos = photos.where((photo) => 
      photo.timestamp.year == date.year &&
      photo.timestamp.month == date.month &&
      photo.timestamp.day == date.day
    ).toList();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalCalcium = 0;
    double totalIron = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;

    for (final photo in dayPhotos) {
      for (final food in photo.recognizedFoods) {
        final multiplier = food.portionSize / 100;
        totalCalories += food.calories * multiplier;
        totalProtein += food.protein * multiplier;
        totalCarbs += food.carbs * multiplier;
        totalFat += food.fat * multiplier;
        totalFiber += food.fiber * multiplier;
        totalCalcium += food.calcium * multiplier;
        totalIron += food.iron * multiplier;
        totalVitaminC += food.vitaminC * multiplier;
        totalVitaminD += food.vitaminD * multiplier;
      }
    }

    final nutrition = DailyNutrition(
      date: date,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      totalCalcium: totalCalcium,
      totalIron: totalIron,
      totalVitaminC: totalVitaminC,
      totalVitaminD: totalVitaminD,
    );

    await StorageService.saveDailyNutrition(nutrition);
    return nutrition;
  }

  static List<DeficiencyAlert> getDeficiencyAlerts(
    DailyNutrition nutrition,
    NutritionGoals goals,
  ) {
    final alerts = <DeficiencyAlert>[];

    final checks = [
      (nutrition.totalCalories, goals.dailyCalories, 'Calories', 'kcal'),
      (nutrition.totalProtein, goals.dailyProtein, 'Protein', 'g'),
      (nutrition.totalCarbs, goals.dailyCarbs, 'Carbohydrates', 'g'),
      (nutrition.totalFat, goals.dailyFat, 'Fat', 'g'),
      (nutrition.totalFiber, goals.dailyFiber, 'Fiber', 'g'),
      (nutrition.totalCalcium, goals.dailyCalcium, 'Calcium', 'mg'),
      (nutrition.totalIron, goals.dailyIron, 'Iron', 'mg'),
      (nutrition.totalVitaminC, goals.dailyVitaminC, 'Vitamin C', 'mg'),
      (nutrition.totalVitaminD, goals.dailyVitaminD, 'Vitamin D', 'μg'),
    ];

    for (final (actual, target, name, unit) in checks) {
      final percentage = (actual / target * 100).round();
      final status = percentage >= 100 ? DeficiencyStatus.met
          : percentage >= 70 ? DeficiencyStatus.close
          : DeficiencyStatus.low;

      alerts.add(DeficiencyAlert(
        nutrient: name,
        current: actual,
        target: target,
        percentage: percentage,
        status: status,
        unit: unit,
      ));
    }

    return alerts;
  }
}

enum DeficiencyStatus { met, close, low }

class DeficiencyAlert {
  final String nutrient;
  final double current;
  final double target;
  final int percentage;
  final DeficiencyStatus status;
  final String unit;

  DeficiencyAlert({
    required this.nutrient,
    required this.current,
    required this.target,
    required this.percentage,
    required this.status,
    required this.unit,
  });
}