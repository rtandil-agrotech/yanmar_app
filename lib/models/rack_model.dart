import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/checklist_model.dart';
import 'package:yanmar_app/models/op_assembly_model.dart';

class RackModel extends Equatable {
  final int id;
  final String rackName;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<OpAssemblyModel> opAssemblyModel;
  final List<ChecklistDetailModel> details;

  const RackModel({
    required this.id,
    required this.rackName,
    required this.startTime,
    required this.endTime,
    required this.opAssemblyModel,
    required this.details,
  });

  factory RackModel.fromSupabase(Map<String, dynamic> map, List<dynamic>? details, dynamic startTime, dynamic endTime) {
    final List<OpAssemblyModel> opAssy = (map['master_op_assembly'] as List<dynamic>?)?.map((e) => OpAssemblyModel.fromSupabase(e)).toList() ?? [];

    return RackModel(
      id: map['id'],
      rackName: (map['rack_name'] as int).toString(),
      startTime: startTime != null ? DateTime.parse(startTime) : null,
      endTime: endTime != null ? DateTime.parse(endTime) : null,
      opAssemblyModel: opAssy,
      details: (details ?? []).map((e) => ChecklistDetailModel.fromSupabase(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, rackName, startTime, endTime, opAssemblyModel, details];
}
