import 'package:equatable/equatable.dart';
import 'package:yanmar_app/extensions/psql_interval_formatter.dart';

class FulfillmentModel extends Equatable {
  final int id;
  final int opAssemblyId;
  final Duration estimatedDuration;

  const FulfillmentModel({required this.id, required this.opAssemblyId, required this.estimatedDuration});

  factory FulfillmentModel.fromSupabase(Map<String, dynamic> map) {
    return FulfillmentModel(
      id: map['id'],
      opAssemblyId: map['op_assembly_id'],
      estimatedDuration: (map['estimated_duration'] as String).parseInterval(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        opAssemblyId,
        estimatedDuration,
      ];
}
