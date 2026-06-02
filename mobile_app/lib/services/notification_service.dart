import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final plugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    await plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
  }
  Future<void> show(String title, String body) => plugin.show(0, title, body, const NotificationDetails(android: AndroidNotificationDetails('padel_finder', 'PadelFinder')));
}
