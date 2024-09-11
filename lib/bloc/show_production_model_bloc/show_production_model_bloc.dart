import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/production_type_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'show_production_model_event.dart';
part 'show_production_model_state.dart';

class ShowProductionModelBloc extends Bloc<ShowProductionModelEvent, ShowProductionModelState> {
  ShowProductionModelBloc() : super(ShowProductionModelInitial()) {
    on<FetchProductionModel>((event, emit) async {
      emit(ShowProductionModelLoading());
      try {
        final result = await _repo.getMasterProductionType(page: event.page, limit: event.limit);
        emit(
          ShowProductionModelDone(
            productionModels: result['data'],
            currentPage: result['meta']['page'],
            limit: result['meta']['limit'],
            totalData: result['meta']['total'],
          ),
        );
      } catch (e) {
        emit(ShowProductionModelFailed(message: e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
