# LinkStage

Mobile marketplace connecting event planners with creative professionals (DJs, photographers, decorators, content creators) in Rwanda.

## Features

- **Authentication**: Email/Password and Google Sign-In
- **Role selection**: Event Planner or Creative Professional
- **Profile discovery**: Browse creative professionals with filters
- **Settings**: Theme (light/dark/system), notifications, language
- **Bottom navigation**: Home, Search, Messages, Bookings, Profile

## Setup

### Prerequisites

- Flutter SDK ^3.11.0
- Firebase project

### Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd linkstage-dev
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   dart run flutterfire_cli:flutterfire configure
   ```
   This generates `lib/firebase_options.dart` from your Firebase project.

4. Add platform config:
   - **Android**: Download `google-services.json` from Firebase Console and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and add to `ios/Runner/`

5. Deploy Firestore rules (optional, for production):
   ```bash
   firebase deploy --only firestore
   ```

### Run

```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Theme, router, DI, constants
├── data/           # Data sources, models, repository implementations
├── domain/         # Entities, repositories, use cases
├── presentation/   # BLoC, pages, widgets (atoms, molecules, organisms)
├── app.dart
└── main.dart
```

## Architecture

- **Clean Architecture** with presentation, domain, and data layers
- **BLoC** for state management
- **Firebase** (Auth + Firestore) for backend
- **go_router** for navigation

## Testing

```bash
flutter test
```

## License

Private - LinkStage Project
