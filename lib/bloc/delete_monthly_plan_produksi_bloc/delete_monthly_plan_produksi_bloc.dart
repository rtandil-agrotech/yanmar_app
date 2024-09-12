import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'delete_monthly_plan_produksi_event.dart';
part 'delete_monthly_plan_produksi_state.dart';

class DeleteMonthlyPlanProduksiBloc extends Bloc<DeleteMonthlyPlanProduksiEvent, DeleteMonthlyPlanProduksiState> {
  DeleteMonthlyPlanProduksiBloc() : super(DeleteMonthlyPlanProduksiInitial()) {
    on<DeletePlan>((event, emit) async {
      emit(DeleteMonthlyPlanProduksiLoading());

      try {
        await _repo.deleteMonthlyPlanProduksi(id: event.id);
        emit(DeleteMonthlyPlanProduksiDone());
      } catch (e) {
        emit(DeleteMonthlyPlanProduksiFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
