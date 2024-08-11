import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';

class SupabaseRepository {
  SupabaseRepository(SupabaseClient client) : _client = client;

  final SupabaseClient _client;

  Future<List<PlanProduksiModel>> getPlanProduksi() async {
    final result = await _client
        .from('production_plan_header')
        .select(
            'id, start_time, end_time, users(id, username, user_roles(id, role_name)), production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration) ,production_qty, order, production_actual(id, recorded_time))')
        .order('order', ascending: true, referencedTable: 'production_plan_detail');

    final List<PlanProduksiModel> planProduksiModel = result.map((e) => PlanProduksiModel.fromSupabase(e)).toList();

    return planProduksiModel;
  }

  RealtimeChannel subscribeToProductionActualChanges(void Function(PostgresChangePayload) callback) {
    final subs = _client
        .channel('prod-actual')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'production_actual',
          callback: callback,
        )
        .subscribe();

    return subs;
  }

  Future<void> unsubscribe(RealtimeChannel subs) async {
    await subs.unsubscribe();
  }
}
