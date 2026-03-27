# 🖋️ MyPen - Fountain Pen & Ink Inventory

MyPen is a premium, feature-rich Flutter application designed for fountain pen enthusiasts to manage their collections of pens, inks (bottles & cartridges), and wishlists with ease. 

Built with a focus on both performance and security, MyPen leverages **Firebase** for cloud synchronization and **Hive** for encrypted local storage.

---

## ✨ Key Features

- **Inventory Management**: Track pens, ink bottles, and cartridges with detailed metadata.
- **Cloud Sync**: Seamless data synchronization across devices using Firebase.
- **Secure Local Storage**: Data is encrypted locally using Hive and Flutter Secure Storage.
- **Analytics Dashboard**: Get insights into your collection with visual data representations.
- **Wishlist**: Maintain a list of desired items for future acquisitions.
- **Global Search**: Find any item in your collection instantly.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Stateful Widgets & Provider-like patterns.
- **Local Database**: [Hive](https://pub.dev/packages/hive) (Encrypted)
- **Backend Service**: [Firebase](https://firebase.google.com/) (Authentication & Cloud Firestore)
- **Local Security**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

## 🚀 Step-by-Step Setup Guide

Follow these steps to set up the project locally on your machine.

### 1. Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Android Studio](https://developer.android.com/studio) / [Xcode](https://developer.apple.com/xcode/)
- [Firebase CLI](https://firebase.google.com/docs/cli) (Recommended)

### 2. Clone the Repository
```bash
git clone https://github.com/midlaj-muhammed/MyPen.git
cd MyPen
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Setup Firebase (Handling Git-Ignored Files) 🔒
This project requires specific Firebase configuration files that are typically excluded from version control for security. You must add them manually:

#### **For Android:**
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project and add an Android App.
3. Download the `google-services.json` file.
4. Place it in the following directory:
   `android/app/google-services.json`

#### **For iOS:**
1. Add an iOS App to your Firebase project.
2. Download the `GoogleService-Info.plist` file.
3. Open the project in Xcode and drag the file into the `Runner` folder (ensure "Copy items if needed" is selected).

#### **For Web & Desktop (Optional):**
If you have the Firebase CLI installed, you can re-generate the config file:
```bash
flutterfire configure
```

### 5. Generate Hive Adapters
The project uses Hive for local storage. You need to generate the TypeAdapters before running:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Run the Project
Connect your device or start an emulator and run:
```bash
flutter run
```

---

## 🛡️ Security & Git Best Practices
The following files are ignored by Git to protect your API keys and sensitive data:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart` (optional, can be generated)
- `pubspec.lock` (sometimes ignored in libraries, but usually committed in apps)
- `*.keystore` / `*.jks` (Android release keys)

**Never commit your `key.properties` or keystore files!**

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License
This project is for personal use and portfolio demonstration. See the LICENSE file for details.
