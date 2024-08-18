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
            'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration) ,production_qty, order, production_actual(id, recorded_time))')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lt('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('order', ascending: true, referencedTable: 'production_plan_detail')
        .order('start_time', ascending: true);

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
        .lt('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('order', ascending: true, referencedTable: 'production_plan_detail');

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
  Future<List<RackModel>> getRackList({required DateTime currentTime}) async {
    final result = await _client
        .from('master_rack')
        .select('id, rack_name, master_op_assembly(id, assembly_name, rack_placement)')
        .isFilter('deleted_at', null)
        .order('rack_name', ascending: true)
        .order('rack_placement', referencedTable: 'master_op_assembly', ascending: true);

    final List<RackModel> rackModel = [];

    // Move time by 1 hour
    final time = currentTime.subtract(const Duration(hours: 1));

    for (int i = 0; i < result.length; i++) {
      final opAssIdList = (result[i]['master_op_assembly'] as List).map((e) => e['id']).toList();

      final planHeader = await _client
          .from('production_plan_header')
          .select(
              'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, master_production_type_detail(id, master_parts(id, op_assembly_id, part_code, part_name), part_qty)) ,production_qty, order)')
          .gte('end_time', time.toUtc().toIso8601String())
          .lte('start_time', time.toUtc().toIso8601String())
          .inFilter('production_plan_detail.master_production_type_header.master_production_type_detail.master_parts.op_assembly_id', opAssIdList)
          .isFilter('deleted_at', null)
          .order('order', ascending: true, referencedTable: 'production_plan_detail')
          .limit(1);

      // Remove all parts where op assembly id is not opAssemblyId from planHeaderList
      if (planHeader.isNotEmpty) {
        for (var details in planHeader[0]['production_plan_detail']) {
          (details['master_production_type_header']['master_production_type_detail'] as List)
              .removeWhere((element) => element['master_parts'] == null);
        }
      }

      RackModel model = RackModel.fromSupabase(
        result[i],
        planHeader.isNotEmpty ? planHeader[0]['production_plan_detail'] : null,
        planHeader.isNotEmpty ? planHeader[0]['start_time'] : null,
        planHeader.isNotEmpty ? planHeader[0]['end_time'] : null,
      );
      rackModel.add(model);
    }

    return rackModel;
  }

  /* -------------------------- Monthly Plan Produksi ------------------------- */
  Future<List<MonthlyPlanProduksiModel>> getMonthlyPlanProduksi({required DateTime startTime, required DateTime endTime}) async {
    final result = await _client
        .from('monthly_production_plan_header')
        .select('id, start_time, end_time, monthly_production_plan_detail(id, master_production_type_header(id, type_name), production_qty, order)')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lte('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('order', ascending: true, referencedTable: 'monthly_production_plan_detail')
        .order('start_time', ascending: true);

    final actuals = await _client
        .from('production_actual')
        .select('id, production_plan_detail(id, master_production_type_header(id, type_name)), recorded_time')
        .gte('recorded_time', startTime.toUtc().toIso8601String())
        .lte('recorded_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('recorded_time', ascending: true);

    // print(actuals);

    final List<MonthlyPlanProduksiModel> monthlyPlanProduksiModel = result.map((e) => MonthlyPlanProduksiModel.fromSupabase(e, actuals)).toList();

    return monthlyPlanProduksiModel;
  }
}
