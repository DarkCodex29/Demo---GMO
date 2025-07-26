# 🏭 GMO - Sistema de Gestión de Mantenimiento Operacional

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3+-02569B.svg?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg?logo=dart)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Windows-green.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)]()
[![Demo](https://img.shields.io/badge/Status-Demo-orange.svg)]()

> **Sistema empresarial de gestión de mantenimiento industrial desarrollado con Flutter**  
> Proyecto demo creado por **Gianpierre Mio** para **EBIM** como demostración de capacidades en **GMO** (Gestión de Mantenimiento Operacional).

<div align="center">
  <img src="assets/images/logo_demo.png" alt="Logo GMO" width="150" />
  
  <br/>
  
  [![🚀 Ver Demo](https://img.shields.io/badge/🚀%20Ver%20Demo-Live%20Preview-055658?style=for-the-badge)]()
  [![📱 Descargar APK](https://img.shields.io/badge/📱%20Descargar-APK%20Android-5AA97F?style=for-the-badge)]()
</div>

---

## 🌟 Características Principales

### 🔐 **Autenticación y Seguridad**
- Sistema de login seguro con persistencia de sesión
- Gestión de roles y permisos de usuario
- Recordar credenciales y logout automático

### 🏗️ **Módulo de Confiabilidad** (Datos Maestros)
- **Gestión de Equipos**: Catálogo master de equipos industriales
- **Ubicaciones Técnicas**: Jerarquía de ubicaciones y centros de trabajo  
- **Clases de Equipos**: Clasificación y categorización de activos
- **Materiales y Repuestos**: Gestión de inventarios y catálogos
- **Hojas de Ruta**: Instrucciones de trabajo y procedimientos
- **Estrategias de Mantenimiento**: Definición de planes preventivos

### 📋 **Módulo de Demanda**
- **Avisos de Mantenimiento**: Registro y seguimiento de solicitudes
- **Gestión de Demanda**: Procesamiento y priorización de trabajo
- **Sistema de Notificaciones**: Alertas en tiempo real

### 📅 **Módulo de Planificación**  
- **Creación de Órdenes**: Generación automática de órdenes de trabajo
- **Gestión de Capacidades**: Planificación de recursos y personal

### 🕐 **Módulo de Programación**
- **Calendario de Mantenimiento**: Vista temporal de actividades
- **Programación de Recursos**: Asignación de personal y equipos
- **Análisis de Carga de Trabajo**: Optimización de capacidades

### ⚡ **Módulo de Ejecución**
- **Órdenes de Trabajo**: Gestión en campo del trabajo operativo
- **Registro de Ejecución**: Captura de horas, materiales y actividades
- **Cierre Técnico**: Finalización y documentación de trabajos

### 📊 **Módulo de Seguimiento y Control**
- **Reportes de Stock**: Inventarios y disponibilidad de materiales
- **Reportes de Órdenes**: Seguimiento de trabajo ejecutado
- **Reportes de Capacidades**: Análisis de utilización de recursos
- **Reportes de Equipos**: Estados y rendimiento de activos
- **Log de Fallas**: Registro histórico de eventos críticos

## 🛠️ Tecnologías y Herramientas

### **Frontend & Framework**
- **Flutter 3.24.3+**: Framework multiplataforma de Google
- **Dart 3.0+**: Lenguaje de programación optimizado para UI
- **Material Design 3**: Sistema de diseño moderno de Google
- **Responsive Framework**: Diseño adaptativo para múltiples dispositivos

### **Gestión de Estado**
- **StatefulWidget**: Gestión de estado local
- **SharedPreferences**: Persistencia de datos de sesión
- **Provider Pattern**: Inyección de dependencias

### **UI/UX Features**
- **Tema personalizado**: Paleta de colores corporativa
- **Animaciones fluidas**: Transiciones y efectos visuales
- **Design System**: Componentes reutilizables y consistentes
- **Dark/Light Theme**: Soporte para múltiples temas
- **Responsive Design**: Adaptación automática a diferentes pantallas

### **Arquitectura y Patrones**
- **Clean Architecture**: Separación de responsabilidades
- **Repository Pattern**: Abstracción de datos
- **Modular Structure**: Organización por funcionalidades
- **SOLID Principles**: Principios de desarrollo limpio

### **Herramientas de Desarrollo**
- **JSON**: Serialización y manejo de datos
- **Flutter Inspector**: Herramientas de debugging
- **Hot Reload**: Desarrollo en tiempo real
- **Code Generation**: Generación automática de código

## 🚀 Guía de Instalación

### 📋 **Requisitos Previos**

| Herramienta | Versión Mínima | Instalación |
|-------------|----------------|-------------|
| 🦋 **Flutter SDK** | 3.24.3+ | [Descargar Flutter](https://flutter.dev/docs/get-started/install) |
| 🎯 **Dart SDK** | 3.0.0+ | Incluido con Flutter |
| 🌐 **Navegador Web** | Chrome 90+ | Para testing web |
| 📱 **Android Studio** | 2021.1+ | Para desarrollo Android |
| 🍎 **Xcode** | 13+ | Para desarrollo iOS (solo macOS) |

### ⚡ **Instalación Rápida**

```bash
# 1️⃣ Clonar el repositorio
git clone https://github.com/tu-usuario/gmo-demo.git
cd gmo-demo

# 2️⃣ Instalar dependencias
flutter pub get

# 3️⃣ Verificar configuración
flutter doctor

# 4️⃣ Ejecutar en diferentes plataformas
flutter run -d chrome              # 🌐 Web (Recomendado)
flutter run -d windows             # 🪟 Windows
flutter run -d android             # 📱 Android
flutter run -d ios                 # 🍎 iOS
flutter run                        # 🎯 Dispositivo por defecto
```

### 🔧 **Comandos Útiles**

```bash
# 🏗️ Construir para producción
flutter build web                  # Web
flutter build apk                  # Android APK
flutter build windows              # Windows

# 🧪 Testing y calidad
flutter test                       # Ejecutar tests
flutter analyze                    # Análisis estático
flutter pub outdated               # Verificar dependencias

# 🧹 Limpiar proyecto
flutter clean && flutter pub get   # Limpiar y reinstalar
```

### 🎯 **Acceso Rápido al Demo**

```bash
# Ejecutar directamente en web (más rápido)
flutter run -d chrome --web-port 8080

# URL local: http://localhost:8080
```

## 🗂️ Estructura de Datos y Configuración

### 💾 **Almacenamiento de Datos**

| Mecanismo | Descripción | Uso en la aplicación | Archivos |
|-----------|-------------|----------------------|----------|
| 🔐 **SharedPreferences** | Almacenamiento clave-valor | Autenticación, sesiones, preferencias | - |
| 📄 **JSON Local** | Archivos de datos estructurados | Catálogos, datos maestros, configuración | `assets/data/*.json` |
| 🗄️ **SQLite** | Base de datos local (futuro) | Operaciones offline, caché | Planificado |

### 📊 **Datos de Demostración**

Los datos incluidos en `assets/data/` para testing:

| Archivo | Descripción | Registros | Módulo |
|---------|-------------|-----------|---------|
| 👥 `users.json` | Usuarios y credenciales | 3 usuarios | Autenticación |
| 🏷️ `class.json` | Clases de equipos | 15 clases | Confiabilidad |
| ⚙️ `equipament.json` | Catálogo de equipos | 125 equipos | Confiabilidad |
| 👔 `job.json` | Puestos de trabajo | 12 puestos | Confiabilidad |
| 📍 `locations.json` | Ubicaciones técnicas | 28 ubicaciones | Confiabilidad |
| 📋 `ordenes.json` | Órdenes de trabajo | 156 órdenes | Planificación |
| ⚠️ `avisos.json` | Avisos de mantenimiento | 89 avisos | Demanda |
| 📦 `materials.json` | Materiales y repuestos | 342 materiales | Confiabilidad |
| 🛠️ `instrucciones_trabajo.json` | Instrucciones técnicas | 45 instrucciones | Confiabilidad |
| 👥 `equipos_trabajo.json` | Equipos de trabajo | 18 equipos | Confiabilidad |

### 🔑 **Credenciales de Acceso**

| Usuario | Contraseña | Rol | Permisos |
|---------|------------|-----|----------|
| `admin` | `admin123` | Administrador | Acceso completo |
| `user1` | `password1` | Técnico | Módulos operativos |
| `user2` | `password2` | Supervisor | Reportes y seguimiento |

## 🏗️ Arquitectura del Sistema

### 📁 **Estructura del Proyecto**

```
📦 gmo-demo/
├── 🎯 lib/                           # Código fuente principal
│   ├── 🚀 main.dart                 # Punto de entrada
│   └── 📂 src/
│       ├── 📱 app.dart              # Configuración de la app
│       ├── 🔧 core/                 # Funcionalidades core
│       │   └── 🌐 services/         # Servicios globales
│       ├── 🏛️ modules/              # Módulos funcionales
│       │   ├── 🔐 auth/             # Autenticación
│       │   ├── 🏗️ confiabilidad/    # Datos maestros
│       │   ├── 📋 demanda/          # Gestión de demanda
│       │   ├── 📅 planificacion/    # Planificación
│       │   ├── 🕐 programacion/     # Programación
│       │   ├── ⚡ ejecucion/        # Ejecución
│       │   └── 📊 seguimiento_control/ # Reportes
│       ├── 🎨 shared/               # Componentes compartidos
│       │   ├── 🧩 layouts/          # Layouts reutilizables
│       │   ├── 🎪 widgets/          # Widgets personalizados
│       │   └── 📄 pages/            # Páginas compartidas
│       └── 🎭 theme/                # Sistema de diseño
│           ├── 🎨 app_colors.dart   # Paleta de colores
│           ├── ✍️ app_text_styles.dart # Tipografía
│           └── 🎪 app_theme.dart    # Tema global
├── 📦 assets/                       # Recursos estáticos
│   ├── 📊 data/                     # Datos JSON demo
│   └── 🖼️ images/                   # Imágenes y logos
├── 🧪 test/                         # Tests unitarios
├── 🌐 web/                          # Configuración web
├── 📱 android/                      # Configuración Android
├── 🍎 ios/                          # Configuración iOS
├── 🪟 windows/                      # Configuración Windows
└── 📋 pubspec.yaml                  # Dependencias
```

### 🔄 **Patrones y Principios**

#### **Arquitectura Modular**
- 🏗️ **Separation of Concerns**: Cada módulo maneja su responsabilidad específica
- 🧩 **Reusable Components**: Widgets y layouts compartidos
- 🎯 **Single Responsibility**: Una función por clase/archivo
- 🔗 **Loose Coupling**: Mínima dependencia entre módulos

#### **Gestión de Estado**
```dart
// 🔄 Local State Management
StatefulWidget → setState() → UI Update

// 💾 Persistent State
SharedPreferences → Local Storage → Session Management

// 📊 Data Flow
JSON Assets → Data Models → UI Components
```

#### **Navegación y Routing**
```dart
// 🧭 Navigation Pattern
MainLayout → Module Pages → Detail Pages
     ↓           ↓              ↓
  Sidebar    Grid Cards    Specific Forms
```

## 🧪 Testing y Calidad

### 🔍 **Herramientas de Testing**

```bash
# 🧪 Ejecutar todos los tests
flutter test

# 📊 Test con cobertura
flutter test --coverage

# 🔬 Tests específicos
flutter test test/widget_test.dart

# 🚀 Tests de integración
flutter drive --target=test_driver/app.dart
```

### 📈 **Análisis de Código**

```bash
# 🔍 Análisis estático
flutter analyze

# 📏 Métricas de código
dart pub global run dart_code_metrics:metrics analyze lib

# 🎯 Verificar dependencias
flutter pub outdated
```

## 🎨 Design System

### 🎨 **Paleta de Colores Corporativa**

| Color | Hex | Uso |
|-------|-----|-----|
| 🔵 **Primary Dark Teal** | `#055658` | Headers, botones principales |
| 🟢 **Primary Medium Teal** | `#056769` | Elementos secundarios |
| 💚 **Primary Mint Green** | `#5AA97F` | Estados de éxito |
| 🟢 **Primary Light Green** | `#AEEA94` | Acentos suaves |
| 🔴 **Coral Red** | `#EA5050` | Errores y alertas |
| 🔵 **Bright Blue** | `#2A77E8` | Información |
| 🟡 **Golden Yellow** | `#FFD96E` | Advertencias |

### ✍️ **Tipografía**
- **Fuente Principal**: DM Sans (Google Fonts)
- **Pesos**: Regular (400), Medium (500), Bold (700)
- **Escalas**: Responsive según dispositivo

### 🧩 **Componentes**
- **Cards**: Bordes redondeados 12px, sombra sutil
- **Botones**: Consistentes con colores corporativos
- **Formularios**: Estados de focus con colores primarios

## 🚀 Deployment

### 🌐 **Web Deployment**

```bash
# Construir para web
flutter build web --release

# Servir localmente
flutter build web && python -m http.server 8000 -d build/web
```

### 📱 **Mobile Deployment**

```bash
# Android APK
flutter build apk --release

# Android Bundle (para Play Store)
flutter build appbundle --release

# iOS (requiere macOS)
flutter build ios --release
```

### 🪟 **Desktop Deployment**

```bash
# Windows
flutter build windows --release

# macOS (requiere macOS)
flutter build macos --release

# Linux
flutter build linux --release
```

## 👨‍💻 Desarrollador & Contacto

### 🧑‍💼 **Información del Desarrollador**

<div align="center">

**Gianpierre Mio**  
*Full Stack Flutter Developer*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Gianpierre%20Mio-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/gianpierre-mio)
[![Email](https://img.shields.io/badge/Email-gianxs296@gmail.com-D14836?style=for-the-badge&logo=gmail)](mailto:gianxs296@gmail.com)
[![Phone](https://img.shields.io/badge/Teléfono-+51%20952%20164%20832-25D366?style=for-the-badge&logo=whatsapp)](tel:+51952164832)

</div>

### 🏢 **Contexto del Proyecto**
- **Cliente**: EBIM (Empresa de demostración)
- **Propósito**: Demo de capacidades en GMO
- **Tipo**: Proyecto de demostración técnica
- **Estado**: Completado como MVP funcional

### 📧 **Soporte y Consultas**
Para consultas técnicas, personalizaciones o implementación:
- 📧 **Email**: gianxs296@gmail.com
- 📱 **WhatsApp**: +51 952 164 832
- 💼 **LinkedIn**: Gianpierre Mio

---

## 📄 Licencia

```
MIT License

Copyright (c) 2024 Gianpierre Mio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

<div align="center">

---

**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub**

[![GitHub stars](https://img.shields.io/github/stars/tu-usuario/gmo-demo?style=social)]()
[![GitHub forks](https://img.shields.io/github/forks/tu-usuario/gmo-demo?style=social)]()

---

*Desarrollado con ❤️ y Flutter por **Gianpierre Mio** para **EBIM***

</div>
