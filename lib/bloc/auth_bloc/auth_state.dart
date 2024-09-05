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
}

final class UnauthenticatedState extends AuthState {}
