# MyBasketTeam Project Structure

This project follows an MVVM architecture with Riverpod for state management, adhering to Effective Dart guidelines.

## Directory Structure

```
lib/
├── core/                      # Shared core functionality
│   ├── models/                # Base models and interfaces
│   ├── providers/             # Global providers and provider utilities
│   ├── router/                # App routing
│   ├── services/              # Shared services
│   │   └── repositories/      # Centralized repositories
│   ├── theme/                 # App theming
│   └── widgets/               # Reusable widgets
│
├── features/                  # Feature modules
│   ├── feature_name/          # e.g., team, live_stats, etc.
│   │   ├── models/            # Data models for this feature
│   │   ├── providers/         # Feature-specific Riverpod providers (converted from view_models)
│   │   ├── views/             # Screens/pages
│   │   └── widgets/           # Feature-specific widgets
│
└── main.dart                  # App entry point
```

## Completed Refactoring Tasks

1. Created core directories for shared functionality:
   - `models` - for base models and interfaces
   - `providers` - for global provider management 
   - `services/repositories` - for centralized data access
   - `widgets` - for reusable UI components

2. Organized feature modules with a consistent structure:
   - Each feature has its own directory with models, providers, views, and widgets
   - View models have been renamed to providers following Riverpod patterns

3. Centralized import management:
   - Created `app_providers.dart` to export all providers
   - Created `repositories.dart` to export all repositories

## Import Best Practices

- For global providers: `import 'package:mybasketteam/core/providers/app_providers.dart';`
- For repositories: `import 'package:mybasketteam/core/services/repositories/repositories.dart';`
- For feature-specific code: `import 'package:mybasketteam/features/[feature_name]/[module]/[file].dart';`

## Naming Conventions (Following Effective Dart)

- Use `lowerCamelCase` for variables, parameters, and method names
- Use `UpperCamelCase` for classes, enums, and type names
- Use `lowercase_with_underscores` for file and directory names
- Prefix private members with underscore: `_privateVariable`
- Keep provider names descriptive: `teamsProvider`, `matchesByLeagueProvider`

## Future Improvements

- Consider converting remaining view models to proper Riverpod providers
- Add unit tests for core providers and repositories
- Standardize model interfaces across features
- Further refine the dependency injection approach
