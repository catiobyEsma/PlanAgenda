import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';
import 'notifications.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('de_DE', null);
  await initializeDateFormatting('it_IT', null);
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  runApp(const PlanAgendaApp());
}

class PlanAgendaApp extends StatefulWidget {
  const PlanAgendaApp({super.key});

  @override
  State<PlanAgendaApp> createState() => _PlanAgendaAppState();
}

class _PlanAgendaAppState extends State<PlanAgendaApp> {
  final AppData _appData = AppData();

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    try {
      await _appData.load();
    } finally {
      if (mounted) {
        FlutterNativeSplash.remove();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>.value(
      value: _appData,
      child: AnimatedBuilder(

        animation: _appData,
        builder: (context, _) {
          return MaterialApp(
            title: 'PlanAgenda',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(_appData.themeOption),
            home: _appData.isLoaded ? const HomeScreen() : const SplashScreen(),
          );
        },
      ),
    );
  }
}