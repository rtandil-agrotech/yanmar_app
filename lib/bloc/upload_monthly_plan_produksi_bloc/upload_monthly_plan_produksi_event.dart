part of 'upload_monthly_plan_produksi_bloc.dart';

sealed class UploadMonthlyPlanProduksiEvent extends Equatable {
  const UploadMonthlyPlanProduksiEvent();

  @override
  List<Object> get props => [];
}

final class UploadPlan extends UploadMonthlyPlanProduksiEvent {
  final List<Map<String, dynamic>> excelData;
  final int loggedUserId;
  final DateTime selectedDate;

  const UploadPlan(this.excelData, this.loggedUserId, this.selectedDate);

  @override
  List<Object> get props => [excelData, loggedUserId, selectedDate];
}
