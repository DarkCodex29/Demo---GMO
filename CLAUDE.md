# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based Industrial Maintenance Management System (Sistema de Gestión de Mantenimiento Industrial) developed as a demo for GMO by Gianpierre Mio for Ebim. It's a cross-platform application for comprehensive industrial equipment maintenance management.

## Essential Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the application
flutter run -d chrome          # For web
flutter run -d windows         # For Windows
flutter run -d android         # For Android
flutter run                    # For default device

# Clean build artifacts
flutter clean

# Get dependencies after clean
flutter pub get
```

### Testing and Quality
```bash
# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Check for dependency updates
flutter pub outdated
```

### Build Commands
```bash
# Build for web
flutter build web

# Build APK for Android
flutter build apk

# Build for Windows
flutter build windows
```

## Architecture Overview

### Core Structure
- **Authentication Flow**: `lib/src/app.dart` handles login state management using SharedPreferences
- **Main Entry Point**: `lib/main.dart` initializes notification service and responsive framework
- **Modular Page Structure**: Pages organized by functional areas under `lib/src/pages/`
- **Data Storage**: JSON files in `assets/data/` provide demo data for all modules
- **Responsive Design**: Uses `responsive_framework` package for cross-platform UI adaptation

### Key Components

#### State Management
- Uses `StatefulWidget` for local state management
- `SharedPreferences` for authentication persistence
- No external state management library (Provider/Bloc) - pure Flutter state

#### Data Architecture
- **Local JSON Files**: All demo data stored in `assets/data/` as JSON files
- **No Database**: Currently uses file-based data storage for demo purposes
- **Key Data Files**:
  - `users.json`: Authentication credentials
  - `equipament.json`: Equipment catalog
  - `ordenes.json`: Work orders
  - `avisos.json`: Maintenance warnings
  - `locations.json`: Technical locations
  - `materials.json`: Materials and spare parts

#### Notification System
- Custom notification service using `flutter_local_notifications`
- Simulates real-time maintenance alerts
- Three notification channels: orders, capacity alerts, and failure alerts

### Module Organization

#### Maintenance Management (`lib/src/pages/maintenance/`)
- **Warnings**: `warning.page.dart` - Maintenance alert management
- **Orders**: `order.page.dart` - Work order management
- **Create Order**: `create_order.page.dart` - New work order creation
- **Demand Management**: `demand_management.page.dart` - Processing warnings and demands

#### Team/Equipment Management (`lib/src/pages/team/`)
- **Classes**: `class.page.dart` - Equipment classification
- **Locations**: `locations.page.dart` - Technical location hierarchy
- **Jobs**: `job.page.dart` - Work centers and responsibilities
- **Equipment**: `equipment.page.dart` - Master equipment registry
- **Materials**: `materials.page.dart` - Materials and spare parts catalog

#### Planning (`lib/src/pages/planning/`)
- **Strategies**: `strategies.page.dart` - Preventive maintenance strategies
- **Capacity Management**: `capacity_management.page.dart` - Resource planning and scheduling
- **Roadmap**: `roadmap_main.page.dart` - Route sheets and work team management
- **Maintenance Cycles**: `maintenance/cycle.page.dart` - Individual maintenance cycle scheduling

#### Reports (`lib/src/pages/reports/`)
- **Reports Hub**: `reports_main.page.dart` - Central access to all system reports
- **Capacity Reports**: `capacity_report.page.dart`
- **Equipment Reports**: `equipment_report.page.dart`
- **Orders Reports**: `orders_report.page.dart`
- **Stock Reports**: `stock_report.page.dart`

## Theme and Design System

### Corporate Color Palette
The application uses a comprehensive corporate color palette defined in `lib/src/theme/app_colors.dart`:

#### Primary Colors
- **Dark Teal**: `#055658` (`AppColors.primaryDarkTeal`) - Main primary color for AppBars, buttons, and key UI elements
- **Medium Teal**: `#056769` (`AppColors.primaryMediumTeal`) - Secondary primary shade
- **Mint Green**: `#5AA97F` (`AppColors.primaryMintGreen`) - Used for success states and secondary actions
- **Light Green**: `#AEEA94` (`AppColors.primaryLightGreen`) - Light accent color

#### Secondary Colors
- **Aqua Green**: `#59D19A` (`AppColors.secondaryAquaGreen`) - Success color
- **Coral Red**: `#EA5050` (`AppColors.secondaryCoralRed`) - Error/danger color
- **Bright Blue**: `#2A77E8` (`AppColors.secondaryBrightBlue`) - Info color
- **Golden Yellow**: `#FFD96E` (`AppColors.secondaryGoldenYellow`) - Warning color

