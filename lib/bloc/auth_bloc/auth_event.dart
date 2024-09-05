part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LogIn extends AuthEvent {}

class LogOut extends AuthEvent {}

class AuthStateChange extends AuthEvent {
  final AuthChangeEvent data;
  const AuthStateChange(this.data);
}
