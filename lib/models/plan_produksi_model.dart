import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/production_actual_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';

class PlanProduksiModel extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<PlanProduksiDetailModel> details;

  const PlanProduksiModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.details,
  });

  factory PlanProduksiModel.fromSupabase(Map<String, dynamic> json) {
    return PlanProduksiModel(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      details: (json['production_plan_detail'] as List<dynamic>?)?.map((e) => PlanProduksiDetailModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, details];
}

class PlanProduksiDetailModel extends Equatable {
  final int id;
  final ProductionTypeModel type;
  final int qty;
  final int order;
  final List<ProductionActualModel> actuals;

  const PlanProduksiDetailModel({
    required this.id,
    required this.type,
    required this.qty,
    required this.order,
    required this.actuals,
  });

  factory PlanProduksiDetailModel.fromSupabase(Map<String, dynamic> json) {
    return PlanProduksiDetailModel(
      id: json['id'],
      type: ProductionTypeModel.fromSupabase(json['master_production_type_header']),
      qty: json['production_qty'],
      order: json['order'],
      actuals: (json['production_actual'] as List<dynamic>?)?.map((e) => ProductionActualModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, type, qty, order, actuals];
}

class MonthlyPlanProduksiModel extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<MonthlyPlanProduksiDetailModel> details;

  const MonthlyPlanProduksiModel({required this.id, required this.startTime, required this.endTime, required this.details});

  factory MonthlyPlanProduksiModel.fromSupabase(Map<String, dynamic> json, List<Map<String, dynamic>> actuals) {
    return MonthlyPlanProduksiModel(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      details:
          (json['monthly_production_plan_detail'] as List<dynamic>?)?.map((e) => MonthlyPlanProduksiDetailModel.fromSupabase(e, actuals)).toList() ??
              [],
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, details];
}

class MonthlyPlanProduksiDetailModel extends Equatable {
  final int id;
  final ProductionTypeModel type;
  final int qty;
  final int order;
  final List<ProductionActualModel> actuals;

  const MonthlyPlanProduksiDetailModel({required this.id, required this.type, required this.qty, required this.order, required this.actuals});

  factory MonthlyPlanProduksiDetailModel.fromSupabase(Map<String, dynamic> json, List<Map<String, dynamic>> actuals) {
    return MonthlyPlanProduksiDetailModel(
      id: json['id'],
      type: ProductionTypeModel.fromSupabase(json['master_production_type_header']),
      qty: json['production_qty'],
      order: json['order'],
      actuals: actuals
          .where((e) => e['production_plan_detail']['master_production_type_header']['id'] == json['master_production_type_header']['id'])
          .map((f) => ProductionActualModel.fromSupabase(f))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, type, qty, order, actuals];
}
