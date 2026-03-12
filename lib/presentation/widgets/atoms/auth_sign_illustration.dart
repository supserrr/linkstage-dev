import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sign in / Sign up illustration, theme-aware (light/dark).
class AuthSignIllustration extends StatelessWidget {
  const AuthSignIllustration({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/images/auth_sign_illustration_dark.svg'
        : 'assets/images/auth_sign_illustration_light.svg';
    return SvgPicture.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
