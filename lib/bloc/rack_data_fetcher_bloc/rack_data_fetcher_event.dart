part of 'rack_data_fetcher_bloc.dart';

sealed class RackDataFetcherEvent extends Equatable {
  const RackDataFetcherEvent();

  @override
  List<Object> get props => [];
}

final class FetchRackData extends RackDataFetcherEvent {}
