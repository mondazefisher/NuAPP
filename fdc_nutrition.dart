// This file connects to the USDA FoodData Central (FDC) API
// to search for foods and get their full nutrient information.
//
// It implements the NutritionRepository interface so it can be
// swapped in without changing NutritionService or the UI.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nourishlens/models/models.dart';
import 'package:nourishlens/nutrition/nutrient_keys.dart';
import 'package:nourishlens/services/nutrition_repository.dart';

class FdcApiNutritionRepository implements NutritionRepository {
  // Your USDA API key (get one at https://fdc.nal.usda.gov/api-key-signup.html)
  final String apiKey;

  // HTTP client for making requests; allows us to reuse or mock it for tests
  final http.Client _client;

  // Base URL for the FDC API
  static const _base = 'https://api.nal.usda.gov/fdc/v1';

  FdcApiNutritionRepository(this.apiKey, {http.Client? client})
      : _client = client ?? http.Client();

  // SEARCH for foods by name (returns quick info + some nutrients)
  @override
  Future<List<FoodItem>> search(String query) async {
    // Build the search URL
    // dataType=Foundation,SR%20Legacy filters to high-quality generic foods
    // pageSize=20 limits results
    final uri = Uri.parse(
      '$_base/foods/search?api_key=$apiKey'
      '&query=${Uri.encodeQueryComponent(query)}'
      '&dataType=Foundation,SR%20Legacy&pageSize=20'
    );

    // Make the GET request
    final res = await _client.get(uri);

    // If the API returns an error status, throw
    if (res.statusCode != 200) {
      throw Exception('FDC search failed: ${res.statusCode}');
    }

    // Parse the JSON body into a Map
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // "foods" is the list of results
    final foods = (data['foods'] as List? ?? const [])
        .cast<Map<String, dynamic>>();

    // Map each raw API item to our FoodItem model
    return foods.map(_fromSearchHit).toList();
  }

  // HELPER: convert a search result map into a FoodItem
  FoodItem _fromSearchHit(Map<String, dynamic> m) {
    // Create a map of nutrients keyed by our NutrientKey enum
    final per100g = <NutrientKey, double>{};

    // Loop over the nutrients in the API response
    for (final n in (m['foodNutrients'] as List? ?? const [])) {
      final name = (n['nutrientName'] ?? '').toString(); // e.g., "Protein"
      final unit = (n['unitName'] ?? '').toString();     // e.g., "G"
      final val = (n['value'] as num?)?.toDouble();      // numeric value

      // Map USDA nutrient name + unit → our NutrientKey
      final key = _mapFdcNameUnitToKey(name, unit);

      // If we recognize it, store it
      if (key != null && val != null) per100g[key] = val;
    }

    // Return a minimal FoodItem (search hits don't give every nutrient)
    return FoodItem(
      fdcId: (m['fdcId'] as num?)?.toInt(),
      name: (m['description'] ?? '').toString(),
      referenceSizeG: 100,
      per100g: per100g,
    );
  }

  // GET full details for a food by its FDC ID (includes all nutrients)
  @override
  Future<FoodItem?> getByFdcId(int fdcId) async {
    final uri = Uri.parse('$_base/food/$fdcId?api_key=$apiKey');

    final res = await _client.get(uri);
    if (res.statusCode != 200) return null;

    final m = jsonDecode(res.body) as Map<String, dynamic>;

    // Extract and normalize nutrient values to per 100g
    final per100g = _normalizeToPer100g(m);

    return FoodItem(
      fdcId: fdcId,
      name: (m['description'] ?? '').toString(),
      referenceSizeG: 100,
      per100g: per100g,
    );
  }

  // MAP USDA nutrient names to our NutrientKey enum
  NutrientKey? _mapFdcNameUnitToKey(String name, String unit) {
    final u = unit.toUpperCase();
    switch (name) {
      case 'Energy':                return u == 'KCAL' ? NutrientKey.energyKcal : null;
      case 'Protein':               return u == 'G'    ? NutrientKey.proteinG : null;
      case 'Carbohydrate, by difference':
                                   return u == 'G'    ? NutrientKey.carbsG : null;
      case 'Total lipid (fat)':     return u == 'G'    ? NutrientKey.fatG : null;
      case 'Fiber, total dietary':  return u == 'G'    ? NutrientKey.fiberG : null;
      case 'Vitamin C, total ascorbic acid':
                                   return u == 'MG'   ? NutrientKey.vitaminCmg : null;
      case 'Vitamin D (D2 + D3)':   return (u == 'UG' || u == 'µG') ? NutrientKey.vitaminDµg : null;
      case 'Vitamin A, RAE':        return (u == 'UG' || u == 'µG') ? NutrientKey.vitaminAµg : null;
      case 'Vitamin E (alpha-tocopherol)':
                                   return u == 'MG'   ? NutrientKey.vitaminEmg : null;
      case 'Vitamin K (phylloquinone)':
                                   return (u == 'UG' || u == 'µG') ? NutrientKey.vitaminKµg : null;
      case 'Thiamin':               return u == 'MG'   ? NutrientKey.thiaminB1mg : null;
      case 'Riboflavin':            return u == 'MG'   ? NutrientKey.riboflavinB2mg : null;
      case 'Niacin':                return u == 'MG'   ? NutrientKey.niacinB3mg : null;
      case 'Vitamin B-6':           return u == 'MG'   ? NutrientKey.vitaminB6mg : null;
      case 'Folate, DFE':           return (u == 'UG' || u == 'µG') ? NutrientKey.folateB9µg : null;
      case 'Vitamin B-12':          return (u == 'UG' || u == 'µG') ? NutrientKey.vitaminB12µg : null;
      case 'Calcium, Ca':           return u == 'MG'   ? NutrientKey.calciumMg : null;
      case 'Iron, Fe':              return u == 'MG'   ? NutrientKey.ironMg : null;
      case 'Magnesium, Mg':         return u == 'MG'   ? NutrientKey.magnesiumMg : null;
      case 'Potassium, K':          return u == 'MG'   ? NutrientKey.potassiumMg : null;
      case 'Zinc, Zn':              return u == 'MG'   ? NutrientKey.zincMg : null;
      case 'Sodium, Na':            return u == 'MG'   ? NutrientKey.sodiumMg : null;
    }
    return null;
  }

  // Convert API nutrient amounts to a "per 100g" basis
  // For Foundation/SR Legacy foods, USDA already reports per 100g
  Map<NutrientKey, double> _normalizeToPer100g(Map<String, dynamic> food) {
    final map = <NutrientKey, double>{};

    // Loop through the nutrient list in the food details
    for (final n in (food['foodNutrients'] as List? ?? const [])) {
      final nutrientInfo = (n['nutrient'] as Map?) ?? const {};
      final name = (nutrientInfo['name'] ?? '').toString();
      final unit = (nutrientInfo['unitName'] ?? '').toString();
      final amount = (n['amount'] as num?)?.toDouble();

      final key = _mapFdcNameUnitToKey(name, unit);
      if (key == null || amount == null) continue;

      // For Foundation/SR Legacy, these amounts are already per 100g
      map[key] = amount;
    }

    return map;
  }
}
