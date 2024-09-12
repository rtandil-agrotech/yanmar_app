part of 'show_production_model_detail_bloc.dart';

sealed class ShowProductionModelDetailState extends Equatable {
  const ShowProductionModelDetailState();

  @override
  List<Object> get props => [];
}

final class ShowProductionModelDetailInitial extends ShowProductionModelDetailState {}

final class ShowProductionModelDetailLoading extends ShowProductionModelDetailState {}

final class ShowProductionModelDetailDone extends ShowProductionModelDetailState {
  final List<MasterProductionTypeDetailModel> details;
  final MasterProductionTypeModel header;

  const ShowProductionModelDetailDone({required this.details, required this.header});

  @override
  List<Object> get props => [details, header];
}

final class ShowProductionModelDetailFailed extends ShowProductionModelDetailState {
  final String message;

  const ShowProductionModelDetailFailed({required this.message});

  @override
  List<Object> get props => [message];
}
