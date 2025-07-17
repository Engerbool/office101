# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains "직장생활은 처음이라" (Office Life for Beginners) - a Flutter mobile application designed as a comprehensive workplace guide for new employees. The app provides Korean business terminology, email templates, and workplace tips in a modern neumorphic design.

## Development Commands

### Initial Setup
```bash
# Navigate to the Flutter app directory
cd office101_app

# Install Flutter dependencies
flutter pub get

# Generate Hive adapters (required for database models)
flutter packages pub run build_runner build --delete-conflicting-outputs

# For development, use watch mode for continuous generation
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
# From office101_app directory
flutter run

# Use the convenience script
./run_app.sh

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

### Development & Quality Assurance
```bash
# Run tests
flutter test

# Run static analysis
flutter analyze

# Format code
flutter format .

# Clean build artifacts
flutter clean
```

### Additional Development Commands
```bash
# Clear Hive database boxes (when testing data changes)
# Note: Database will reload from JSON assets on next run
flutter clean && flutter run

# Check specific device for testing
flutter devices

# Debug specific performance issues
flutter run --debug
flutter run --profile  # For performance testing
```

## Architecture Overview

### Technology Stack
- **Framework**: Flutter (Dart 3.0+)
- **Local Database**: Hive (NoSQL key-value storage)
- **State Management**: Provider pattern
- **UI Design**: Neumorphism (Soft UI)
- **Fonts**: Google Fonts (Noto Sans KR)
- **Code Generation**: build_runner for Hive adapters
- **Scroll Control**: ScrollView Observer for advanced navigation
- **Error Handling**: Comprehensive error service with typed errors

### Core Architecture Components

#### 1. Database Layer (`lib/services/database_service.dart`)
- **Hive Integration**: Manages three separate boxes for different data types
- **Initialization**: Registers adapters and loads initial data from JSON assets
- **Data Loading**: Populates database from `assets/data/` JSON files on first run
- **CRUD Operations**: Provides methods for all data manipulation

#### 2. Data Models (`lib/models/`)
All models extend `HiveObject` and use `@HiveType` annotations:
- **Term**: Business terminology with categories, definitions, examples, and tags
- **EmailTemplate**: Situational email templates with tips and categories  
- **WorkplaceTip**: Workplace advice with key points and priority levels
- **Enums**: TermCategory, EmailCategory, TipCategory (all Hive-serializable)

#### 3. State Management (`lib/providers/`)
- **TermProvider**: Advanced state management with progressive loading, search debouncing, and multi-level caching
- **ThemeProvider**: Handles light/dark theme switching
- **Provider Pattern**: Used throughout for reactive state management

#### 4. Error Handling (`lib/services/error_service.dart`)
- **Typed Error System**: Different error types (database, network, filesystem, validation)
- **User-friendly Messages**: Context-aware error messages in Korean
- **Retry Mechanisms**: Automatic retry logic for transient failures
- **Error Logging**: Comprehensive error tracking with stack traces

#### 5. UI Layer (`lib/screens/` & `lib/widgets/`)
- **Screens**: Feature-specific full-screen components
- **Widgets**: Reusable UI components with consistent neumorphic styling
- **Navigation**: BottomNavigationBar with 4 main tabs
- **Index Navigation**: ScrollView Observer enables precise scroll-to-index functionality

### Data Flow Architecture
1. **Initialization**: `main.dart` initializes Hive and registers all adapters
2. **Data Loading**: `DatabaseService.initialize()` loads initial JSON data
3. **State Management**: Providers access data through DatabaseService
4. **UI Updates**: Screens listen to providers via Consumer widgets
5. **Persistence**: Changes are automatically saved to Hive boxes

### Key Design Patterns

#### Neumorphic Design System
- **Base Color**: `#EBF0F5` (light gray-blue)
- **Shadows**: Dual shadow system (dark + light) for depth
- **Consistency**: All components use `neumorphic_container.dart`
- **Accessibility**: Maintains proper contrast ratios

#### Korean Text Handling
- **Font**: Noto Sans KR for proper Korean typography
- **Sorting**: Custom Korean sorting utilities in `utils/korean_sort_utils.dart`
- **Initial Sound Extraction**: Extracts Korean consonants (초성) for indexing
- **Index Navigation**: Supports both Korean consonants and English letters
- **Search Optimization**: Handles Korean text input and matching

