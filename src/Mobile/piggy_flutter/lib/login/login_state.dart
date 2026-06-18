import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {
  final List<ExternalLoginProvider> externalProviders;

  const LoginInitial({this.externalProviders = const []});

  @override
  List<Object> get props => [externalProviders];
}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String errorMessage;

  const LoginFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class SignUpSuccess extends LoginState {
  final String message;

  const SignUpSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
