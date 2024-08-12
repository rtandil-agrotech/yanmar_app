part of 'delivery_data_fetcher_bloc.dart';

sealed class DeliveryDataFetcherState extends Equatable {
  const DeliveryDataFetcherState();

  @override
  List<Object> get props => [];
}

final class DeliveryDataFetcherInitial extends DeliveryDataFetcherState {}

final class DeliveryDataFetcherLoading extends DeliveryDataFetcherState {}

final class DeliveryDataFetcherDone extends DeliveryDataFetcherState {
  final List<DeliveryPlanModel> result;
  const DeliveryDataFetcherDone(this.result);
}

final class DeliveryDataFetcherFailed extends DeliveryDataFetcherState {
  final String message;
  const DeliveryDataFetcherFailed(this.message);
}
