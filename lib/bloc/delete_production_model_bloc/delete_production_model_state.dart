part of 'delete_production_model_bloc.dart';

sealed class DeleteProductionModelState extends Equatable {
  const DeleteProductionModelState();

  @override
  List<Object> get props => [];
}

final class DeleteProductionModelInitial extends DeleteProductionModelState {}

final class DeleteProductionModelLoading extends DeleteProductionModelState {}

final class DeleteProductionModelDone extends DeleteProductionModelState {}

final class DeleteProductionModelFailed extends DeleteProductionModelState {
  final String message;
  const DeleteProductionModelFailed({required this.message});

  @override
  List<Object> get props => [message];
}
