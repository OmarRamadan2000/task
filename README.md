# Task App

> A modern Flutter application featuring social media authentication, settings management, and WebView functionality, built with Clean Architecture and Cubit state management.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Features

### 🔐 Authentication
- **Google Sign-In** - Seamless OAuth authentication
- **Facebook Login** - Social media integration
- **Firebase Auth** - Secure user management
- Beautiful gradient UI with Material Design 3

### ⚙️ Settings Management
- **Web URL Configuration** - Customize WebView destination
- **Device Scanning** - Discover WiFi and Bluetooth devices
- **Persistent Storage** - Save user preferences locally
- Real-time device connection status

### 🌐 WebView Browser
- **Full-Featured Browser** - Navigate any website
- **Navigation Controls** - Back, forward, refresh, and home buttons
- **Progress Indicator** - Visual loading feedback
- **URL Bar** - Display current page address
- **Auto URL Updating** - Changes reflect immediately from settings

## 📸 Screenshots

<picture>
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://github.com/user-attachments/assets/0765c444-e0d9-4375-b899-abc11dd799c7" width="280">
</picture>
<picture>
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://github.com/user-attachments/assets/14247db6-0735-4096-b2ea-d274267ce7d5" width="280">
</picture>
<picture>
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://github.com/user-attachments/assets/98759ee4-aab9-48f8-a500-2fab6193cce5" width="280">
</picture>
<picture>
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://github.com/user-attachments/assets/fd9e1728-d284-448b-9c4d-7834f3f5ebe8" width="280">
</picture>
<picture>
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://github.com/user-attachments/assets/f870a8ca-0eb3-4aac-a239-f461fc573517" width="280">
</picture>

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **Cubit** state management:

```
lib/
├── core/                          # Shared utilities
│   ├── error/
│   │   ├── exceptions.dart       # Custom exceptions
│   │   └── failures.dart         # Error handling
│   ├── network/
│   │   └── network_info.dart     # Connectivity checking
│   └── usecases/
│       └── usecase.dart          # Base use case class
│
├── features/                      # Feature modules
│   ├── auth/                     # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/      # Remote & local data sources
│   │   │   ├── models/           # Data models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/         # Business entities
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   └── usecases/         # Business logic
│   │   └── presentation/
│   │       ├── cubit/            # State management
│   │       ├── pages/            # UI screens
│   │       └── widgets/          # Reusable components
│   │
│   ├── settings/                 # Settings feature
│   │   └── [similar structure]
│   │
│   └── webview/                  # WebView feature
│       └── presentation/
│
├── injection_container.dart      # Dependency injection (GetIt)
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # App entry point
```

### 🎯 Design Patterns

- **Clean Architecture** - Separation of concerns across layers
- **Repository Pattern** - Abstract data sources
- **Dependency Injection** - Using GetIt service locator
- **BLoC/Cubit Pattern** - Predictable state management
- **Either Pattern** - Functional error handling with Dartz
