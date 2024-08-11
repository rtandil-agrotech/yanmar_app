import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/observer.dart';
import 'package:yanmar_app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupAsync();

  usePathUrlStrategy();

  Bloc.observer = AppBlocObserver();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}
