import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_HOST')
  static String supabaseHost = _Env.supabaseHost;
  @EnviedField(varName: 'ANON_KEY')
  static String anonKey = _Env.anonKey;
}
