import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/checklist_model.dart';
import 'package:yanmar_app/models/op_assembly_model.dart';

class RackModel extends Equatable {
  final int id;
  final String rackName;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? headerId;
  final List<OpAssemblyModel> opAssemblyModel;
  final List<ChecklistDetailModel> details;
  final List<ChecklistHeaderStatusModel> checklistHeader;

  const RackModel({
    required this.id,
    required this.rackName,
    required this.startTime,
    required this.endTime,
    required this.opAssemblyModel,
    required this.headerId,
    required this.details,
    required this.checklistHeader,
  });

  factory RackModel.fromSupabase(
      Map<String, dynamic> map, int? headerId, List<dynamic>? details, dynamic startTime, dynamic endTime, List<dynamic>? checklistHeader) {
    final List<OpAssemblyModel> opAssy = (map['master_op_assembly'] as List<dynamic>?)?.map((e) => OpAssemblyModel.fromSupabase(e)).toList() ?? [];

    return RackModel(
      id: map['id'],
      rackName: (map['rack_name'] as int).toString(),
      startTime: startTime != null ? DateTime.parse(startTime) : null,
      endTime: endTime != null ? DateTime.parse(endTime) : null,
      headerId: headerId,
      opAssemblyModel: opAssy,
      details: (details ?? []).map((e) => ChecklistDetailModel.fromSupabase(e)).toList(),
      checklistHeader: (checklistHeader ?? []).map((e) => ChecklistHeaderStatusModel.fromSupabase(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, rackName, startTime, endTime, opAssemblyModel, details];
}
