import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String tenancyName;
  final String username;
  final String password;

  const LoginButtonPressed({
    required this.tenancyName,
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [tenancyName, username, password];
}

class SignUpButtonPressed extends LoginEvent {
  final String tenancyName;
  final String name;
  final String surname;
  final String userName;
  final String emailAddress;
  final String password;

  const SignUpButtonPressed({
    required this.tenancyName,
    required this.name,
    required this.surname,
    required this.userName,
    required this.emailAddress,
    required this.password,
  });

  @override
  List<Object> get props =>
      [tenancyName, name, surname, userName, emailAddress, password];
}

class GoogleSignInPressed extends LoginEvent {
  final String tenancyName;

  const GoogleSignInPressed({required this.tenancyName});

  @override
  List<Object> get props => [tenancyName];
}

class LoadExternalProviders extends LoginEvent {}
