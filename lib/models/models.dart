class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String activityLevel;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'weight': weight,
    'height': height,
    'activityLevel': activityLevel,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    age: json['age'] ?? 0,
    gender: json['gender'] ?? 'other',
    weight: json['weight']?.toDouble() ?? 0.0,
    height: json['height']?.toDouble() ?? 0.0,
    activityLevel: json['activityLevel'] ?? 'moderate',
  );
}

class MealPhoto {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final List<FoodItem> recognizedFoods;

  MealPhoto({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.recognizedFoods,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'recognizedFoods': recognizedFoods.map((f) => f.toJson()).toList(),
  };

  factory MealPhoto.fromJson(Map<String, dynamic> json) => MealPhoto(
    id: json['id'] ?? '',
    imagePath: json['imagePath'] ?? '',
    timestamp: DateTime.parse(json['timestamp']),
    recognizedFoods: (json['recognizedFoods'] as List?)
        ?.map((f) => FoodItem.fromJson(f))
        .toList() ?? [],
  );
}

class FoodItem {
  final String name;
  final double portionSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double calcium;
  final double iron;
  final double vitaminC;
  final double vitaminD;

  FoodItem({
    required this.name,
    required this.portionSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.calcium,
    required this.iron,
    required this.vitaminC,
    required this.vitaminD,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'portionSize': portionSize,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'calcium': calcium,
    'iron': iron,
    'vitaminC': vitaminC,
    'vitaminD': vitaminD,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    name: json['name'] ?? '',
    portionSize: json['portionSize']?.toDouble() ?? 100.0,
    calories: json['calories']?.toDouble() ?? 0.0,
    protein: json['protein']?.toDouble() ?? 0.0,
    carbs: json['carbs']?.toDouble() ?? 0.0,
    fat: json['fat']?.toDouble() ?? 0.0,
    fiber: json['fiber']?.toDouble() ?? 0.0,
    calcium: json['calcium']?.toDouble() ?? 0.0,
    iron: json['iron']?.toDouble() ?? 0.0,
    vitaminC: json['vitaminC']?.toDouble() ?? 0.0,
    vitaminD: json['vitaminD']?.toDouble() ?? 0.0,
  );
}

class DailyNutrition {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalCalcium;
  final double totalIron;
  final double totalVitaminC;
  final double totalVitaminD;

  DailyNutrition({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalCalcium,
    required this.totalIron,
    required this.totalVitaminC,
    required this.totalVitaminD,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalCalories': totalCalories,
    'totalProtein': totalProtein,
    'totalCarbs': totalCarbs,
    'totalFat': totalFat,
    'totalFiber': totalFiber,
    'totalCalcium': totalCalcium,
    'totalIron': totalIron,
    'totalVitaminC': totalVitaminC,
    'totalVitaminD': totalVitaminD,
  };

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
    date: DateTime.parse(json['date']),
    totalCalories: json['totalCalories']?.toDouble() ?? 0.0,
    totalProtein: json['totalProtein']?.toDouble() ?? 0.0,
    totalCarbs: json['totalCarbs']?.toDouble() ?? 0.0,
    totalFat: json['totalFat']?.toDouble() ?? 0.0,
    totalFiber: json['totalFiber']?.toDouble() ?? 0.0,
    totalCalcium: json['totalCalcium']?.toDouble() ?? 0.0,
    totalIron: json['totalIron']?.toDouble() ?? 0.0,
    totalVitaminC: json['totalVitaminC']?.toDouble() ?? 0.0,
    totalVitaminD: json['totalVitaminD']?.toDouble() ?? 0.0,
  );
}

class NutritionGoals {
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;
  final double dailyFiber;
  final double dailyCalcium;
  final double dailyIron;
  final double dailyVitaminC;
  final double dailyVitaminD;

  const NutritionGoals({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.dailyFiber,
    required this.dailyCalcium,
    required this.dailyIron,
    required this.dailyVitaminC,
    required this.dailyVitaminD,
  });

  static NutritionGoals getDefaultGoals(UserProfile? profile) {
    if (profile == null) {
      return const NutritionGoals(
        dailyCalories: 2000,
        dailyProtein: 50,
        dailyCarbs: 250,
        dailyFat: 65,
        dailyFiber: 25,
        dailyCalcium: 1000,
        dailyIron: 18,
        dailyVitaminC: 90,
        dailyVitaminD: 20,
      );
    }

    double bmr = profile.gender == 'male'
        ? 88.362 + (13.397 * profile.weight) + (4.799 * profile.height) - (5.677 * profile.age)
        : 447.593 + (9.247 * profile.weight) + (3.098 * profile.height) - (4.330 * profile.age);

    double activityMultiplier = switch (profile.activityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'very_active' => 1.9,
      _ => 1.55,
    };

    double calories = bmr * activityMultiplier;

    return NutritionGoals(
      dailyCalories: calories,
      dailyProtein: profile.weight * 0.8,
      dailyCarbs: calories * 0.45 / 4,
      dailyFat: calories * 0.35 / 9,
      dailyFiber: 25,
      dailyCalcium: 1000,
      dailyIron: profile.gender == 'female' ? 18 : 8,
      dailyVitaminC: 90,
      dailyVitaminD: 20,
    );
  }
}