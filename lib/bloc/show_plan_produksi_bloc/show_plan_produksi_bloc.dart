import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'show_plan_produksi_event.dart';
part 'show_plan_produksi_state.dart';

class ShowPlanProduksiBloc extends Bloc<ShowPlanProduksiEvent, ShowPlanProduksiState> {
  ShowPlanProduksiBloc() : super(ShowPlanProduksiInitial()) {
    on<FetchPlanProduksi>((event, emit) async {
      final today = event.dateTime;

      // Start of the day
      final DateTime startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);

      // End of the day
      final DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

      emit(ShowPlanProduksiLoading());

      try {
        final result = await _repo.getPlanProduksi(startTime: startOfDay, endTime: endOfDay);
        emit(ShowPlanProduksiDone(result: result));
      } catch (e) {
        emit(ShowPlanProduksiFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
