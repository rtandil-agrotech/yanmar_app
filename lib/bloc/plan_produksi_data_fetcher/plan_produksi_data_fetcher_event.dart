part of 'plan_produksi_data_fetcher_bloc.dart';

sealed class PlanProduksiDataFetcherEvent extends Equatable {
  const PlanProduksiDataFetcherEvent();

  @override
  List<Object?> get props => [];
}

final class FetchPlanProduksiData extends PlanProduksiDataFetcherEvent {
  const FetchPlanProduksiData();
}
