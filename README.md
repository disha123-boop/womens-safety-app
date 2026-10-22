# SafeHer

SafeHer is a Flutter women's safety app with emergency contacts, location-aware
SOS alerts, and an optional Node.js backend for sending SMS through Twilio.

## Requirements

- Flutter SDK compatible with the version constraint in `pubspec.yaml`
- Node.js and npm (for the backend)
- Android Studio or Xcode for building on mobile platforms

## Run the Flutter app

```shell
flutter pub get
flutter run
```

The app requests location permissions for location features. Configure the
backend URL in the app for the device or emulator you are using; `localhost`
on a physical device refers to that device, not your development computer.

## Run the backend

```shell
cd backend
npm install
```

Copy `.env.example` to `.env` and configure the Twilio values if you want to
enable SMS. The backend defaults to demo mode, which logs a simulated alert
instead of sending messages.

```shell
node server.js
```

To send real SMS, set `DEMO_MODE=false` and provide valid Twilio credentials and
a Twilio phone number. Real SMS may incur charges. Never commit `.env` or put
credentials in source control.

## Checks

```shell
flutter analyze
flutter test
```

## Safety note

This project is not a substitute for contacting local emergency services.
Verify location permissions, backend connectivity, and SMS delivery before
relying on any alert feature.
