part of 'delete_production_model_bloc.dart';

sealed class DeleteProductionModelEvent extends Equatable {
  const DeleteProductionModelEvent();

  @override
  List<Object> get props => [];
}

final class DeleteProductionModel extends DeleteProductionModelEvent {
  const DeleteProductionModel({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}
