import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'upload_monthly_plan_produksi_event.dart';
part 'upload_monthly_plan_produksi_state.dart';

class UploadMonthlyPlanProduksiBloc extends Bloc<UploadMonthlyPlanProduksiEvent, UploadMonthlyPlanProduksiState> {
  UploadMonthlyPlanProduksiBloc() : super(UploadMonthlyPlanProduksiInitial()) {
    on<UploadPlan>((event, emit) async {
      emit(UploadMonthlyPlanProduksiLoading());

      DateTime now = event.selectedDate;

      final DateTime startTime = DateTime(now.year, now.month, 1);
      final DateTime endTime = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));

      try {
        await _repo.uploadMonthlyPlanProduksi(event.excelData, startTime, endTime, event.loggedUserId);
        emit(UploadMonthlyPlanProduksiDone());
      } catch (e) {
        print('Here ${e.toString()}');
        emit(UploadMonthlyPlanProduksiFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
