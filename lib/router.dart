import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/pages/assembly/assembly.dart';
import 'package:yanmar_app/pages/checklist/checklist.dart';
import 'package:yanmar_app/pages/delivery/delivery.dart';
import 'package:yanmar_app/pages/home.dart';
import 'package:yanmar_app/pages/login/login.dart';
import 'package:yanmar_app/pages/upload_daily_plan/upload_daily_plan.dart';
import 'package:yanmar_app/pages/upload_model/upload_model.dart';
import 'package:yanmar_app/pages/upload_model_detail/upload_model_detail.dart';

final router = GoRouter(
  // initialLocation: ChecklistPage.route,
  routes: [
    GoRoute(path: HomePage.route, builder: (context, state) => const HomePage()),
    GoRoute(
      path: LoginPage.route,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
        path: ChecklistPage.route,
        routes: [
          GoRoute(path: ':id', builder: (context, state) => ChecklistPage(initialPage: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0)),
        ],
        builder: (context, state) => const ChecklistPage(initialPage: 1)),
    GoRoute(path: DeliveryPage.route, builder: (context, state) => const DeliveryPage()),
    GoRoute(path: AssemblyPage.route, builder: (context, state) => const AssemblyPage()),
    GoRoute(
        path: UploadDailyPlanPage.route,
        builder: (context, state) => const UploadDailyPlanPage(),
        redirect: (context, state) {
          final userState = context.read<AuthBloc>().state;
          if (userState is UnauthenticatedState) return HomePage.route;
          if (userState is AuthenticatedState && !UploadDailyPlanPage.allowedUserRoles.contains(userState.user.role.name)) return HomePage.route;
          return null;
        }),
    GoRoute(
        path: UploadModelPage.route,
        routes: [
          GoRoute(path: ':id', builder: (context, state) => UploadModelDetailPage(id: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0)),
        ],
        builder: (context, state) => const UploadModelPage(),
        redirect: (context, state) {
          final userState = context.read<AuthBloc>().state;
          if (userState is UnauthenticatedState) return HomePage.route;
          if (userState is AuthenticatedState && !UploadModelPage.allowedUserRoles.contains(userState.user.role.name)) return HomePage.route;
          return null;
        })
  ],
);
