part of 'delete_plan_produksi_bloc.dart';

sealed class DeletePlanProduksiState extends Equatable {
  const DeletePlanProduksiState();

  @override
  List<Object> get props => [];
}

final class DeletePlanProduksiInitial extends DeletePlanProduksiState {}

final class DeletePlanProduksiLoading extends DeletePlanProduksiState {}

final class DeletePlanProduksiDone extends DeletePlanProduksiState {}

final class DeletePlanProduksiFailed extends DeletePlanProduksiState {
  final String message;
  const DeletePlanProduksiFailed(this.message);

  @override
  List<Object> get props => [message];
}
