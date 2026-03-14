# Splash Screen Setup

The app uses [splash_master](https://pub.dev/packages/splash_master) to unify native and Flutter splash screens. The native splash is shown while the app starts; then a Lottie animation runs in Flutter before the main app (go_router) is shown.

## Flow

1. **Native splash** — Configured via the `splash_master:` block in `pubspec.yaml` (color, optional image, Android 12+ options). The OS shows this until the Flutter engine is ready.
2. **Flutter splash** — `SplashMaster.initialize()` defers the first frame; `main()` runs Firebase init and DI, then runs a `MaterialApp` whose home is `SplashMaster.lottie(...)` with the LinkStage Lottie asset. When the animation is ready, the app navigates to `LinkStageApp()` (go_router).
3. **Router** — Initial route is `/`; a placeholder is built briefly while `SplashNotifier` completes (auth + min duration). Redirect then sends the user to onboarding, login, or home.

## Changing the native splash

Edit the `splash_master:` section in `pubspec.yaml` (e.g. `color`, `image`, `android_12_and_above`). After any change to that block, run:

```bash
dart run splash_master create
```

This regenerates native splash resources for iOS and Android. If you have custom native splash assets, back them up first; the command may overwrite them.

## Lottie asset

The Flutter splash uses `assets/lottie/Link-Stage-Animation-Light-Mode.json`. To switch to dark mode or a different asset, update the `source` argument of `SplashMaster.lottie(...)` in `lib/main.dart`.
