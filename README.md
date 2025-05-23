# 💬 ChatApp

A modern Flutter chat application with Firebase integration, offering real-time messaging capabilities and a rich set of features.

## ✨ Features

- **💬 Real-time Messaging**: Instant message delivery using Firebase Cloud Firestore
- **🔐 Authentication**: Secure user login and registration with Firebase Auth
- **🔔 Notifications**:
  - Push notifications for new messages
  - Local notifications for offline updates
- **🎨 User Experience**:
  - Modern Material Design UI
  - Animated splash screen
  - Smooth transitions and interactions
  - Dark/Light theme support
- **💾 Data Persistence**: Local storage for user preferences and offline data

## 🛠️ Tech Stack

- **📱 Core Framework**: Flutter SDK (>=3.3.0)
- **🔥 Backend Services**:
  - Firebase Authentication
  - Cloud Firestore (Database)
  - Firebase Storage (Media)
  - Firebase Cloud Messaging
  - Firebase Analytics
- **📦 Key Packages**:
  - `provider` for state management
  - `google_fonts` for typography
  - `lottie` for animations
  - `flutter_local_notifications` for local alerts

## 🚀 Getting Started

### 📋 Prerequisites

- Flutter SDK installed
- Android Studio/VS Code with Flutter plugins
- Firebase account and project setup

### ⚙️ Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/kartik17k/ChatApp
cd ChatApp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Firebase Configuration:
   - Download and add `google-services.json` to `android/app/`
   - Download and add `GoogleService-Info.plist` to `ios/Runner/`
   - Enable required Firebase services in console

4. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
ChatApp/
├── lib/              # Main application code
│   ├── models/       # Data models
│   ├── screens/      # UI screens
│   ├── services/     # Firebase services
│   ├── utils/        # Helper functions
│   └── widgets/      # Reusable components
├── assets/           # Static assets
│   ├── images/       # Image resources
│   └── animations/   # Lottie animations
├── android/          # Android specific code
```

## 💻 Development

- Follow Flutter's official style guide
- Use meaningful commit messages
- Test on multiple devices before pushing changes
- Update documentation when adding new features

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## ❓ Support

For support, please open an issue in the repository or contact the maintainers.

## 📧 Contact

For questions or suggestions, feel free to reach out at:
- 📧 Email: kartikkattishettar@gmail.com
- 👨‍💻 GitHub: [Kartik](https://github.com/kartik17k)