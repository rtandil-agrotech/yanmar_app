import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'monthly_plan_produksi_data_fetcher_event.dart';
part 'monthly_plan_produksi_data_fetcher_state.dart';

class MonthlyPlanProduksiDataFetcherBloc extends Bloc<MonthlyPlanProduksiDataFetcherEvent, MonthlyPlanProduksiDataFetcherState> {
  MonthlyPlanProduksiDataFetcherBloc() : super(MonthlyPlanProduksiDataFetcherInitial()) {
    final DateTime now = DateTime.now();

    final DateTime startTime = DateTime(now.year, now.month, 1);
    final DateTime endTime = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));

    on<FetchMonthlyPlanProduksiData>((event, emit) async {
      emit(MonthlyPlanProduksiDataFetcherLoading());
      try {
        final result = await _repo.getMonthlyPlanProduksi(startTime: startTime, endTime: endTime);
        emit(MonthlyPlanProduksiDataFetcherDone(result));
      } catch (e) {
        emit(MonthlyPlanProduksiDataFetcherFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
