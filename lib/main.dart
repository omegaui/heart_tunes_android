import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';

import '../screens/home_screen.dart';
import '../io/app_data_manager.dart';
import 'io/track_data.dart';
import 'io/track_manager.dart';

final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey();

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.grey.shade900));
    return MaterialApp(
      color: Colors.grey.shade900,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: const ContentPane(),
      ),
    );
  }
}

class ContentPane extends StatefulWidget {
  const ContentPane({Key? key}) : super(key: key);

  @override
  State<ContentPane> createState() => _ContentPaneState();
}

class _ContentPaneState extends State<ContentPane> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initAppStore();
      if (isFirstStartup()) {
        registerFirstStartup();
      }
      trackListPanelKey.currentState?.rebuild();

      dynamic autoplayOnProperty = appSettingsStore.get('autoplay');
      if (autoplayOnProperty != null) {
        if (autoplayOnProperty as bool) {
          dynamic trackData = appSettingsStore.get('last-active-track');
          if (trackData != null) {
            String path = trackData['path'];
            Track? track = getTrack(path);
            if (track != null) {
              Timer(const Duration(seconds: 1), () {
                putToView(track);
                track.trackPlayerService.play();
              });
            }
          }
        }
        homeScreenKey.currentState?.rebuild();
      }

      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Heart Tunes",
        notificationText: "I'm always there to put a smile on your face :)",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
      if(success) {
        await FlutterBackground.enableBackgroundExecution();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey.shade900,
      child: HomeScreen(key: homeScreenKey),
    );
  }
}
