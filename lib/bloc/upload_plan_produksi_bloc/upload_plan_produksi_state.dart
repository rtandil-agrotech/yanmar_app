part of 'upload_plan_produksi_bloc.dart';

sealed class UploadPlanProduksiState extends Equatable {
  const UploadPlanProduksiState();

  @override
  List<Object> get props => [];
}

final class UploadPlanProduksiInitial extends UploadPlanProduksiState {}

final class UploadPlanProduksiLoading extends UploadPlanProduksiState {}

final class UploadPlanProduksiDone extends UploadPlanProduksiState {}

final class UploadPlanProduksiFailed extends UploadPlanProduksiState {
  final String message;
  const UploadPlanProduksiFailed(this.message);

  @override
  List<Object> get props => [message];
}
