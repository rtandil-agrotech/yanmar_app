part of 'delete_monthly_plan_produksi_bloc.dart';

sealed class DeleteMonthlyPlanProduksiState extends Equatable {
  const DeleteMonthlyPlanProduksiState();

  @override
  List<Object> get props => [];
}

final class DeleteMonthlyPlanProduksiInitial extends DeleteMonthlyPlanProduksiState {}

final class DeleteMonthlyPlanProduksiLoading extends DeleteMonthlyPlanProduksiState {}

final class DeleteMonthlyPlanProduksiDone extends DeleteMonthlyPlanProduksiState {}

final class DeleteMonthlyPlanProduksiFailed extends DeleteMonthlyPlanProduksiState {
  final String error;
  const DeleteMonthlyPlanProduksiFailed(this.error);

  @override
  List<Object> get props => [error];
}
