part of 'show_production_model_detail_bloc.dart';

sealed class ShowProductionModelDetailEvent extends Equatable {
  const ShowProductionModelDetailEvent();

  @override
  List<Object> get props => [];
}

final class FetchProductionModelDetail extends ShowProductionModelDetailEvent {
  const FetchProductionModelDetail({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}
