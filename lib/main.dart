import 'package:flutter/material.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/router.dart';

Future<void> main() async {
  await setupAsync();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
