part of 'show_plan_produksi_bloc.dart';

sealed class ShowPlanProduksiEvent extends Equatable {
  const ShowPlanProduksiEvent();

  @override
  List<Object> get props => [];
}

final class FetchPlanProduksi extends ShowPlanProduksiEvent {
  final DateTime dateTime;
  const FetchPlanProduksi({required this.dateTime});

  @override
  List<Object> get props => [dateTime];
}
