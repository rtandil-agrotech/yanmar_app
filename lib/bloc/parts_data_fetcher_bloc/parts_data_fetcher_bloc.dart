import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/checklist_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'parts_data_fetcher_event.dart';
part 'parts_data_fetcher_state.dart';

class PartsDataFetcherBloc extends Bloc<PartsDataFetcherEvent, PartsDataFetcherState> {
  PartsDataFetcherBloc() : super(PartsDataFetcherInitial()) {
    on<FetchPartsData>((event, emit) async {
      emit(PartsDataFetcherLoading());
      try {
        final result = await _repo.getPartListForOpAssembly(opAssemblyId: event.opAssemblyId, currentTime: DateTime.now());
        emit(PartsDataFetcherDone(result));
      } catch (e) {
        emit(PartsDataFetcherFailed(e.toString()));
      }
    });
  }

  final _repo = locator<SupabaseRepository>();
}
