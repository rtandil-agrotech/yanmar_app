part of 'delete_plan_produksi_bloc.dart';

sealed class DeletePlanProduksiEvent extends Equatable {
  const DeletePlanProduksiEvent();

  @override
  List<Object> get props => [];
}

final class DeletePlan extends DeletePlanProduksiEvent {
  final List<int> id;

  const DeletePlan(this.id);

  @override
  List<Object> get props => [id];
}