## Development Notes

### Hive Code Generation Requirements
- **Critical**: Run `build_runner build` after any model changes
- **Generated Files**: `.g.dart` files are required for compilation
- **Type Safety**: All Hive types must be properly registered in `database_service.dart`

### Asset Management
```
assets/
├── data/                    # JSON data files (loaded on first run)
│   ├── terms/              # Category-separated term files
│   │   ├── business.json   # Business terminology
│   │   ├── marketing.json  # Marketing terms
│   │   ├── it.json         # IT terminology
│   │   ├── hr.json         # HR terms
│   │   ├── communication.json # Communication terms
│   │   ├── approval.json   # Approval/reporting terms
│   │   └── time.json       # Time management terms
│   ├── email_templates.json # Email templates with tips
│   └── workplace_tips.json # Workplace advice
└── images/                 # Category icons and UI assets
```

### Search & Filter Implementation
- **Multi-field Search**: Searches across term, definition, and tags
- **Category Filtering**: Hierarchical category system
- **Korean Search**: Handles Korean text input and matching
- **Performance**: Efficient filtering using Dart's built-in list operations
- **Progressive Loading**: Loads 10 items initially, then chunks of 50 for better UX
- **Search Debouncing**: 300ms delay to prevent excessive processing during typing
- **Multi-level Caching**: Search cache and category cache for optimal performance

### Theme System
- **Dual Theme**: Light and dark mode support
- **Provider-based**: Theme changes trigger app-wide updates
- **Neumorphic Adaptation**: Colors adjust while maintaining depth effect
- **Persistence**: Theme preference saved locally

## File Structure Context

```
office101/
├── CLAUDE.md                # This file (root level documentation)
├── office101_app/           # Flutter application directory
│   ├── lib/                 # Main source code
│   │   ├── main.dart        # App entry point & providers setup
│   │   ├── models/          # Hive data models with adapters
│   │   ├── services/        # Database and business logic
│   │   ├── providers/       # State management (Provider pattern)
│   │   ├── screens/         # UI screens/pages
│   │   ├── widgets/         # Reusable UI components
│   │   └── utils/           # Helper functions and utilities
│   ├── assets/              # Static assets (JSON data, images)
│   ├── pubspec.yaml         # Flutter dependencies and config
│   └── run_app.sh           # Development convenience script
└── draft.txt                # Development notes
```

## Advanced Features

### Progressive Loading System
- **Initial Load**: 10 items for immediate display
- **Background Loading**: Remaining items loaded in chunks of 50
- **Performance**: Prevents UI blocking on large datasets
- **State Management**: Proper loading states and error handling

### ScrollView Observer Integration
- **Advanced Scroll Control**: Uses `scrollview_observer` package for precise scroll positioning
- **Index-based Navigation**: Jump to specific list positions by index
- **Korean Character Support**: Handles Korean consonants and English letters
- **Fallback Logic**: Automatically finds next available character if target doesn't exist

### Multi-level Caching System
- **Search Cache**: Caches search results with composite keys
- **Category Cache**: Pre-loads all categories for instant filtering
- **Memory Management**: Limits cache size to prevent memory issues
- **Smart Invalidation**: Selective cache clearing based on data changes

## Common Development Workflows

### Adding New Terms/Content
1. Modify appropriate JSON file in `assets/data/`
2. Clear existing Hive boxes or increment app version
3. Run `flutter run` to reload data

### Modifying Data Models
1. Update model class in `lib/models/`
2. Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
3. Update any affected screens/providers

### UI Component Development
1. Follow existing neumorphic design patterns
2. Use `neumorphic_container.dart` for consistent styling
3. Implement responsive design for different screen sizes
4. Test both light and dark themes
5. Consider Korean text layout and index navigation when adding new list components

## Testing Strategy

The app uses Flutter's built-in testing framework. Key testing areas:
- **Unit Tests**: Model serialization/deserialization
- **Widget Tests**: UI component behavior
- **Integration Tests**: Full app flow testing
- **Database Tests**: Hive operations and data persistence