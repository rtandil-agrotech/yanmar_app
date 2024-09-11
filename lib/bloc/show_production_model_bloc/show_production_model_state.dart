part of 'show_production_model_bloc.dart';

sealed class ShowProductionModelState extends Equatable {
  const ShowProductionModelState();

  @override
  List<Object> get props => [];
}

final class ShowProductionModelInitial extends ShowProductionModelState {}

final class ShowProductionModelLoading extends ShowProductionModelState {}

final class ShowProductionModelDone extends ShowProductionModelState {
  const ShowProductionModelDone({required this.productionModels, required this.currentPage, required this.limit, required this.totalData});

  final List<MasterProductionTypeModel> productionModels;
  final int currentPage;
  final int limit;
  final int totalData;

  @override
  List<Object> get props => [productionModels, currentPage, limit, totalData];
}

final class ShowProductionModelFailed extends ShowProductionModelState {
  const ShowProductionModelFailed({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
