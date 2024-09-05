part of 'monthly_plan_produksi_data_fetcher_bloc.dart';

sealed class MonthlyPlanProduksiDataFetcherState extends Equatable {
  const MonthlyPlanProduksiDataFetcherState();

  @override
  List<Object> get props => [];
}

final class MonthlyPlanProduksiDataFetcherInitial extends MonthlyPlanProduksiDataFetcherState {}

final class MonthlyPlanProduksiDataFetcherLoading extends MonthlyPlanProduksiDataFetcherState {}

final class MonthlyPlanProduksiDataFetcherDone extends MonthlyPlanProduksiDataFetcherState {
  final List<MonthlyPlanProduksiModel> result;
  const MonthlyPlanProduksiDataFetcherDone(this.result);

  @override
  List<Object> get props => [result];
}

final class MonthlyPlanProduksiDataFetcherFailed extends MonthlyPlanProduksiDataFetcherState {
  final String message;
  const MonthlyPlanProduksiDataFetcherFailed(this.message);

  @override
  List<Object> get props => [message];
}
