import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/models/delivery_model.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';
import 'package:yanmar_app/models/rack_model.dart';
import 'package:yanmar_app/models/set_checklist_model.dart';
import 'package:yanmar_app/models/upload_plan_produksi_model.dart';
import 'package:yanmar_app/models/user_model.dart';

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
            'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, estimated_production_duration, master_fulfillment(id, op_assembly_id, estimated_duration)) ,production_qty, order), item_requests(id, master_op_assembly(id, assembly_name, rack_placement), start_time, end_time), checklist_header(id, is_help_pressed)')
        .gte('start_time', startTime.toUtc().toIso8601String())
        .lt('end_time', endTime.toUtc().toIso8601String())
        .isFilter('deleted_at', null)
        .order('order', ascending: true, referencedTable: 'production_plan_detail')
        .order('start_time', ascending: true);

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

    // Start of the day
    final DateTime startOfDay = DateTime(currentTime.year, currentTime.month, currentTime.day, 0, 0, 0);

    // End of the day
    final DateTime endOfDay = DateTime(currentTime.year, currentTime.month, currentTime.day, 23, 59, 59, 999);

    for (int i = 0; i < result.length; i++) {
      final opAssIdList = (result[i]['master_op_assembly'] as List).map((e) => e['id']).toList();

      // Get header where:
      // - 1st header where start_time is greater than now
      // - start_time and end_time between startOfDay and endOfDay
      final planHeader = await _client
          .from('production_plan_header')
          .select(
              'id, start_time, end_time, production_plan_detail(id, master_production_type_header(id, type_name, master_production_type_detail(id, master_parts(id, op_assembly_id, part_code, part_name, locator), part_qty)) ,production_qty, order), checklist_header(id, checker_pic_id, is_help_pressed, all_check_done_time, checklist_detail(id, part_id, checked_done_time))')
          .gte('start_time', currentTime.toUtc().toIso8601String())
          .gte('start_time', startOfDay.toUtc().toIso8601String())
          .lte('end_time', endOfDay.toUtc().toIso8601String())
          .inFilter('production_plan_detail.master_production_type_header.master_production_type_detail.master_parts.op_assembly_id', opAssIdList)
          .isFilter('deleted_at', null)
          .order('order', ascending: true, referencedTable: 'production_plan_detail')
          .order('start_time', ascending: true)
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
        planHeader.isNotEmpty ? planHeader[0]['id'] : null,
        planHeader.isNotEmpty ? planHeader[0]['production_plan_detail'] : null,
        planHeader.isNotEmpty ? planHeader[0]['start_time'] : null,
        planHeader.isNotEmpty ? planHeader[0]['end_time'] : null,
        planHeader.isNotEmpty ? planHeader[0]['checklist_header'] : null,
      );
      rackModel.add(model);
    }

    return rackModel;
  }

  Future insertChecklist(int prodPlanHeaderId, int partId, int userId) async {
    final result = await _client.from('checklist_header').select('id').eq('production_plan_header_id', prodPlanHeaderId).limit(1);
    int id;

    if (result.isEmpty) {
      final header = SetChecklistHeaderModel(
        prodPlanHeaderId: prodPlanHeaderId,
        picId: userId,
        isHelpedPressed: false,
        allCheckDoneTime: null,
      );

      final headerId = await _client.from('checklist_header').insert(header.toJson()).select('id');

      id = headerId.first['id'];
    } else {
      id = result.first['id'];
    }

    final detail = SetChecklistDetailModel(headerId: id, partId: partId, checkedDoneTime: DateTime.now());

    await _client.from('checklist_detail').insert(detail.toJson());

    // Update all check done if all parts from plan header are checked
    final allDetail = await _client.from('checklist_header').select('id, checklist_detail(id, part_id)');

    final response = await _client
        .from('production_plan_header')
        .select('id, production_plan_detail(id, master_production_type_header(id, master_production_type_detail(id, part_id)))');

    final checklistParts = allDetail.expand((e) => e['checklist_detail']).map((f) => f['part_id']).toList();
    final responseParts = response
        .expand((e) => e['production_plan_detail'])
        .map((f) => f['master_production_type_header'])
        .expand((g) => g['master_production_type_detail'])
        .map((h) => h['part_id'])
        .toList();

    if (checklistParts.length == responseParts.length) {
      await _client.from('checklist_header').update({'all_check_done_time': DateTime.now().toIso8601String()}).eq('id', id);
    }
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

  /* ----------------------- UPLOAD PLAN PRODUKSI DAILY ----------------------- */
  Future<void> deletePlanProduksi({required List<int> id}) async {
    for (int i = 0; i < id.length; i++) {
      await _client.from('production_plan_detail').delete().eq('header_id', '${id[i]}');
      await _client.from('production_plan_header').delete().eq('id', '${id[i]}');
    }
  }

  Future<void> insertPlanProduksi(Map<String, dynamic> excelData, int createdBy) async {
    // Loop through all headers
    final headersList = excelData['time_slot'] as List<Map<String, dynamic>>;
    final detailsList = excelData['plan_slot'] as List<Map<String, dynamic>>;

    final headerIdList = [];

    for (int i = 0; i < headersList.length; i++) {
      final UploadPlanProduksiHeaderModel header = UploadPlanProduksiHeaderModel(
        startTime: headersList[i]['start_time'] as DateTime,
        endTime: headersList[i]['end_time'] as DateTime,
        createdBy: createdBy,
      );

      final headerId = await _client.from('production_plan_header').insert(header.toJson()).select('id');

      headerIdList.add(headerId.first['id']);
    }

    for (int i = 0; i < detailsList.length; i++) {
      for (int j = 0; j < (detailsList[i]['zone'] as List).length; j++) {
        if (detailsList[i]['zone'][j] > 0) {
          final prodTypeId = await _client.from('master_production_type_header').select('id').eq('type_name', detailsList[i]['model']).limit(1);

          if (prodTypeId.isEmpty) throw Exception("Production Type ${detailsList[i]['model']} not found");

          final order = await _client.from('production_plan_detail').select('id').eq('header_id', headerIdList[j]).count(CountOption.exact);

          final UploadPlanProduksiDetailModel detail = UploadPlanProduksiDetailModel(
            headerId: headerIdList[j],
            productionTypeId: prodTypeId.first['id'],
            productionQty: detailsList[i]['zone'][j],
            order: order.count + 1,
          );

          await _client.from('production_plan_detail').insert(detail.toJson());
        }
      }
    }
  }

  /* ------------------------------ UPLOAD MODEL ------------------------------ */
  Future<List<MasterProductionTypeModel>> getMasterProductionType({required int page, required int limit}) async {
    final result = await _client
        .from('master_production_type_header')
        .select('id, type_name, estimated_production_duration, created_at')
        .isFilter('deleted_at', null)
        .order('id', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    final List<MasterProductionTypeModel> models = result.map((e) => MasterProductionTypeModel.fromSupabase(e)).toList();

    return models;
  }

  Future<List<MasterProductionTypeDetailModel>> getMasterProductionTypeDetail({required int typeId}) async {
    final result = await _client
        .from('master_production_type_detail')
        .select('id, master_parts(id, part_name, part_code, master_op_assembly(id, assembly_name, rack_placement)), part_qty')
        .eq('header_id', typeId);

    final List<MasterProductionTypeDetailModel> details = result.map((e) => MasterProductionTypeDetailModel.fromSupabase(e)).toList();

    return details;
  }

  Future<void> deleteMasterProductionType({required int id}) async {
    await _client.from('master_production_type_header').update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
  }

  Future<void> insertMasterProductionType(Map<String, dynamic> excelData) async {}

  /* ---------------------------------- Users --------------------------------- */
  Future<UserModel> getLoggedUser({required String uuid}) async {
    final result =
        await _client.from('users').select('id, username, user_roles(id, role_name), uuid').isFilter('deleted_at', null).eq('uuid', uuid).limit(1);

    final userModel = result.map((e) => UserModel.fromSupabase(e)).toList().first;

    return userModel;
  }
}
