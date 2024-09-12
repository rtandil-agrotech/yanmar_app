import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'plan_produksi_data_fetcher_event.dart';
part 'plan_produksi_data_fetcher_state.dart';

class PlanProduksiDataFetcherBloc extends Bloc<PlanProduksiDataFetcherEvent, PlanProduksiDataFetcherState> {
  PlanProduksiDataFetcherBloc() : super(PlanProduksiDataFetcherInitial()) {
    on<FetchPlanProduksiData>((event, emit) async {
      DateTime now = event.currentDate;

      // Start of the day
      final DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // End of the day
      final DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      emit(PlanProduksiDataFetcherLoading());
      try {
        final result = await _repo.getPlanProduksi(startTime: startOfDay, endTime: endOfDay);
        emit(PlanProduksiDataFetcherDone(result: result));
      } catch (e) {
        emit(PlanProduksiDataFetcherError(message: e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
