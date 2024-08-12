import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/delivery_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'delivery_data_fetcher_event.dart';
part 'delivery_data_fetcher_state.dart';

class DeliveryDataFetcherBloc extends Bloc<DeliveryDataFetcherEvent, DeliveryDataFetcherState> {
  DeliveryDataFetcherBloc() : super(DeliveryDataFetcherInitial()) {
    DateTime now = DateTime.now();

    // Start of the day
    final DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

    // End of the day
    final DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    subs = _repo.subscribeToItemRequestChanges((payload) {
      add(FetchDeliveryData());
    });

    on<FetchDeliveryData>((event, emit) async {
      emit(DeliveryDataFetcherLoading());
      try {
        final result = await _repo.getDelivery(startTime: startOfDay, endTime: endOfDay);
        emit(DeliveryDataFetcherDone(result));
      } catch (e) {
        emit(DeliveryDataFetcherFailed(e.toString()));
      }
    });
  }

  final _repo = locator.get<SupabaseRepository>();
  late final RealtimeChannel subs;

  @override
  Future<void> close() {
    _repo.unsubscribe(subs);
    return super.close();
  }
}
