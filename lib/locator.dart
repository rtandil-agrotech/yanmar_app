import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';
import 'package:yanmar_app/env/env.dart';
import 'package:yanmar_app/repository/db_repository.dart';

final locator = GetIt.instance;

Future<void> setupAsync() async {
  final conn = await _setupDBConn();

  locator.registerLazySingleton<DBRepository>(() => DBRepository(conn));
}

Future<Connection> _setupDBConn() async {
  final conn = await Connection.open(Endpoint(
    host: Env.dbHost,
    database: Env.dbName,
    username: Env.dbName,
    password: Env.dbPassword,
  ));

  if (!conn.isOpen) throw Exception('Connection not open');

  return conn;
}
