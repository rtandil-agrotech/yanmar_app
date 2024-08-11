import 'package:equatable/equatable.dart';

class ProductionActualModel extends Equatable {
  final int id;
  final DateTime recordedTime;

  const ProductionActualModel({required this.id, required this.recordedTime});

  factory ProductionActualModel.fromSupabase(Map<String, dynamic> map) {
    return ProductionActualModel(id: map['id'], recordedTime: DateTime.parse(map['recorded_time']));
  }

  @override
  List<Object?> get props => [
        id,
        recordedTime,
      ];
}