#### Neutral Colors
- **Text Gray**: `#4E6478` (`AppColors.neutralTextGray`) - Primary text color
- **Light Background**: `#F3F4F6` (`AppColors.neutralLightBackground`) - Main background color
- **Medium Border**: `#C1C7D0` (`AppColors.neutralMediumBorder`) - Border and divider color

### Typography
- **Font Family**: DM Sans (loaded via Google Fonts)
- **Font Weights**: Regular (400), Medium (500), Bold (700)
- **Comprehensive text styles** defined in `lib/src/theme/app_text_styles.dart`
- **Responsive font sizes** that adapt to different screen sizes

### Design Components
- **Cards**: White background with subtle shadows and 12px rounded corners
- **Buttons**: Consistent styling with corporate colors and proper text contrast
- **Input Fields**: Clean styling with focus states using primary colors

### Responsive Breakpoints
- **Mobile**: 0-450px
- **Tablet**: 451-800px
- **Desktop**: 801-1920px
- **4K**: 1921px+

### Design Patterns
- **Expansion Tiles**: Primary navigation method for grouping related functions
- **Card-based Layout**: All content sections use Material Design cards
- **Responsive Grid**: Desktop uses 2-column layout, tablet and mobile stack vertically
- **Consistent theming** using `AppTheme.lightTheme` from `lib/src/theme/app_theme.dart`

## Authentication System

### Demo Credentials
- **Admin**: username `admin`, password `admin123`
- **User1**: username `user1`, password `password1`
- **User2**: username `user2`, password `password2`

### Session Management
- Uses `SharedPreferences` to store login state (`isLoggedIn` boolean)
- No JWT tokens or complex authentication - simple boolean persistence
- Logout clears the stored preference and redirects to login

## Development Guidelines

### Adding New Pages
1. Create page in appropriate module directory under `lib/src/pages/`
2. Follow existing naming convention: `feature_name.page.dart`
3. Add navigation route in `home.page.dart`
4. Ensure responsive design using `ResponsiveBreakpoints`
5. **Use theme colors**: Import `AppColors` from `lib/src/theme/app_colors.dart` and use theme colors instead of hardcoded colors
6. **Use theme text styles**: Import `AppTextStyles` from `lib/src/theme/app_text_styles.dart` for consistent typography

### Data Integration
- Add new JSON files to `assets/data/` for demo data
- Update `pubspec.yaml` assets section if needed
- Use `rootBundle.loadString()` to load JSON data in pages

### Notification Integration
- Use `NotificationService` class for all notifications
- Three main notification types: orders, capacity alerts, failure alerts
- Test notifications available via app header actions

### Theme Architecture
The theme system is organized into separate files for maintainability:
- **`lib/src/theme/app_colors.dart`**: Complete color palette with corporate colors
- **`lib/src/theme/app_text_styles.dart`**: Typography system using DM Sans with all text styles
- **`lib/src/theme/app_theme.dart`**: Complete Material Theme configuration combining colors and typography
- **Usage**: Import `AppTheme.lightTheme` in `main.dart` and use individual color/text style imports in pages

## Key Dependencies

### Core Flutter Packages
- `shared_preferences: ^2.3.2` - Local data persistence
- `flutter_local_notifications: ^19.3.0` - Push notifications
- `permission_handler: ^11.3.1` - App permissions
- `responsive_framework: ^1.5.1` - Responsive design
- `http: ^1.2.2` - HTTP requests (for future API integration)
- `intl: ^0.19.0` - Internationalization support
- `provider: ^6.1.2` - State management (minimal usage)
- `google_fonts: ^6.2.1` - DM Sans font loading via Google Fonts

### Development Tools
- `flutter_lints: ^3.0.0` - Code analysis and linting
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## Testing

### Current Test Structure
- Basic widget tests in `test/widget_test.dart`
- No comprehensive test coverage currently implemented
- Tests focus on widget rendering and basic functionality

### Running Tests
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

## Multi-Platform Support

### Supported Platforms
- **Web**: Primary development target
- **Windows**: Desktop support
- **Android**: Mobile support
- **iOS**: Configured but not actively tested
- **macOS**: Configured but not actively tested
- **Linux**: Configured but not actively tested

### Platform-Specific Notes
- Notifications configured primarily for Android
- Web build targets Chrome for optimal performance
- Windows build includes native window management