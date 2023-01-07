import 'package:dd_app_ui/data/services/database.dart';
import 'package:dd_app_ui/domain/enums/tab_item.dart';
import 'package:dd_app_ui/internal/utils.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dd_app_ui/firebase_options.dart';
import 'dart:convert';

void showModal(
  String title,
  String content,
  Map<String, dynamic> data,
) {
  var ctx = AppNavigator.key.currentContext;

  if (ctx != null) {
    showDialog(
      context: ctx,
      builder: (context) {
        var size = MediaQuery.of(context).size;

        return Dialog(
          alignment: Alignment.topCenter,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SizedBox(
            height: size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: title),
                  ),
                  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: content),
                  ),
                  SizedBox(
                      width: 320.0,
                      child: TextButton(
                          onPressed: () {
                            var decodedJson = json.decode(data.values.first);
                            var id = decodedJson["additionalProp1"];
                            var root = decodedJson["additionalProp2"];
                            Navigator.of(context).pop();
                            if (id != null && root != null) {
                              var rb = TabNavigator(
                                navigatorKey: AppNavigator.key,
                                tabItem: TabItemEnum.home,
                              ).routeBuilders(context, arg: id);
                              Navigator.of(AppNavigator.key.currentContext!)
                                  .push(MaterialPageRoute(
                                builder: (context) => rb[root]!(context),
                              ));
                            }
                          },
                          child: const Text("Go to event")))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void catchMessage(RemoteMessage message) {
  "Got a message whilst in the foreground!".console();
  'Message data: ${message.data}'.console();
  if (message.notification != null) {
    showModal(message.notification!.title!, message.notification!.body!,
        message.data);
  }
}

Future initApp() async {
  await initFareBase();
  await DB.instance.init();
}

Future initFareBase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true);
  FirebaseMessaging.onMessage.listen(catchMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(catchMessage);
  try {
    ((await messaging.getToken()) ?? "no token").console();
  } catch (e) {
    e.toString().console();
  }
}
