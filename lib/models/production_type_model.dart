import 'package:equatable/equatable.dart';
import 'package:yanmar_app/extensions/psql_interval_formatter.dart';
import 'package:yanmar_app/models/fulfillment_model.dart';

class ProductionTypeModel extends Equatable {
  final int id;
  final String typeName;
  final Duration? estimatedProductionTime;
  final List<FulfillmentModel>? fulfillment;

  const ProductionTypeModel({required this.id, required this.typeName, this.estimatedProductionTime = Duration.zero, this.fulfillment});

  factory ProductionTypeModel.fromSupabase(Map<String, dynamic> map) {
    return ProductionTypeModel(
      id: map['id'] as int,
      typeName: map['type_name'] as String,
      estimatedProductionTime: (map['estimated_production_duration'] as String?)?.parseInterval(),
      fulfillment: (map['master_fulfillment'] as List<dynamic>?)?.map((e) => FulfillmentModel.fromSupabase(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, typeName, estimatedProductionTime, fulfillment];
}
