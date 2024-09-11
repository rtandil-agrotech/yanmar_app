part of 'show_production_model_bloc.dart';

sealed class ShowProductionModelEvent extends Equatable {
  const ShowProductionModelEvent();

  @override
  List<Object> get props => [];
}

final class FetchProductionModel extends ShowProductionModelEvent {
  const FetchProductionModel({required this.page, required this.limit});

  final int page;
  final int limit;

  @override
  List<Object> get props => [page, limit];
}
