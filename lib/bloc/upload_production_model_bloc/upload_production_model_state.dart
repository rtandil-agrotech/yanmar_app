part of 'upload_production_model_bloc.dart';

sealed class UploadProductionModelState extends Equatable {
  const UploadProductionModelState();

  @override
  List<Object> get props => [];
}

final class UploadProductionModelInitial extends UploadProductionModelState {}

final class UploadProductionModelLoading extends UploadProductionModelState {}

final class UploadProductionModelDone extends UploadProductionModelState {}

final class UploadProductionModelFailed extends UploadProductionModelState {
  const UploadProductionModelFailed({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
