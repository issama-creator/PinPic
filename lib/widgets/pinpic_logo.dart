import 'package:flutter/material.dart';

class PinPicLogo extends StatelessWidget {
  const PinPicLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
    );
  }
}
