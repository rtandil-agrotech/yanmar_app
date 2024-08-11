part of 'plan_produksi_data_fetcher_bloc.dart';

sealed class PlanProduksiDataFetcherEvent {}

class FetchPlanProduksiData extends PlanProduksiDataFetcherEvent {
  FetchPlanProduksiData();
}
