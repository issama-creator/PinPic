import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/settings_repository.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local-only reminders for document expiry dates (no cloud).
class ExpiryReminderService {
  ExpiryReminderService(this._settings);

  final SettingsRepository _settings;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  var _ready = false;

  static const _channelId = 'pinpic_expiry';
  static const _channelName = 'Сроки документов';
  static const _offsets = <int>[7, 3, 0];

  Future<void> ensureInitialized() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Напоминания о сроках документов на этом устройстве',
              importance: Importance.defaultImportance,
            ),
          );
    }
    _ready = true;
  }

  Future<bool> requestPermission() async {
    await ensureInitialized();
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  Future<void> syncPhoto(PhotoEntity photo) async {
    final settings = await _settings.getSettings();
    if (!settings.expiryRemindersEnabled) {
      await cancelForMedia(photo.mediaId);
      return;
    }
    final expiresAt = photo.expiresAt;
    final category = photo.category;
    if (expiresAt == null ||
        category == null ||
        !CategoryEngine.documentFamily.contains(category)) {
      await cancelForMedia(photo.mediaId);
      return;
    }
    await ensureInitialized();
    await cancelForMedia(photo.mediaId);

    final title =
        photo.cardTitle?.trim().isNotEmpty == true
            ? photo.cardTitle!.trim()
            : (category);
    final end = DateTime(expiresAt.year, expiresAt.month, expiresAt.day, 10);

    for (final daysBefore in _offsets) {
      final when = end.subtract(Duration(days: daysBefore));
      if (when.isBefore(DateTime.now())) continue;
      final status = DocumentExpiryStatus.fromDate(
        expiresAt,
        now: when,
      );
      final body = status?.label ?? 'Проверьте срок документа';
      final id = _notificationId(photo.mediaId, daysBefore);
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          'PinPic: $body',
          tz.TZDateTime.from(when, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription:
                  'Напоминания о сроках документов на этом устройстве',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: photo.mediaId,
        );
      } catch (error, stack) {
        debugPrint('Schedule expiry reminder failed: $error\n$stack');
      }
    }
  }

  Future<void> syncPhotos(Iterable<PhotoEntity> photos) async {
    for (final photo in photos) {
      if (photo.expiresAt == null) continue;
      await syncPhoto(photo);
    }
  }

  Future<void> cancelForMedia(String mediaId) async {
    await ensureInitialized();
    for (final daysBefore in _offsets) {
      await _plugin.cancel(_notificationId(mediaId, daysBefore));
    }
  }

  Future<void> cancelAll() async {
    await ensureInitialized();
    await _plugin.cancelAll();
  }

  int _notificationId(String mediaId, int daysBefore) {
    return Object.hash(mediaId, daysBefore) & 0x7fffffff;
  }
}
