import 'package:equatable/equatable.dart';
import 'package:yanmar_app/extensions/psql_interval_formatter.dart';
import 'package:yanmar_app/models/fulfillment_model.dart';
import 'package:yanmar_app/models/op_assembly_model.dart';

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

class MasterProductionTypeModel extends Equatable {
  final int id;
  final String typeName;
  final Duration? estimatedProductionTime;
  final DateTime createdAt;

  const MasterProductionTypeModel({required this.id, required this.typeName, required this.estimatedProductionTime, required this.createdAt});

  factory MasterProductionTypeModel.fromSupabase(Map<String, dynamic> json) {
    return MasterProductionTypeModel(
      id: json['id'],
      typeName: json['type_name'],
      estimatedProductionTime: (json['estimated_production_duration'] as String?)?.parseInterval() ?? Duration.zero,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, typeName, estimatedProductionTime, createdAt];
}

class MasterProductionTypeDetailModel extends Equatable {
  final int id;
  final PartsModel part;
  final int qty;

  const MasterProductionTypeDetailModel({required this.id, required this.part, required this.qty});

  factory MasterProductionTypeDetailModel.fromSupabase(Map<String, dynamic> json) {
    return MasterProductionTypeDetailModel(
      id: json['id'],
      part: PartsModel.fromSupabase(json['master_parts']),
      qty: json['part_qty'],
    );
  }

  @override
  List<Object?> get props => [id, part, qty];
}

class PartsModel extends Equatable {
  final int id;
  final String partCode;
  final String partName;
  final OpAssemblyModel opAssemblyModel;

  const PartsModel({required this.id, required this.partCode, required this.partName, required this.opAssemblyModel});

  factory PartsModel.fromSupabase(Map<String, dynamic> json) {
    return PartsModel(
      id: json['id'],
      partCode: json['part_code'],
      partName: json['part_name'],
      opAssemblyModel: OpAssemblyModel.fromSupabase(
        json['master_op_assembly'],
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        partCode,
        partName,
        opAssemblyModel,
      ];
}
