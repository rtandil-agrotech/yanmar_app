part of 'monthly_plan_produksi_data_fetcher_bloc.dart';

sealed class MonthlyPlanProduksiDataFetcherEvent extends Equatable {
  const MonthlyPlanProduksiDataFetcherEvent();

  @override
  List<Object> get props => [];
}

class FetchMonthlyPlanProduksiData extends MonthlyPlanProduksiDataFetcherEvent {}
