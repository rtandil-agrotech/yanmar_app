import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'DB_HOST')
  static String dbHost = _Env.dbHost;
  @EnviedField(varName: 'DB_USER')
  static String dbUser = _Env.dbUser;
  @EnviedField(varName: 'DB_PASSWORD')
  static String dbPassword = _Env.dbPassword;
  @EnviedField(varName: 'DB_NAME')
  static String dbName = _Env.dbName;
}
