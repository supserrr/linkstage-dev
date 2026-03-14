import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splash_master/splash_master.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SplashMaster.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnimplementedError catch (_) {
    if (kDebugMode) {
      debugPrint(
        'Firebase not configured. Run: dart run flutterfire_cli:flutterfire configure',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init failed: $e');
    }
  }

  await initInjection();

  runApp(
    MaterialApp(
      home: SplashMaster.lottie(
        source: AssetSource('assets/lottie/Link-Stage-Animation-Light-Mode.json'),
        lottieConfig: LottieConfig(),
        backGroundColor: const Color(0xFFFAFAFA),
        nextScreen: LinkStageApp(),
      ),
    ),
  );
}
