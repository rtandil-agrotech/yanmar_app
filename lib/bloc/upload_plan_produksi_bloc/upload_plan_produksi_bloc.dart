import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'upload_plan_produksi_event.dart';
part 'upload_plan_produksi_state.dart';

class UploadPlanProduksiBloc extends Bloc<UploadPlanProduksiEvent, UploadPlanProduksiState> {
  UploadPlanProduksiBloc() : super(UploadPlanProduksiInitial()) {
    on<UploadPlan>((event, emit) async {
      emit(UploadPlanProduksiLoading());
      try {
        await _repo.insertPlanProduksi(event.excelData, event.loggedUserId);
        emit(UploadPlanProduksiDone());
      } catch (e) {
        emit(UploadPlanProduksiFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
