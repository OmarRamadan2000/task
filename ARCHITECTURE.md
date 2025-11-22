# App Architecture Documentation

## Overview

This application follows **Clean Architecture** principles with **Cubit** (BLoC) state management, ensuring separation of concerns, testability, and maintainability.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Login Page  │  │Settings Page │  │ WebView Page │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                  │               │
│    ┌────▼─────┐     ┌────▼─────┐           │               │
│    │Auth Cubit│     │Settings  │           │               │
│    │          │     │  Cubit   │           │               │
│    └────┬─────┘     └────┬─────┘           │               │
└─────────┼──────────────────┼─────────────────┼──────────────┘
          │                  │                 │
┌─────────┼──────────────────┼─────────────────┼──────────────┐
│         │    DOMAIN LAYER  │                 │               │
│    ┌────▼─────┐       ┌───▼──────┐          │               │
│    │Use Cases │       │Use Cases │          │               │
│    │• SignIn  │       │• Get     │          │               │
│    │  Google  │       │  Settings│          │               │
│    │• SignIn  │       │• Save    │          │               │
│    │  Facebook│       │  Settings│          │               │
│    │• SignOut │       │• Scan    │          │               │
│    │• GetUser │       │  Devices │          │               │
│    └────┬─────┘       └────┬─────┘          │               │
│         │                  │                 │               │
│    ┌────▼─────┐       ┌───▼──────┐          │               │
│    │   Auth   │       │ Settings │          │               │
│    │Repository│       │Repository│          │               │
│    │Interface │       │Interface │          │               │
│    └────┬─────┘       └────┬─────┘          │               │
└─────────┼──────────────────┼─────────────────┼──────────────┘
          │                  │                 │
┌─────────┼──────────────────┼─────────────────┼──────────────┐
│         │     DATA LAYER   │                 │               │
│    ┌────▼─────┐       ┌───▼──────┐     ┌────▼─────┐        │
│    │   Auth   │       │ Settings │     │  Native  │        │
│    │Repository│       │Repository│     │ WebView  │        │
│    │   Impl   │       │   Impl   │     │ Widget   │        │
│    └────┬─────┘       └────┬─────┘     └──────────┘        │
│         │                  │                                 │
│    ┌────▼─────┐       ┌───▼──────┐                         │
│    │  Remote  │       │  Local   │                         │
│    │   Data   │       │   Data   │                         │
│    │  Source  │       │  Source  │                         │
│    └────┬─────┘       └────┬─────┘                         │
└─────────┼──────────────────┼────────────────────────────────┘
          │                  │
┌─────────┼──────────────────┼────────────────────────────────┐
│         │   EXTERNAL       │                                 │
│    ┌────▼─────┐       ┌───▼──────┐                         │
│    │ Firebase │       │  Shared  │                         │
│    │   Auth   │       │   Prefs  │                         │
│    │  Google  │       │          │                         │
│    │ Facebook │       └──────────┘                         │
│    └──────────┘                                             │
│    ┌──────────┐       ┌──────────┐                         │
│    │Bluetooth │       │   WiFi   │                         │
│    │  Scanner │       │   Info   │                         │
│    └──────────┘       └──────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

## Feature Structure

### Authentication Feature

```
auth/
├── domain/
│   ├── entities/
│   │   └── user.dart                    # User entity
│   ├── repositories/
│   │   └── auth_repository.dart         # Abstract repository
│   └── usecases/
│       ├── sign_in_with_google.dart     # Google sign-in use case
│       ├── sign_in_with_facebook.dart   # Facebook sign-in use case
│       ├── sign_out.dart                # Sign out use case
│       └── get_current_user.dart        # Get user use case
├── data/
│   ├── models/
│   │   └── user_model.dart              # User data model
│   ├── datasources/
│   │   └── auth_remote_data_source.dart # Firebase integration
│   └── repositories/
│       └── auth_repository_impl.dart    # Repository implementation
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart              # State management
    │   └── auth_state.dart              # State definitions
    └── pages/
        └── login_page.dart              # Login UI
```

### Settings Feature

