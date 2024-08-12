part of 'parts_data_fetcher_bloc.dart';

sealed class PartsDataFetcherEvent extends Equatable {
  const PartsDataFetcherEvent();

  @override
  List<Object> get props => [];
}

class FetchPartsData extends PartsDataFetcherEvent {
  final int opAssemblyId;
  const FetchPartsData({required this.opAssemblyId});
}
