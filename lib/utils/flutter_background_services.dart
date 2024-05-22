import 'dart:async';
import 'dart:ui';

import 'package:background_location/background_location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shake/shake.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:empower_her/db/db_services.dart';
import 'package:empower_her/model/contactsm.dart';

sendMessage(String messageBody) async {
  List<TContact> contactList = await DatabaseHelper().getContactList();
  if (contactList.isEmpty) {
    Fluttertoast.showToast(msg: "No number exists, please add a number");
  } else {
    for (var i = 0; i < contactList.length; i++) {
      Telephony.backgroundInstance
          .sendSms(to: contactList[i].number, message: messageBody)
          .then((value) {
        Fluttertoast.showToast(msg: "Message sent");
      }).catchError((error) {
        print("Failed to send message: $error");
        Fluttertoast.showToast(msg: "Failed to send message: $error");
      });
    }
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    "script_academy",
    "Foreground Service",
    "Used for important notifications",
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: "script_academy",
        initialNotificationTitle: "Foreground Service",
        initialNotificationContent: "Initializing",
        foregroundServiceNotificationId: 888,
      ));
  service.startService();
}

@pragma('vm-entry-point')
void onStart(ServiceInstance service) async {
  Location? clocation;

  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      print("Service set as foreground");
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      print("Service set as background");
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
    print("Service stopped");
  });

  await BackgroundLocation.setAndroidNotification(
    title: "Location tracking is running in the background!",
    message: "You can turn it off from settings menu inside the app",
    icon: '@mipmap/ic_logo',
  );
  BackgroundLocation.startLocationService(
    distanceFilter: 20,
  );

  BackgroundLocation.getLocationUpdates((location) {
    clocation = location;
    print("Location updated: ${location.latitude}, ${location.longitude}");
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      ShakeDetector.autoStart(
          shakeThresholdGravity: 7,
          shakeSlopTimeMS: 500,
          shakeCountResetTime: 3000,
          minimumShakeCount: 1,
          onPhoneShake: () async {
            print("Shake detected");
            if (await Vibration.hasVibrator() ?? false) {
              print("Vibration supported");
              if (await Vibration.hasCustomVibrationsSupport() ?? false) {
                print("Custom vibration supported");
                Vibration.vibrate(duration: 1000);
              } else {
                print("Default vibration");
                Vibration.vibrate();
                await Future.delayed(Duration(milliseconds: 500));
                Vibration.vibrate();
              }
            } else {
              print("No vibration support");
            }

            if (clocation != null) {
              String messageBody =
                  "https://www.google.com/maps/search/?api=1&query=${clocation!.latitude}%2C${clocation!.longitude}";
              sendMessage(messageBody);
            } else {
              print("Location is null");
              Fluttertoast.showToast(msg: "Location is null");
            }
          });

      flutterLocalNotificationsPlugin.show(
        888,
        "Women Safety App",
        clocation == null
            ? "Please enable location to use app"
            : "Shake feature enabled ${clocation!.latitude}",
        NotificationDetails(
            android: AndroidNotificationDetails(
          "script_academy",
          "Foreground Service",
          "Used for important notifications",
          icon: 'ic_bg_service_small',
          ongoing: true,
        )),
      );
    }
  }
}
