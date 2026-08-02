import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/features/home/presentation/home_screen.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
import 'package:pinpic/theme/app_theme.dart';
import 'package:pinpic/widgets/async_state_view.dart';
import 'package:pinpic/widgets/pinpic_logo.dart';

void main() {
  test('does not rescan an unchanged completed library on app entry', () {
    final settings = AppSettingsEntity.initial()
      ..initialScanCompleted = true
      ..totalIndexed = 124
      ..indexedPipelineVersion = HashUtils.indexPipelineVersion;

    expect(shouldStartStartupIndex(settings, 124), isFalse);
    expect(shouldStartStartupIndex(settings, 125), isTrue);
    settings.indexedPipelineVersion = HashUtils.indexPipelineVersion - 1;
    expect(shouldStartStartupIndex(settings, 124), isTrue);
  });

  testWidgets('PinPic brand widgets render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Column(
            children: [PinPicLogo(size: 64), Text(AppConstants.appName)],
          ),
        ),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.byType(PinPicLogo), findsOneWidget);
  });

  testWidgets('retry state shows safe message and retries', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AppRetryState(
          message: 'Не удалось загрузить данные',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    expect(retried, isTrue);
  });

  testWidgets('empty and loading states render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Column(
          children: [
            CircularProgressIndicator(),
            AppEmptyState(
              title: 'Пока пусто',
              description: 'Добавьте первый элемент',
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Пока пусто'), findsOneWidget);
    expect(find.text('Добавьте первый элемент'), findsOneWidget);
  });
}
