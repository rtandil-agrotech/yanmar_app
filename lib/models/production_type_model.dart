import 'package:equatable/equatable.dart';
import 'package:yanmar_app/extensions/psql_interval_formatter.dart';

class ProductionTypeModel extends Equatable {
  final int id;
  final String typeName;
  final Duration estimatedProductionTime;

  const ProductionTypeModel({required this.id, required this.typeName, this.estimatedProductionTime = Duration.zero});

  factory ProductionTypeModel.fromSupabase(Map<String, dynamic> map) {
    return ProductionTypeModel(
      id: map['id'] as int,
      typeName: map['type_name'] as String,
      estimatedProductionTime: (map['estimated_production_duration'] as String).parseInterval(),
    );
  }

  @override
  List<Object?> get props => [id, typeName, estimatedProductionTime];
}
