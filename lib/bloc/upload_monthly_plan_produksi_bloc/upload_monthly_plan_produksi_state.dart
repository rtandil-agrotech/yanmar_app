part of 'upload_monthly_plan_produksi_bloc.dart';

sealed class UploadMonthlyPlanProduksiState extends Equatable {
  const UploadMonthlyPlanProduksiState();

  @override
  List<Object> get props => [];
}

final class UploadMonthlyPlanProduksiInitial extends UploadMonthlyPlanProduksiState {}

final class UploadMonthlyPlanProduksiLoading extends UploadMonthlyPlanProduksiState {}

final class UploadMonthlyPlanProduksiDone extends UploadMonthlyPlanProduksiState {}

final class UploadMonthlyPlanProduksiFailed extends UploadMonthlyPlanProduksiState {
  final String error;
  const UploadMonthlyPlanProduksiFailed(this.error);

  @override
  List<Object> get props => [error];
}
