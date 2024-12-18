import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/env/env.dart';
import 'package:yanmar_app/repository/auth_repository.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

final locator = GetIt.instance;

Future<void> setupAsync() async {
  final client = await _initSupabase();
  final version = await _getAppVersion();

  locator.registerSingleton<String>(version, instanceName: 'appVersion');

  locator.registerLazySingleton(() => SupabaseRepository(client));
  locator.registerLazySingleton(() => AuthRepository(client));
}

Future<SupabaseClient> _initSupabase() async {
  final supabaseClient = await Supabase.initialize(url: Env.supabaseHost, anonKey: Env.anonKey);

  return supabaseClient.client;
}

Future<String> _getAppVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return packageInfo.version;
}
