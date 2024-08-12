part of 'parts_data_fetcher_bloc.dart';

sealed class PartsDataFetcherState extends Equatable {
  const PartsDataFetcherState();

  @override
  List<Object> get props => [];
}

final class PartsDataFetcherInitial extends PartsDataFetcherState {}

final class PartsDataFetcherLoading extends PartsDataFetcherState {}

final class PartsDataFetcherDone extends PartsDataFetcherState {
  final ChecklistModel? data;
  const PartsDataFetcherDone(this.data);
}

final class PartsDataFetcherFailed extends PartsDataFetcherState {
  final String message;

  const PartsDataFetcherFailed(this.message);
}
