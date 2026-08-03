import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';

/// Route stub — scan CTA was removed from home.
class ScanDocumentScreen extends StatelessWidget {
  const ScanDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Скан'),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'PinPic ищет важное уже в вашей галерее.\n'
            'Отдельно сканировать не нужно — сфотографируйте документ '
            'как обычно, и он попадёт в память при индексации.',
            style: TextStyle(
              color: AppColors.textMuted,
              height: 1.45,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
