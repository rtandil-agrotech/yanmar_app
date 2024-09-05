import 'package:equatable/equatable.dart';

class UploadPlanProduksiHeaderModel extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final int createdBy;

  const UploadPlanProduksiHeaderModel({required this.startTime, required this.endTime, required this.createdBy});

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        createdBy,
      ];
}

class UploadPlanProduksiDetailModel extends Equatable {
  final int headerId;
  final int productionTypeId;
  final int productionQty;
  final int order;

  const UploadPlanProduksiDetailModel({required this.headerId, required this.productionTypeId, required this.productionQty, required this.order});

  Map<String, dynamic> toJson() {
    return {
      'header_id': headerId,
      'production_type_id': productionTypeId,
      'production_qty': productionQty,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
        headerId,
        productionTypeId,
        productionQty,
        order,
      ];
}
