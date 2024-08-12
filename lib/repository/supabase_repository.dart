import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/models/delivery_model.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/models/rack_model.dart';

class SupabaseRepository {
  SupabaseRepository(SupabaseClient client) : _client = client;

  final SupabaseClient _client;

  /* -------------------------------- ASSEMBLY -------------------------------- */
  Future<List<PlanProduksiModel>> getPlanProduksi({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final result = await _client
        .from('production_plan_header')
        .select(
            'id, start_time, end_time, users(id, username, user_roles(id, role_name)), production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration) ,production_qty, order, production_actual(id, recorded_time))')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lte('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
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

  /* -------------------------------- DELIVERY -------------------------------- */
  Future getDelivery({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final result = await _client
        .from('production_plan_header')
        .select(
            'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration, master_fulfillment(id, op_assembly_id, estimated_duration)) ,production_qty, order), item_requests(id, master_op_assembly(id, assembly_name), start_time, end_time), checklist_header(id, is_help_pressed)')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lte('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('order', ascending: true, referencedTable: 'production_plan_detail');

    print(result);

    final List<DeliveryPlanModel> deliveryPlanModel = result.map((e) => DeliveryPlanModel.fromSupabase(e)).toList();

    return deliveryPlanModel;
  }

  RealtimeChannel subscribeToItemRequestChanges(void Function(PostgresChangePayload) callback) {
    final subs = _client
        .channel('item-requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'item_requests',
          callback: callback,
        )
        .subscribe();

    return subs;
  }

  RealtimeChannel subscribeToChecklistChanges(void Function(PostgresChangePayload) callback) {
    final subs = _client
        .channel('checklist_header')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'checklist_header',
          callback: callback,
        )
        .subscribe();

    return subs;
  }

  /* -------------------------------- CHECKLIST ------------------------------- */
  Future<List<RackModel>> getRackList() async {
    final result = await _client.from('master_rack').select('id, rack_name, master_op_assembly(id, assembly_name)').isFilter('deleted_at', null);

    final List<RackModel> rackModel = result.map((e) => RackModel.fromSupabase(e)).toList();

    return rackModel;
  }

  Future getPartListForOpAssembly({required int opAssemblyId, required DateTime startTime, required DateTime endTime}) async {
    // Things to get:
    // - Based on plan header id on time
    // - Get plan detail to know type & qty
    // - Get part per type
    // - Filter part by op assembly
    final planHeader = await _client
        .from('production_plan_header')
        .select(
            'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration) ,production_qty, order)')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lte('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null);
  }
}
