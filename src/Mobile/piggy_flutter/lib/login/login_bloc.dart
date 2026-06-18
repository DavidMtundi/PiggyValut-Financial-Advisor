import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/services/google_auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.userRepository,
    required this.authBloc,
    GoogleAuthService? googleAuthService,
  })  : assert(userRepository != null),
        assert(authBloc != null),
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        super(const LoginInitial()) {
    add(LoadExternalProviders());
  }

  final UserRepository userRepository;
  final AuthBloc authBloc;
  final GoogleAuthService _googleAuthService;

  List<ExternalLoginProvider> _externalProviders = const [];

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoadExternalProviders) {
      try {
        _externalProviders = await userRepository.getExternalLoginProviders();
      } catch (_) {
        _externalProviders = const [];
      }
      yield LoginInitial(externalProviders: _externalProviders);
      return;
    }

    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          tenancyName: event.tenancyName,
          usernameOrEmailAddress: event.username,
          password: event.password,
        );

        if (token == null) {
          yield const LoginFailure(
              errorMessage: 'Invalid family, username, or password');
          yield LoginInitial(externalProviders: _externalProviders);
          return;
        }

        authBloc.add(
            LoggedIn(token: token, tenancyName: event.tenancyName));
        yield LoginInitial(externalProviders: _externalProviders);
      } catch (error) {
        yield LoginFailure(errorMessage: error.toString());
        yield LoginInitial(externalProviders: _externalProviders);
      }
      return;
    }

    if (event is SignUpButtonPressed) {
      yield LoginLoading();

      try {
        final result = await userRepository.register(
          tenancyName: event.tenancyName,
          name: event.name,
          surname: event.surname,
          userName: event.userName,
          emailAddress: event.emailAddress,
          password: event.password,
        );

        if (result.canLogin) {
          final token = await userRepository.authenticate(
            tenancyName: event.tenancyName,
            usernameOrEmailAddress: event.userName,
            password: event.password,
          );

          if (token != null) {
            authBloc.add(
                LoggedIn(token: token, tenancyName: event.tenancyName));
            yield LoginInitial(externalProviders: _externalProviders);
            return;
          }
        }

        yield const SignUpSuccess(
            message: 'Account created. You can sign in now.');
        yield LoginInitial(externalProviders: _externalProviders);
      } catch (error) {
        yield LoginFailure(errorMessage: error.toString());
        yield LoginInitial(externalProviders: _externalProviders);
      }
      return;
    }

    if (event is GoogleSignInPressed) {
      yield LoginLoading();

      try {
        final googleProvider = _externalProviders
            .cast<ExternalLoginProvider?>()
            .firstWhere(
              (provider) => provider?.name == 'Google',
              orElse: () => null,
            );

        final googleResult = await _googleAuthService.signIn(
          provider: googleProvider,
        );

        if (googleResult == null) {
          yield LoginInitial(externalProviders: _externalProviders);
          return;
        }

        final token = await userRepository.externalAuthenticate(
          tenancyName: event.tenancyName,
          authProvider: 'Google',
          providerKey: googleResult.providerKey,
          providerAccessCode: googleResult.accessToken,
        );

        if (token == null) {
          yield const LoginFailure(
              errorMessage:
                  'Google sign-in failed. Check your family name and try again.');
          yield LoginInitial(externalProviders: _externalProviders);
          return;
        }

        authBloc.add(
            LoggedIn(token: token, tenancyName: event.tenancyName));
        yield LoginInitial(externalProviders: _externalProviders);
      } catch (error) {
        yield LoginFailure(errorMessage: error.toString());
        yield LoginInitial(externalProviders: _externalProviders);
      }
    }
  }
}
