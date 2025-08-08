# NutriSnap Architecture Plan

## Core Features
1. **Photo Capture & Gallery** - Camera integration with meal photo gallery
2. **Food Recognition & Nutrition Data** - Basic food identification with manual editing
3. **Daily Nutrition Tracking** - Calorie and macro tracking with deficiency alerts
4. **History & Trends** - Calendar view and weekly progress charts
5. **User Profile & Settings** - Basic user info and app preferences

## Technical Architecture

### Data Models
- `UserProfile` - user demographics and goals
- `MealPhoto` - photo metadata and timestamp
- `FoodItem` - food name, nutrition data per 100g
- `DailyNutrition` - aggregated daily totals
- `NutritionGoals` - recommended daily values

### Screen Structure
1. `OnboardingScreen` - Welcome and profile setup
2. `MainFeedScreen` - Today's meals with snap button
3. `CameraScreen` - Full-screen camera for meal photos
4. `MealDetailScreen` - Photo with recognized foods
5. `DailySummaryScreen` - Nutrition charts and deficiency alerts
6. `HistoryScreen` - Calendar and trend charts
7. `SettingsScreen` - Profile and app preferences

### Core Services
- `StorageService` - Local data persistence
- `NutritionService` - Food data and calculations
- `CameraService` - Photo capture and gallery management

### State Management
- Simple `setState` with stateful widgets
- Local storage for persistence

## Implementation Priority
1. Basic UI structure and navigation
2. Camera integration and photo storage
3. Manual food entry system
4. Nutrition calculation and daily summary
5. History and settings screens
6. Sample data and polish

## Key Constraints
- MVP scope with essential features only
- Local storage (no external APIs)
- Maximum 10-12 files total
- Focus on core nutrition tracking workflow