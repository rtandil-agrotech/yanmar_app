import 'package:go_router/go_router.dart';
import 'package:yanmar_app/pages/assembly.dart';
import 'package:yanmar_app/pages/home.dart';
import 'package:yanmar_app/pages/login.dart';

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const HomePage()),
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/assembly', builder: (context, state) => const AssemblyPage())
]);
