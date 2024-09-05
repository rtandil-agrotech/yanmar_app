import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    _repo.authStateChangeStream.listen((data) {
      add(AuthStateChange(data.event));
    });

    on<AuthStateChange>((event, emit) {
      if (event.data == AuthChangeEvent.signedIn) {
        emit(AuthenticatedState());
      } else if (event.data == AuthChangeEvent.signedOut) {
        emit(UnauthenticatedState());
      } else if (event.data == AuthChangeEvent.initialSession) {
        if (_repo.currentSession != null) {
          emit(AuthenticatedState());
        } else {
          emit(UnauthenticatedState());
        }
      }
    });
  }

  final _repo = locator.get<AuthRepository>();
}
