import 'package:equatable/equatable.dart';

class OpAssemblyModel extends Equatable {
  final int id;
  final String name;
  final String rackPlacement;

  const OpAssemblyModel({required this.id, required this.name, required this.rackPlacement});

  factory OpAssemblyModel.fromSupabase(Map<String, dynamic> map) {
    return OpAssemblyModel(
      id: map['id'],
      name: map['assembly_name'],
      rackPlacement: map['rack_placement'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}
