part of 'plan_produksi_data_fetcher_bloc.dart';

sealed class PlanProduksiDataFetcherState extends Equatable {
  const PlanProduksiDataFetcherState();

  @override
  List<Object?> get props => [];
}

final class PlanProduksiDataFetcherInitial extends PlanProduksiDataFetcherState {}

final class PlanProduksiDataFetcherLoading extends PlanProduksiDataFetcherState {}

final class PlanProduksiDataFetcherDone extends PlanProduksiDataFetcherState {
  final List<PlanProduksiModel> result;
  const PlanProduksiDataFetcherDone({required this.result});
}

final class PlanProduksiDataFetcherError extends PlanProduksiDataFetcherState {
  final String message;
  const PlanProduksiDataFetcherError({required this.message});

  @override
  List<Object> get props => [message];
}
