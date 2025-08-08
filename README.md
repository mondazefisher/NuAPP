# nourishlens

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
app:
  name: NutriSnap
  platforms: [ios, android]
  goal: "Track meals via photos; auto-identify foods; compute nutrients; give an end-of-day deficiency report with food-first suggestions."

  onboarding_profile_fields:
    - age
    - sex
    - height_cm
    - weight_kg
    - activity_level: [sedentary, light, moderate, high]
    - dietary_pattern: [omnivore, vegetarian, vegan, pescatarian]
    - allergies_or_intolerances: free_text

  permissions:
    - camera: "Capture meal photos for recognition."
    - photos: "Upload existing meal photos."
    - notifications: "Meal-time reminders and daily report."

  data_sources:
    nutrition_database:
      name: "USDA FoodData Central or equivalent"
      required_fields:
        - calories
        - macros: [protein, carbs, fat, fiber]
        - vitamins: [A, C, D, E, K, B1, B2, B3, B6, B9, B12]
        - minerals: [Calcium, Iron, Magnesium, Potassium, Zinc, Sodium, Iodine]
    ai_models:
      vision_identification: "Food detection from images; return candidates with confidence."
      portion_estimation: "Heuristic/model using plate context; always editable."
      nlp_suggestions: "Generate plain-language food-first tips respecting diet/allergies."

  deficiency_logic:
    compare_to: "Personalized RDA/AI/UL by profile"
    low_threshold_pct: 80
    high_threshold_pct: 150
    focus_nutrients: [Vitamin D, Iron, Calcium, B12, Fiber, Potassium, Magnesium]
    output:
      - "Flag likely low/excess nutrients"
      - "Provide 1–3 food suggestions honoring diet & allergies"

  screens:
    - id: home_today
      widgets:
        - add_meal_button
        - today_timeline_photos
        - running_totals: [calories, protein, fiber, iron, calcium, potassium]
    - id: capture
      widgets:
        - camera
        - gallery_import
        - ai_results_editor: {food_candidates_with_confidence: true, quantity_stepper: true, manual_search_fallback: true, notes: true}
    - id: meal_detail
      widgets:
        - items_list_editable
        - portion_controls
        - nutrient_breakdown_card
    - id: daily_report
      widgets:
        - totals_chart # calories/macros
        - micronutrient_bars # color-coded vs targets
        - gaps_list_with_tips
    - id: history
      widgets:
        - calendar
        - weekly_averages
        - recurring_gaps_highlights
    - id: profile_settings
      widgets:
        - profile_form
        - dietary_pattern_picker
        - allergies_editor
        - units
        - reminders
        - data_export_csv

  ux_requirements:
    - one_tap_camera_from_home
    - inline_edit_chips_for_food_items
    - supportive_nonjudgmental_tone
    - accessibility_labels_for_all_controls
    - high_contrast_mode

  notifications:
    - meal_reminders: {times: [08:00, 12:00, 18:00], user_customizable: true}
    - daily_report_ready: {time: "20:30"}

  offline:
    queue_entries_offline: true
    manual_add_offline: true
    analyze_on_reconnect: true

  privacy_storage:
    photos_local_default: true
    cloud_sync_optional: true
    delete_entries_and_photos: true
    export_csv: true

  acceptance_criteria:
    - "User logs 5+ meals by photo; median < 30s each."
    - "Top-3 candidate includes correct food ≥90% of time; easy manual correction."
    - "Daily report highlights at least 5 micronutrients and flags gaps with 1–3 actionable tips."
    - "CSV export includes date range, macros, and selected vitamins/minerals."
