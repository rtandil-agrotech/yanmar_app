part of 'update_estimated_production_duration_bloc.dart';

sealed class UpdateEstimatedProductionDurationEvent extends Equatable {
  const UpdateEstimatedProductionDurationEvent();

  @override
  List<Object> get props => [];
}

final class UpdateEstimatedProductionDuration extends UpdateEstimatedProductionDurationEvent {
  final int id;
  final Duration productionDuration;

  const UpdateEstimatedProductionDuration({required this.id, required this.productionDuration});

  @override
  List<Object> get props => [id, productionDuration];
}
