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

### Module Organization (Based on C:\Users\gianx\Desktop\EMPRESAS\EBIM\GMO\Documento de Capacitacion)

The application follows a modular architecture with main navigation pages for each module and individual section pages. Each module uses a consistent pattern with a main navigation page showing section cards in a responsive grid layout.

#### 1. Confiabilidad Module (`lib/src/modules/confiabilidad/`)
**Main Page**: `confiabilidad_main.page.dart` - Shows 9 section cards in responsive grid
- **Clases**: `pages/class.page.dart` - Equipment classification management
- **Ubicaciones**: `pages/locations.page.dart` - Technical location hierarchy
- **Puestos de Trabajo**: `pages/job.page.dart` - Work centers and responsibilities  
- **Equipos**: `pages/equipment.page.dart` - Master equipment registry
- **Materiales**: `pages/materials.page.dart` - Materials and spare parts catalog
- **Características**: `pages/characteristics.page.dart` - Equipment characteristics
- **Hojas de Ruta**: `pages/roadmap_main.page.dart` - Main navigation for roadmap subsections
  - **Instrucciones**: `pages/roadmap/instruction.page.dart` - Work instructions
  - **Equipos de Trabajo**: `pages/roadmap/team.page.dart` - Work teams
  - **UBTs**: `pages/roadmap/ubt.page.dart` - Basic work units
- **Estrategias**: `pages/strategies.page.dart` - Maintenance strategies
- **Ciclos**: `pages/cycle.page.dart` - Maintenance cycles

#### 2. Demanda Module (`lib/src/modules/demanda/`)
**Main Page**: `demanda_main.page.dart` - Shows 3 section cards
- **Avisos**: `pages/warning.page.dart` - Maintenance notifications
- **Gestión de Demanda**: `pages/demand_management.page.dart` - Demand processing
- **Notificaciones**: `pages/notification.page.dart` - System notifications

#### 3. Planificación Module (`lib/src/modules/planificacion/`)
**Main Page**: `planificacion_main.page.dart` - Shows 2 section cards
- **Crear Orden**: `pages/create_order.page.dart` - Create work orders
- **Gestión de Capacidades**: `pages/capacity_management.page.dart` - Capacity planning

#### 4. Programación Module (`lib/src/modules/programacion/`)
**Status**: Pending implementation - currently redirects to capacity management

#### 5. Ejecución Module (`lib/src/modules/ejecucion/`)
**Main Page**: Pending implementation
- **Órdenes**: `pages/order.page.dart` - Work order execution
- **Ejecución**: `pages/execution.page.dart` - Field work execution
- **Cierre**: `pages/closing.page.dart` - Work order closing

#### 6. Seguimiento y Control Module (`lib/src/modules/seguimiento_control/`)
**Main Page**: `seguimiento_control_main.page.dart` - Pending implementation
- **Reportes**: `pages/reports_main.page.dart` - Reports hub
- **Reporte de Capacidades**: `pages/capacity_report.page.dart`
- **Reporte de Equipos**: `pages/equipment_report.page.dart`
- **Reporte de Órdenes**: `pages/orders_report.page.dart`
- **Reporte de Stock**: `pages/stock_report.page.dart`
- **Log de Fallas**: `pages/fault.log.page.dart`

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
- **Module Navigation Pages**: Each module has a main page with section cards in responsive grid
- **Card-based Layout**: All content sections use Material Design cards with consistent styling
- **No Gradients**: Formal business application without gradient backgrounds
- **Responsive Grid**: Desktop uses multi-column layout, tablet and mobile stack vertically
- **Consistent Navigation**: MainLayout wrapper with showBackButton for hierarchical navigation
- **Color Usage**:
  - Primary headers use `AppColors.primaryDarkTeal`
  - Section cards have colored headers matching their theme
  - Icons on colored backgrounds use contrasting colors for visibility
  - Status indicators use semantic colors (green/red/teal)
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
1. Create page in appropriate module directory under `lib/src/modules/[module_name]/pages/`
2. Follow existing naming convention: `feature_name.page.dart`
3. Add navigation in module's main page or parent navigation page
4. Wrap all pages with `MainLayout` providing:
   - `currentModule`: Module identifier
   - `customTitle`: Page title for AppBar
   - `showBackButton`: true for sub-pages
5. Use `ResponsiveRowColumn` for responsive layouts
6. **Use theme colors**: Import `AppColors` from `lib/src/theme/app_colors.dart`
7. **Use theme text styles**: Import `AppTextStyles` from `lib/src/theme/app_text_styles.dart`
8. **Avoid gradients**: Keep design formal and professional
9. **Color contrast**: Ensure icons are visible on colored backgrounds
10. **Use debugPrint** instead of print for console output

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

## Implementation Standards (Based on Confiabilidad Module)

### Page Structure Pattern
```dart
class PageName extends StatefulWidget {
  const PageName({super.key});
  
  @override
  PageNameState createState() => PageNameState();
}

class PageNameState extends State<PageName> {
  // State variables
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Load data from JSON
  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/file.json');
      final data = await json.decode(response);
      setState(() {
        items = List<Map<String, dynamic>>.from(data['items']);
        filteredItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error: $e');
      // Show error snackbar
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'module_name',
      customTitle: 'Page Title',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Search bar
          // Content area with responsive layout
        ],
      ),
    );
  }
}
```

### Module Main Page Pattern
```dart
// Grid of section cards with navigation
Widget _buildSectionCard(BuildContext context, Map<String, dynamic> section) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => section['page'],
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: section['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                section['icon'],
                size: 32,
                color: section['color'],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              section['title'],
              style: AppTextStyles.heading6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              section['description'],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutralTextGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Common UI Components

#### Search Bar
- White background with shadow
- Teal search icon
- Gray clear icon
- Responsive hint text

#### Data Cards (Mobile)
- White background with border
- Header with ID badge and title
- Status indicator with semantic colors
- Detail rows with consistent spacing

#### Data Tables (Desktop)
- Horizontal scroll for wide tables
- Consistent column spacing
- Status badges with colors
- Hover states on rows

#### Empty States
- Centered icon and message
- Contextual messaging
- Consistent styling

### Color Usage Guidelines
1. **Headers**: Primary color (teal) for main headers
2. **Section Cards**: Different colors per section with 0.1 opacity backgrounds
3. **Icons on Colored Backgrounds**: Use contrasting colors (teal on yellow, not yellow on yellow)
4. **Status Colors**:
   - Active/Success: `Colors.green`
   - In Progress/Review: `AppColors.primaryMediumTeal`
   - Inactive/Error: `AppColors.secondaryCoralRed`
   - Pending: `AppColors.neutralTextGray`
5. **Text**: `AppColors.neutralTextGray` for body text
6. **Backgrounds**: `AppColors.white` for cards, `AppColors.neutralLightBackground` for page background

## Memories
- This is a demo project for an Industrial Maintenance Management System created for GMO by Gianpierre Mio for Ebim
- The project follows the structure from C:\Users\gianx\Desktop\EMPRESAS\EBIM\GMO\Documento de Capacitacion
- No gradients are used - this is a formal business application
- All modules follow the same pattern established in the Confiabilidad module