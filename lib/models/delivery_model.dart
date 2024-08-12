import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/item_requests_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';

class DeliveryPlanModel extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<DeliveryPlanDetailModel> details;
  final List<ItemRequestsModel> itemRequests;

  const DeliveryPlanModel({required this.id, required this.startTime, required this.endTime, required this.details, required this.itemRequests});

  factory DeliveryPlanModel.fromSupabase(Map<String, dynamic> map) {
    return DeliveryPlanModel(
      id: map['id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      details: (map['production_plan_detail'] as List<dynamic>?)?.map((e) => DeliveryPlanDetailModel.fromSupabase(e)).toList() ?? [],
      itemRequests: (map['item_requests'] as List<dynamic>?)?.map((e) => ItemRequestsModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        details,
        itemRequests,
      ];
}

class DeliveryPlanDetailModel extends Equatable {
  final int id;
  final ProductionTypeModel type;
  final int qty;
  final int order;

  const DeliveryPlanDetailModel({required this.id, required this.type, required this.qty, required this.order});

  factory DeliveryPlanDetailModel.fromSupabase(Map<String, dynamic> map) {
    return DeliveryPlanDetailModel(
      id: map['id'],
      type: ProductionTypeModel.fromSupabase(map['master_production_type_header']),
      qty: map['production_qty'],
      order: map['order'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        qty,
        order,
      ];
}
