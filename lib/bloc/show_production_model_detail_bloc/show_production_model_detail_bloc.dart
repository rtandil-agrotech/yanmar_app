import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/production_type_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'show_production_model_detail_event.dart';
part 'show_production_model_detail_state.dart';

class ShowProductionModelDetailBloc extends Bloc<ShowProductionModelDetailEvent, ShowProductionModelDetailState> {
  ShowProductionModelDetailBloc() : super(ShowProductionModelDetailInitial()) {
    on<FetchProductionModelDetail>((event, emit) async {
      emit(ShowProductionModelDetailLoading());
      try {
        final result = await _repo.getMasterProductionTypeDetail(typeId: event.id);
        emit(ShowProductionModelDetailDone(
            details: result['data'] as List<MasterProductionTypeDetailModel>, header: result['header'] as MasterProductionTypeModel));
      } catch (e) {
        emit(ShowProductionModelDetailFailed(message: e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
