part of 'delivery_data_fetcher_bloc.dart';

sealed class DeliveryDataFetcherEvent extends Equatable {
  const DeliveryDataFetcherEvent();

  @override
  List<Object> get props => [];
}

final class FetchDeliveryData extends DeliveryDataFetcherEvent {}