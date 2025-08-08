import 'package:nourishlens/models/models.dart';
import 'package:nourishlens/services/storage_service.dart';
import 'package:nourishlens/services/nutrition_service.dart';

class SampleDataService {
  static const List<String> _sampleImageUrls = [
    'https://pixabay.com/get/gc1353b8a8b977303ee0f4bbe8e167be4fd62250b46075458232e12fac521aea3f33606eab0200d8a9e4d9d96ddea4a4f6ac52b16aca85abd1b7956e885f81874_1280.jpg',
    'https://pixabay.com/get/gff48d3a0c1903e95114b1adbb9a8e1c0f39ffef0f4c7e869bdc7fd41169fa21926c7ce7a5c94b661850b20f8b43f6017265822d5538ed5c55422a44c0d5c7979_1280.jpg',
    'https://pixabay.com/get/g5c72969545d23f425b4079e225b03ee71e25c81b536e151079771988e22d0c40464f3fc7b3398d6af8f501bfdc218757e1eaf9266ecc59a3cb4f6e4722ef04ac_1280.jpg',
    'https://pixabay.com/get/g0ccacef42d2377b37e2ee6c4af7530ff3d0745e8d16033884b72b75c7bb330d82185e598382bced805c8e05edd913461a4f3e7170d4778d44b3e0864af9fd446_1280.jpg',
    'https://pixabay.com/get/gc9cb2c382ce88d3abc717f2a6b8caab81146ac675aa0682626e451ba4b96498936f1632a30d59cde158162aac73796e5d252aaee09dfa5ce02b94e6da4c71049_1280.jpg',
  ];

  static Future<void> generateSampleData() async {
    final existingPhotos = await StorageService.getMealPhotos();
    if (existingPhotos.isNotEmpty) return; // Don't generate if data already exists

    final now = DateTime.now();
    
    // Generate sample meals for the last 3 days
    for (int dayOffset = 2; dayOffset >= 0; dayOffset--) {
      final date = now.subtract(Duration(days: dayOffset));
      await _generateDayMeals(date);
    }
  }

  static Future<void> _generateDayMeals(DateTime date) async {
    final meals = _getSampleMealsForDay(date);
    
    for (final meal in meals) {
      await StorageService.addMealPhoto(meal);
    }

    // Calculate and save daily nutrition
    await NutritionService.calculateDailyNutrition(date);
  }

  static List<MealPhoto> _getSampleMealsForDay(DateTime date) {
    final meals = <MealPhoto>[];
    final dayOfYear = date.day + date.month * 31; // Simple hash for consistency
    
    // Breakfast
    meals.add(MealPhoto(
      id: 'sample_breakfast_${date.millisecondsSinceEpoch}',
      imagePath: _sampleImageUrls[0],
      timestamp: DateTime(date.year, date.month, date.day, 8, 30),
      recognizedFoods: [
        if (dayOfYear % 3 == 0) ...[
          NutritionService.getFoodByName('banana')!,
          NutritionService.getFoodByName('milk')!,
          NutritionService.getFoodByName('bread')!,
        ] else if (dayOfYear % 3 == 1) ...[
          NutritionService.getFoodByName('egg')!,
          NutritionService.getFoodByName('bread')!,
          NutritionService.getFoodByName('milk')!,
        ] else ...[
          NutritionService.getFoodByName('apple')!,
          NutritionService.getFoodByName('bread')!,
        ],
      ],
    ));

    // Lunch
    meals.add(MealPhoto(
      id: 'sample_lunch_${date.millisecondsSinceEpoch}',
      imagePath: _sampleImageUrls[1],
      timestamp: DateTime(date.year, date.month, date.day, 13, 15),
      recognizedFoods: [
        if (dayOfYear % 2 == 0) ...[
          NutritionService.getFoodByName('chicken breast')!,
          NutritionService.getFoodByName('rice')!,
          NutritionService.getFoodByName('broccoli')!,
        ] else ...[
          NutritionService.getFoodByName('salmon')!,
          NutritionService.getFoodByName('spinach')!,
          NutritionService.getFoodByName('rice')!,
        ],
      ],
    ));

    // Dinner (only add if not today or if it's evening)
    if (date.day != DateTime.now().day || DateTime.now().hour >= 18) {
      meals.add(MealPhoto(
        id: 'sample_dinner_${date.millisecondsSinceEpoch}',
        imagePath: _sampleImageUrls[2],
        timestamp: DateTime(date.year, date.month, date.day, 19, 45),
        recognizedFoods: [
          if (dayOfYear % 4 == 0) ...[
            NutritionService.getFoodByName('salmon')!,
            NutritionService.getFoodByName('broccoli')!,
            NutritionService.getFoodByName('rice')!,
          ] else if (dayOfYear % 4 == 1) ...[
            NutritionService.getFoodByName('chicken breast')!,
            NutritionService.getFoodByName('spinach')!,
          ] else if (dayOfYear % 4 == 2) ...[
            NutritionService.getFoodByName('egg')!,
            NutritionService.getFoodByName('spinach')!,
            NutritionService.getFoodByName('bread')!,
          ] else ...[
            NutritionService.getFoodByName('chicken breast')!,
            NutritionService.getFoodByName('broccoli')!,
          ],
        ],
      ));
    }

    return meals;
  }
}