import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'update_estimated_production_duration_event.dart';
part 'update_estimated_production_duration_state.dart';

class UpdateEstimatedProductionDurationBloc extends Bloc<UpdateEstimatedProductionDurationEvent, UpdateEstimatedProductionDurationState> {
  UpdateEstimatedProductionDurationBloc() : super(UpdateEstimatedProductionDurationInitial()) {
    on<UpdateEstimatedProductionDuration>((event, emit) async {
      emit(UpdateEstimatedProductionDurationLoading());
      try {
        await repo.updateEstimatedProductionDuration(typeId: event.id, productionDuration: event.productionDuration);
        emit(UpdateEstimatedProductionDurationDone());
      } catch (e) {
        emit(UpdateEstimatedProductionDurationFailed(e.toString()));
      }
    });
  }

  final repo = locator.get<SupabaseRepository>();
}
