import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/op_assembly_model.dart';

class ItemRequestsModel extends Equatable {
  final int id;
  final OpAssemblyModel opAssembly;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isHelpPressed;

  const ItemRequestsModel({required this.id, required this.opAssembly, required this.startTime, required this.endTime, required this.isHelpPressed});

  factory ItemRequestsModel.fromSupabase(Map<String, dynamic> map) {
    return ItemRequestsModel(
      id: map['id'],
      startTime: map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      opAssembly: OpAssemblyModel.fromSupabase(map['master_op_assembly']),
      isHelpPressed: map['is_help_pressed'],
    );
  }

  @override
  List<Object?> get props => [id, opAssembly, startTime, endTime];
}
