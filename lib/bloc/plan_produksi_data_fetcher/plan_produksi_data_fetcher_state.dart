part of 'plan_produksi_data_fetcher_bloc.dart';

sealed class PlanProduksiDataFetcherState {}

final class PlanProduksiDataFetcherInitial extends PlanProduksiDataFetcherState {}

final class PlanProduksiDataFetcherLoading extends PlanProduksiDataFetcherState {}

final class PlanProduksiDataFetcherDone extends PlanProduksiDataFetcherState {
  final List<PlanProduksiModel> result;
  PlanProduksiDataFetcherDone({required this.result});
}

final class PlanProduksiDataFetcherError extends PlanProduksiDataFetcherState {
  final String message;
  PlanProduksiDataFetcherError({required this.message});
}
