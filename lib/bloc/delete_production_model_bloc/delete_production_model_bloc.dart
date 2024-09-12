import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'delete_production_model_event.dart';
part 'delete_production_model_state.dart';

class DeleteProductionModelBloc extends Bloc<DeleteProductionModelEvent, DeleteProductionModelState> {
  DeleteProductionModelBloc() : super(DeleteProductionModelInitial()) {
    on<DeleteProductionModel>((event, emit) async {
      emit(DeleteProductionModelLoading());
      try {
        await _repo.deleteMasterProductionType(id: event.id);
        emit(DeleteProductionModelDone());
      } catch (e) {
        emit(DeleteProductionModelFailed(message: e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
