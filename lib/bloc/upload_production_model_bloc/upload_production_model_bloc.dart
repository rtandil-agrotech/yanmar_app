import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'upload_production_model_event.dart';
part 'upload_production_model_state.dart';

class UploadProductionModelBloc extends Bloc<UploadProductionModelEvent, UploadProductionModelState> {
  UploadProductionModelBloc() : super(UploadProductionModelInitial()) {
    on<UploadModel>((event, emit) async {
      emit(UploadProductionModelLoading());
      try {
        await _repo.insertMasterProductionType(event.excelData, event.modelName);
        emit(UploadProductionModelDone());
      } catch (e) {
        emit(UploadProductionModelFailed(message: e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
