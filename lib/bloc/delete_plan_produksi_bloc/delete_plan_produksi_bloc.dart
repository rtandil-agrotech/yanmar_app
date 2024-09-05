import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'delete_plan_produksi_event.dart';
part 'delete_plan_produksi_state.dart';

class DeletePlanProduksiBloc extends Bloc<DeletePlanProduksiEvent, DeletePlanProduksiState> {
  DeletePlanProduksiBloc() : super(DeletePlanProduksiInitial()) {
    on<DeletePlan>((event, emit) async {
      emit(DeletePlanProduksiLoading());
      try {
        await _repo.deletePlanProduksi(id: event.id);
        emit(DeletePlanProduksiDone());
      } catch (e) {
        emit(DeletePlanProduksiFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
