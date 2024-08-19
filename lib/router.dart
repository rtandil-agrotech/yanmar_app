import 'package:go_router/go_router.dart';
import 'package:yanmar_app/pages/assembly.dart';
import 'package:yanmar_app/pages/checklist.dart';
import 'package:yanmar_app/pages/delivery.dart';
import 'package:yanmar_app/pages/home.dart';

final router = GoRouter(
  // initialLocation: ChecklistPage.route,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
        path: ChecklistPage.route,
        routes: [
          GoRoute(path: ':id', builder: (context, state) => ChecklistPage(initialPage: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0)),
        ],
        builder: (context, state) => const ChecklistPage(initialPage: 1)),
    GoRoute(path: DeliveryPage.route, builder: (context, state) => const DeliveryPage()),
    GoRoute(path: AssemblyPage.route, builder: (context, state) => const AssemblyPage())
  ],
);
