/// Application-wide constants for LinkStage.
class AppConstants {
  AppConstants._();

  static const String appName = 'LinkStage';

  /// Minimum password length for validation.
  static const int minPasswordLength = 8;

  /// Regex for basic email validation.
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
}
