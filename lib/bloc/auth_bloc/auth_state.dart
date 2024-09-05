part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthenticatedState extends AuthState {
  final UserModel user;

  const AuthenticatedState({required this.user});

  @override
  List<Object> get props => [user];
}

final class UnauthenticatedState extends AuthState {}

final class FailedToAuthenticate extends AuthState {
  final String message;
  const FailedToAuthenticate(this.message);

  @override
  List<Object> get props => [message];
}
