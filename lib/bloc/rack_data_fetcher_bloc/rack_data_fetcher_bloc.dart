import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/rack_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'rack_data_fetcher_event.dart';
part 'rack_data_fetcher_state.dart';

class RackDataFetcherBloc extends Bloc<RackDataFetcherEvent, RackDataFetcherState> {
  RackDataFetcherBloc() : super(RackDataFetcherInitial()) {
    final DateTime currentTime = DateTime.now().add(Duration(days: 1));

    on<FetchRackData>((event, emit) async {
      emit(RackDataFetcherLoading());
      try {
        final result = await _repo.getRackList(currentTime: currentTime);
        emit(RackDataFetcherDone(result));
      } catch (e) {
        print(e);
        emit(RackDataFetcherFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
}
