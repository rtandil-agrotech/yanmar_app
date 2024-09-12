part of 'delete_monthly_plan_produksi_bloc.dart';

sealed class DeleteMonthlyPlanProduksiEvent extends Equatable {
  const DeleteMonthlyPlanProduksiEvent();

  @override
  List<Object> get props => [];
}

final class DeletePlan extends DeleteMonthlyPlanProduksiEvent {
  final int id;

  const DeletePlan(this.id);

  @override
  List<Object> get props => [id];
}
