import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nourishlens/models/models.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _mealPhotosKey = 'meal_photos';
  static const String _dailyNutritionKey = 'daily_nutrition';

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    if (jsonString != null) {
      return UserProfile.fromJson(json.decode(jsonString));
    }
    return null;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(profile.toJson()));
  }

  static Future<List<MealPhoto>> getMealPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_mealPhotosKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MealPhoto.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> saveMealPhotos(List<MealPhoto> photos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = photos.map((photo) => photo.toJson()).toList();
    await prefs.setString(_mealPhotosKey, json.encode(jsonList));
  }

  static Future<void> addMealPhoto(MealPhoto photo) async {
    final photos = await getMealPhotos();
    photos.add(photo);
    await saveMealPhotos(photos);
  }

  static Future<List<DailyNutrition>> getDailyNutritionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dailyNutritionKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => DailyNutrition.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> saveDailyNutrition(DailyNutrition nutrition) async {
    final history = await getDailyNutritionHistory();
    
    // Remove existing entry for the same date
    history.removeWhere((n) => 
      n.date.year == nutrition.date.year &&
      n.date.month == nutrition.date.month &&
      n.date.day == nutrition.date.day
    );
    
    history.add(nutrition);
    history.sort((a, b) => a.date.compareTo(b.date));
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((n) => n.toJson()).toList();
    await prefs.setString(_dailyNutritionKey, json.encode(jsonList));
  }

  static Future<DailyNutrition?> getDailyNutrition(DateTime date) async {
    final history = await getDailyNutritionHistory();
    try {
      return history.firstWhere((n) => 
        n.date.year == date.year &&
        n.date.month == date.month &&
        n.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }
}