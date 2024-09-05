part of 'upload_plan_produksi_bloc.dart';

sealed class UploadPlanProduksiEvent extends Equatable {
  const UploadPlanProduksiEvent();

  @override
  List<Object> get props => [];
}

final class UploadPlan extends UploadPlanProduksiEvent {
  final Map<String, dynamic> excelData;
  final int loggedUserId;

  const UploadPlan(this.excelData, this.loggedUserId);

  @override
  List<Object> get props => [excelData, loggedUserId];
}
