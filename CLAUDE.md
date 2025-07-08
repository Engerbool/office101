# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "직장생활은 처음이라" (Office Life for Beginners) - a workplace guide app for new employees. The app provides business terminology, email templates, and workplace tips in Korean.

## Development Commands

### Setup and Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Generate Hive adapters (required for database models)
flutter packages pub run build_runner build

# For development, you can also use the watch command
flutter packages pub run build_runner watch
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Use the convenience script
./run_app.sh

# Run on specific device
flutter run -d <device_id>
```

### Testing and Quality
```bash
# Run tests
flutter test

# Run linting
flutter analyze

# Format code
flutter format .
```

## Architecture Overview

### Tech Stack
- **Framework**: Flutter (Dart)
- **Database**: Hive (NoSQL local storage)
- **State Management**: Provider pattern
- **UI Design**: Neumorphism (Soft UI)
- **Fonts**: Google Fonts (Noto Sans KR)

### Project Structure
```
lib/
├── main.dart                 # App entry point with Hive initialization
├── models/                   # Data models with Hive adapters
│   ├── term.dart            # Business term model
│   ├── email_template.dart  # Email template model
│   └── workplace_tip.dart   # Workplace tip model
├── services/                # Business logic layer
│   └── database_service.dart # Hive database operations
├── providers/               # State management
│   └── term_provider.dart   # Term-specific state
├── screens/                 # UI screens
└── widgets/                 # Reusable UI components
    └── neumorphic_container.dart # Custom neumorphic styling
```

### Key Components

#### Database Service (`lib/services/database_service.dart`)
- Manages Hive database initialization and operations
- Loads initial data from JSON assets on first run
- Provides CRUD operations for all data types
- Handles search functionality for terms

#### Data Models
- All models extend `HiveObject` and use `@HiveType` annotations
- Each model has corresponding `.g.dart` generated files
- Models include: `Term`, `EmailTemplate`, `WorkplaceTip`
- Enums for categories are also Hive-serializable

#### State Management
- Uses Provider pattern for state management
- `TermProvider` manages term-related state
- Providers are registered in `main.dart` using `MultiProvider`

### Data Flow
1. App initializes Hive and registers adapters in `main.dart`
2. `DatabaseService.initialize()` loads initial data from assets
3. Screens access data through providers
4. User interactions update state via providers
5. Changes are persisted through `DatabaseService` methods

### Asset Structure
```
assets/
├── data/                    # JSON data files
│   ├── terms.json          # Business terminology
│   ├── email_templates.json # Email templates
│   └── workplace_tips.json # Workplace tips
└── images/                 # Icon assets for categories
```

## Development Notes

### Hive Code Generation
- Models use Hive adapters for serialization
- Run `flutter packages pub run build_runner build` after model changes
- Generated files (`.g.dart`) are required for compilation

### Localization
- App is primarily in Korean
- Text strings are hardcoded (no internationalization framework)
- UI follows Korean text layout conventions

### Design System
- Neumorphism design with consistent color palette
- Base color: `#EBF0F5`
- Custom `neumorphic_container.dart` provides styling utilities
- Uses Noto Sans KR font throughout

### Data Management
- All data is stored locally using Hive
- No network requests or external APIs
- Initial data loaded from JSON assets on first launch
- Support for user-generated content (user_added flag)