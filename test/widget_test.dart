import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/theme/app_theme.dart';
import 'package:pinpic/widgets/pinpic_logo.dart';

void main() {
  testWidgets('PinPic brand widgets render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Column(
            children: [
              PinPicLogo(size: 64),
              Text(AppConstants.appName),
            ],
          ),
        ),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.byType(PinPicLogo), findsOneWidget);
  });
}
