import 'package:equatable/equatable.dart';

class ChecklistModel extends Equatable {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<ChecklistDetailModel> details;

  const ChecklistModel({required this.id, required this.startTime, required this.endTime, required this.details});

  factory ChecklistModel.fromSupabase(Map<String, dynamic> map) {
    return ChecklistModel(
      id: map['id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      details: (map['production_plan_detail'] as List?)?.map((e) => ChecklistDetailModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        details,
      ];
}

class ChecklistDetailModel extends Equatable {
  final int id;
  final int order;
  final int productionQty;
  final ChecklistMasterProductionType masterProductionType;

  const ChecklistDetailModel({required this.id, required this.order, required this.productionQty, required this.masterProductionType});

  factory ChecklistDetailModel.fromSupabase(Map<String, dynamic> map) {
    return ChecklistDetailModel(
      id: map['id'],
      order: map['order'],
      productionQty: map['production_qty'],
      masterProductionType: ChecklistMasterProductionType.fromSupabase(map['master_production_type_header']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        order,
        productionQty,
        masterProductionType,
      ];
}

class ChecklistMasterProductionType extends Equatable {
  final int id;
  final String typeName;
  final List<ChecklistMasterProductionTypeDetail> details;

  const ChecklistMasterProductionType({
    required this.id,
    required this.typeName,
    required this.details,
  });

  factory ChecklistMasterProductionType.fromSupabase(Map<String, dynamic> map) {
    return ChecklistMasterProductionType(
      id: map['id'],
      typeName: map['type_name'],
      details: (map['master_production_type_detail'] as List?)?.map((e) => ChecklistMasterProductionTypeDetail.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        typeName,
        details,
      ];
}

class ChecklistMasterProductionTypeDetail extends Equatable {
  final int id;
  final ChecklistParts parts;
  final int qty;

  const ChecklistMasterProductionTypeDetail({required this.id, required this.parts, required this.qty});

  factory ChecklistMasterProductionTypeDetail.fromSupabase(Map<String, dynamic> map) {
    return ChecklistMasterProductionTypeDetail(
      id: map['id'],
      parts: ChecklistParts.fromSupabase(map['master_parts']),
      qty: map['part_qty'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        parts,
        qty,
      ];
}

class ChecklistParts extends Equatable {
  final int id;
  final int opAssemblyId;
  final String partCode;
  final String partName;
  final String locator;

  const ChecklistParts({required this.id, required this.opAssemblyId, required this.partCode, required this.partName, required this.locator});

  factory ChecklistParts.fromSupabase(Map<String, dynamic> map) {
    return ChecklistParts(
      id: map['id'],
      opAssemblyId: map['op_assembly_id'],
      partCode: map['part_code'],
      partName: map['part_name'],
      locator: map['locator'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        opAssemblyId,
        partCode,
        partName,
        locator,
      ];
}

class ChecklistHeaderStatusModel extends Equatable {
  final int id;
  final int picId;
  final bool isHelpPressed;
  final DateTime? allCheckDoneTime;
  final List<ChecklistDetailStatusModel> details;

  const ChecklistHeaderStatusModel({
    required this.id,
    required this.picId,
    required this.isHelpPressed,
    required this.allCheckDoneTime,
    required this.details,
  });

  factory ChecklistHeaderStatusModel.fromSupabase(Map<String, dynamic> json) {
    return ChecklistHeaderStatusModel(
      id: json['id'],
      picId: json['checker_pic_id'],
      isHelpPressed: json['is_help_pressed'],
      allCheckDoneTime: json['all_check_done_time'] != null ? DateTime.parse(json['all_check_done_time']) : null,
      details: (json['checklist_detail'] as List?)?.map((e) => ChecklistDetailStatusModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, picId, isHelpPressed, allCheckDoneTime, details];
}

class ChecklistDetailStatusModel extends Equatable {
  final int id;
  final int partId;
  final DateTime? checkedDoneTime;

  const ChecklistDetailStatusModel({
    required this.id,
    required this.partId,
    required this.checkedDoneTime,
  });

  factory ChecklistDetailStatusModel.fromSupabase(Map<String, dynamic> json) {
    return ChecklistDetailStatusModel(
      id: json['id'],
      partId: json['part_id'],
      checkedDoneTime: json['checked_done_time'] != null ? DateTime.parse(json['checked_done_time']) : null,
    );
  }

  @override
  List<Object?> get props => [id, partId, checkedDoneTime];
}
