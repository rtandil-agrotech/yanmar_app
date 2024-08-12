import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/op_assembly_model.dart';

class RackModel extends Equatable {
  final int id;
  final String rackName;
  final List<OpAssemblyModel> opAssemblyModel;

  const RackModel({
    required this.id,
    required this.rackName,
    required this.opAssemblyModel,
  });

  factory RackModel.fromSupabase(Map<String, dynamic> map) {
    return RackModel(
      id: map['id'],
      rackName: (map['rack_name'] as int).toString(),
      opAssemblyModel: (map['master_op_assembly'] as List<dynamic>?)?.map((e) => OpAssemblyModel.fromSupabase(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, rackName];
}
