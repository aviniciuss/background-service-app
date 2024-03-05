import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationId = 1000;
const channelId = 'my_notification_channel';
const channelName = 'Background Service APP';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
  channelId,
  channelName,
  description: 'This is channel of notification...',
  importance: Importance.high,
  enableVibration: true,
  enableLights: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initService();

  runApp(const MyApp());
}

Future<void> initService() async {
  var service = FlutterBackgroundService();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
      notificationChannelId: channelId,
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  service.on('setAsForeground').listen((event) {});

  service.on('setAsBackground').listen((event) {});

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Cool Service',
      'Awsome ${DateTime.now()}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          ongoing: true,
          icon: 'ic_bg_service_small',
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Background Service',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Service'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke('stopService');
                },
                child: const Text('stop service'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().startService();
                },
                child: const Text('start service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
