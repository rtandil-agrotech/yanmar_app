part of 'update_estimated_production_duration_bloc.dart';

sealed class UpdateEstimatedProductionDurationState extends Equatable {
  const UpdateEstimatedProductionDurationState();

  @override
  List<Object> get props => [];
}

final class UpdateEstimatedProductionDurationInitial extends UpdateEstimatedProductionDurationState {}

final class UpdateEstimatedProductionDurationLoading extends UpdateEstimatedProductionDurationState {}

final class UpdateEstimatedProductionDurationDone extends UpdateEstimatedProductionDurationState {}

final class UpdateEstimatedProductionDurationFailed extends UpdateEstimatedProductionDurationState {
  final String message;

  const UpdateEstimatedProductionDurationFailed(this.message);

  @override
  List<Object> get props => [message];
}
