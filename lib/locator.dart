import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/env/env.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

final locator = GetIt.instance;

Future<void> setupAsync() async {
  final client = await _initSupabase();

  locator.registerLazySingleton(() => SupabaseRepository(client));
}

Future<SupabaseClient> _initSupabase() async {
  final supabaseClient = await Supabase.initialize(url: Env.supabaseHost, anonKey: Env.anonKey);

  return supabaseClient.client;
}
