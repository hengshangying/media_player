import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'api/media_api_client.dart';
import 'screens/home_shell.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final isDesktop = !kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  if (isDesktop) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1360, 820),
      minimumSize: Size(980, 640),
      center: true,
      backgroundColor: AppColors.bg,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: '影音播放器',
      windowButtonVisibility: false,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setTitle('影音播放器');
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final settings = SettingsService();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ProxyProvider<SettingsService, MediaApiClient>(
          update: (_, s, prev) {
            prev?.dispose();
            return MediaApiClient(s);
          },
          dispose: (_, client) => client.dispose(),
        ),
      ],
      child: const MediaPlayerApp(),
    ),
  );
}

class MediaPlayerApp extends StatelessWidget {
  const MediaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '影音播放器',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeShell(),
    );
  }
}
