import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/production_actual_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';
import 'package:yanmar_app/models/users_model.dart';

class PlanProduksiModel extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final UserModel createdBy;
  final List<PlanProduksiDetailModel> details;

  const PlanProduksiModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.details,
  });

  factory PlanProduksiModel.fromSupabase(Map<String, dynamic> json) {
    return PlanProduksiModel(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      createdBy: UserModel.fromSupabase(json['users']),
      details: (json['production_plan_detail'] as List<dynamic>?)?.map((e) => PlanProduksiDetailModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, createdBy, details];
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