```
settings/
├── domain/
│   ├── entities/
│   │   ├── app_settings.dart            # Settings entity
│   │   └── network_device.dart          # Device entity
│   ├── repositories/
│   │   └── settings_repository.dart     # Abstract repository
│   └── usecases/
│       ├── get_settings.dart            # Get settings use case
│       ├── save_settings.dart           # Save settings use case
│       └── get_available_devices.dart   # Scan devices use case
├── data/
│   ├── models/
│   │   ├── app_settings_model.dart      # Settings model
│   │   └── network_device_model.dart    # Device model
│   ├── datasources/
│   │   ├── settings_local_data_source.dart  # SharedPreferences
│   │   └── device_data_source.dart      # Bluetooth/WiFi scanner
│   └── repositories/
│       └── settings_repository_impl.dart # Repository implementation
└── presentation/
    ├── cubit/
    │   ├── settings_cubit.dart          # State management
    │   └── settings_state.dart          # State definitions
    └── pages/
        └── settings_page.dart           # Settings UI
```

### WebView Feature

```
webview/
└── presentation/
    └── pages/
        └── webview_page.dart            # WebView UI with controls
```

## State Management Flow

### Authentication Flow

```
User Action (Login Button)
    │
    ▼
AuthCubit.signInWithGooglePressed()
    │
    ▼
SignInWithGoogle Use Case
    │
    ▼
AuthRepository
    │
    ▼
AuthRemoteDataSource (Firebase)
    │
    ▼
Firebase Auth Service
    │
    ▼
Return User / Error
    │
    ▼
AuthCubit emits new state
    │
    ▼
UI Updates (BlocBuilder)
```

### Settings Flow

```
User Action (Scan Devices)
    │
    ▼
SettingsCubit.scanDevices()
    │
    ▼
GetAvailableDevices Use Case
    │
    ▼
SettingsRepository
    │
    ▼
DeviceDataSource
    │
    ├─► Bluetooth Scanner (flutter_blue_plus)
    └─► WiFi Scanner (network_info_plus)
    │
    ▼
Return Device List
    │
    ▼
SettingsCubit emits SettingsLoaded
    │
    ▼
UI Updates with Device List
```

## Dependency Injection

Uses **GetIt** for service locator pattern:

```dart
// Registration
sl.registerFactory(() => AuthCubit(...));
sl.registerLazySingleton(() => SignInWithGoogle(sl()));
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));

// Usage in UI
BlocProvider(create: (_) => sl<AuthCubit>())
```

## Key Design Patterns

### 1. **Repository Pattern**
- Abstracts data sources
- Provides clean API for domain layer
- Handles data source switching

### 2. **Use Case Pattern**
- Single responsibility principle
- Reusable business logic
- Easy to test

### 3. **Cubit Pattern (Simplified BLoC)**
- State management
- Separates business logic from UI
- Reactive programming

### 4. **Dependency Injection**
- Loose coupling
- Easy testing
- Service locator pattern with GetIt

### 5. **Clean Architecture**
- Separation of concerns
- Independent of frameworks
- Testable

## Data Flow

### Read Data
```
UI → Cubit → Use Case → Repository → Data Source → External Service
                                                              │
UI ← Cubit ← Use Case ← Repository ← Data Source ← Response ←┘
```

### Write Data
```
UI → Cubit → Use Case → Repository → Data Source → Save to Storage
                                                              │
UI ← Cubit ← Use Case ← Repository ← Data Source ← Success  ←┘
```

## Error Handling

```
External Service Error
    │
    ▼
Exception (in Data Source)
    │
    ▼
Failure (in Repository)
    │
    ▼
Either<Failure, Success> (to Use Case)
    │
    ▼
Error State (in Cubit)
    │
    ▼
Error UI (Show SnackBar)
```

## Benefits of This Architecture

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Changes in one layer don't affect others
3. **Scalability**: Easy to add new features
4. **Flexibility**: Can swap implementations easily
5. **Separation of Concerns**: Each class has one responsibility
6. **Reusability**: Use cases can be reused across features
7. **Independence**: Domain layer has no dependencies on external frameworks

## Testing Strategy

```
Unit Tests
├── Use Cases (business logic)
├── Repositories (data handling)
└── Cubits (state management)

Widget Tests
├── Login Page
├── Settings Page
└── WebView Page

Integration Tests
└── Complete user flows
```
