import 'package:equatable/equatable.dart';

class OpAssemblyModel extends Equatable {
  final int id;
  final String name;

  const OpAssemblyModel({required this.id, required this.name});

  factory OpAssemblyModel.fromSupabase(Map<String, dynamic> map) {
    return OpAssemblyModel(id: map['id'], name: map['assembly_name']);
  }

  @override
  List<Object?> get props => [id, name];
}
