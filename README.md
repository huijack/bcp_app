# UCSI Report

[![Framework](https://img.shields.io/badge/framework-Flutter-blue)](https://flutter.dev/)
[![Backend](https://img.shields.io/badge/backend-Firebase-orange)](https://firebase.google.com/)
[![Database](https://img.shields.io/badge/database-Firestore-yellow)](https://firebase.google.com/products/firestore)
[![Storage](https://img.shields.io/badge/storage-Firebase%20Storage-green)](https://firebase.google.com/products/storage)

UCSI Report aims to streamline the process of reporting and managing maintenance issues on campus. This system replaces traditional methods such as manual form submissions and WhatsApp communication with a more efficient, user-friendly, and accountable approach.

## Prerequisites

- **Platform**: Windows, MacOS, or Linux
- **Code Editor**: Visual Studio Code (VSCode)
  - Download: [VSCode](https://code.visualstudio.com/download)
- **SDK**: Flutter SDK
  - Installation Guide: [Flutter SDK](https://docs.flutter.dev/get-started/install)
- **Packages**: Android Studio
  - Download: [Android Studio](https://developer.android.com/studio)

## Installation Steps

1. **Visual Studio Code**
   - Download and install Visual Studio Code from the [provided link](https://code.visualstudio.com/download).
   - In the VS Code extension marketplace, search for “Flutter” and install the Flutter extension.

2. **Flutter SDK**
   - Download the Flutter SDK zip file from the [Flutter website](https://docs.flutter.dev/get-started/install).
   - Extract the Flutter SDK and add its path to the User Variables path in the system environment variables.

3. **Android Studio**
   - Download and install Android Studio from the [provided link](https://developer.android.com/studio).
   - Open Android Studio, click on “More Actions”, and select “SDK Manager”.
   - Navigate to “SDK Tools” and ensure “Android SDK Command-line Tools (latest)” is installed.

4. **Setup Flutter Doctor**
   - Open VS Code terminal (or command prompt terminal) and type `flutter doctor` to diagnose any issues.
   - If there are issues in the Android toolchain category, run `flutter doctor --android-licenses` to resolve them.

5. **Android Emulator Setup**
   - Open Android Studio, click on “More Actions”, and select “Virtual Device Manager”.
   - Click the “+” icon, choose your preferred device, and proceed by clicking “Next”.
   - Choose your preferred system image to install and click “Next”.
   - Set your AVD name for your Android Emulator and finish by clicking “Finish”.

6. **Create a New Flutter Application**
   - In VS Code, press `CTRL + SHIFT + P`, and select “Flutter: New Application Project”.
   - Choose or create a folder for your project and set the project name accordingly.

7. **Run the Application**
   - In your new Flutter application project, click the “No Device” option and select your preferred mobile emulator.
   - Click “Start Debugging” to run the application.

## Running the App

1. Ensure that your preferred mobile emulator is running.
2. Open your project in VS Code.
3. Click the "Run" option and start debugging to launch the application.

## Support

For further assistance, please refer to the official documentation of [Flutter](https://docs.flutter.dev) and [Android Studio](https://developer.android.com/studio).

---

**Version**: 1.0 (2024)