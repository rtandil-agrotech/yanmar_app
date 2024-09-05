part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LogIn extends AuthEvent {
  final String email;
  final String password;

  const LogIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogOut extends AuthEvent {}

class AuthStateChange extends AuthEvent {
  final AuthChangeEvent data;
  const AuthStateChange(this.data);

  @override
  List<Object> get props => [data];
}
