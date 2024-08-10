import 'package:postgres/postgres.dart';

class DBRepository {
  DBRepository(Connection conn) : _conn = conn;

  final Connection _conn;

  Future getPlanProduksi() async {
    const query = 'select * from master_production_type_header';

    if (!_conn.isOpen) throw Exception('Connection not open');

    final result = await _conn.execute(query);
  }
}
