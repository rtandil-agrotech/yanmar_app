part of 'show_plan_produksi_bloc.dart';

sealed class ShowPlanProduksiState extends Equatable {
  const ShowPlanProduksiState();

  @override
  List<Object> get props => [];
}

final class ShowPlanProduksiInitial extends ShowPlanProduksiState {}

final class ShowPlanProduksiLoading extends ShowPlanProduksiState {}

final class ShowPlanProduksiDone extends ShowPlanProduksiState {
  final List<PlanProduksiModel> result;
  const ShowPlanProduksiDone({required this.result});

  @override
  List<Object> get props => [result];
}

final class ShowPlanProduksiFailed extends ShowPlanProduksiState {
  final String message;
  const ShowPlanProduksiFailed(this.message);

  @override
  List<Object> get props => [message];
}
