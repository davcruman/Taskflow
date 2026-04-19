import 'dart:typed_data'; 
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

    await _notifications.initialize(
      settings: initSettings, 
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool enableVibration = true,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tareas',
          channelDescription: 'Notificaciones de tareas pendientes',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: enableVibration,
          // SOLUCIÓN AL ERROR DE Int64List:
          vibrationPattern: enableVibration 
              ? Int64List.fromList([0, 500, 200, 500]) 
              : null,
        ),
      ),
      // SOLUCIÓN AL ERROR DE uiLocalNotificationDateInterpretation:
      // En la v20 se usa esta propiedad:
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> showInstantNotification() async {
    // SOLUCIÓN A LOS POSITIONAL ARGUMENTS: 
    // En la v20, todos los argumentos de .show deben ser NOMBRADOS
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