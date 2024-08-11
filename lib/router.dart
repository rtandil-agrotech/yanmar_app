import 'package:go_router/go_router.dart';
import 'package:yanmar_app/pages/assembly.dart';
import 'package:yanmar_app/pages/home.dart';
import 'package:yanmar_app/pages/login.dart';

final router = GoRouter(
  initialLocation: AssemblyPage.route,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: AssemblyPage.route, builder: (context, state) => const AssemblyPage())
  ],
);
