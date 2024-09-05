import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/user_model.dart';
import 'package:yanmar_app/repository/auth_repository.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    _authRepo.authStateChangeStream.listen((data) {
      add(AuthStateChange(data.event));
    });

    on<AuthStateChange>((event, emit) async {
      if (event.data == AuthChangeEvent.signedIn) {
        final uuid = _authRepo.currentUser!.id;
        final user = await _dbRepo.getLoggedUser(uuid: uuid);
        emit(AuthenticatedState(user: user));
      } else if (event.data == AuthChangeEvent.signedOut) {
        emit(UnauthenticatedState());
      } else if (event.data == AuthChangeEvent.initialSession) {
        if (_authRepo.currentSession != null) {
          final uuid = _authRepo.currentUser!.id;
          final user = await _dbRepo.getLoggedUser(uuid: uuid);
          emit(AuthenticatedState(user: user));
        } else {
          emit(UnauthenticatedState());
        }
      }
    });

    on<LogIn>((event, emit) async {
      try {
        await _authRepo.login(email: event.email, password: event.password);
      } catch (e) {
        emit(FailedToAuthenticate(e.toString()));
      }
    });

    on<LogOut>((event, emit) async {
      await _authRepo.logout();
    });
  }

  final _authRepo = locator.get<AuthRepository>();
  final _dbRepo = locator.get<SupabaseRepository>();
}
