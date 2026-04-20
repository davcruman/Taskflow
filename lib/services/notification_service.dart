import 'dart:typed_data'; 
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    // CORRECCIÓN: Se debe usar el argumento nombrado 'settings'
    await _notifications.initialize(
      settings: initSettings, 
    );

    // Solicitar permisos para Android 13+
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool enableVibration = true,
  }) async {
    // Verificamos que la fecha sea futura
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint("⚠️ La fecha de notificación es pasada, no se programa.");
      return;
    }

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Tareas',
          channelDescription: 'Notificaciones de tareas de TaskFlow',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: enableVibration,
          vibrationPattern: enableVibration 
              ? Int64List.fromList([0, 500, 200, 500]) 
              : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // NOTA: En las versiones más nuevas, uiLocalNotificationDateInterpretation 
      // ha sido eliminado o ya no es un parámetro nombrado en este método.
    );
    debugPrint("🚀 Notificación programada con éxito para: $scheduledDate");
  }

  static Future<void> showInstantNotification() async {
    await _notifications.show(
      id: 999, 
      title: '¡Funciona!', 
      body: 'Si el móvil ha vibrado, todo está bien configurado.', 
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Pruebas',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
    );
  }
}