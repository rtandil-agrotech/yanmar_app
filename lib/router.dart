import 'package:go_router/go_router.dart';
import 'package:yanmar_app/pages/assembly.dart';
import 'package:yanmar_app/pages/delivery.dart';
import 'package:yanmar_app/pages/home.dart';

final router = GoRouter(
  initialLocation: DeliveryPage.route,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: DeliveryPage.route, builder: (context, state) => const DeliveryPage()),
    GoRoute(path: AssemblyPage.route, builder: (context, state) => const AssemblyPage())
  ],
);
