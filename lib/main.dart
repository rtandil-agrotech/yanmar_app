import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/observer.dart';
import 'package:yanmar_app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupAsync();

  usePathUrlStrategy();

  Bloc.observer = AppBlocObserver();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _auth = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _auth,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Gotham',
        ),
      ),
    );
  }
}
