part of 'rack_data_fetcher_bloc.dart';

sealed class RackDataFetcherState extends Equatable {
  const RackDataFetcherState();

  @override
  List<Object> get props => [];
}

final class RackDataFetcherInitial extends RackDataFetcherState {}

final class RackDataFetcherLoading extends RackDataFetcherState {}

final class RackDataFetcherDone extends RackDataFetcherState {
  final List<RackModel> data;

  const RackDataFetcherDone(this.data);
}

final class RackDataFetcherFailed extends RackDataFetcherState {
  final String message;

  const RackDataFetcherFailed(this.message);
}
