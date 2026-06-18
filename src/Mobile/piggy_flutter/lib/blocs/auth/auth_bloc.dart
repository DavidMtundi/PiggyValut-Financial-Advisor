import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/models/login_information_result.dart';

import 'package:piggy_flutter/repositories/repositories.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.userRepository}) : super(AuthUninitialized());

  final UserRepository userRepository;

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStarted) {
      initOnesignal();
      final bool isFirstAccess = await userRepository.isFirstAccess();
      if (isFirstAccess) {
        yield FirstAccess();
      } else {
        final bool hasToken = await userRepository.hasToken();
        if (hasToken) {
          final LoginInformationResult? result =
              await userRepository.getCurrentLoginInformation();
          if (result == null || result.user == null || result.user!.id == null) {
            yield AuthUnauthenticated();
          } else {
            yield AuthAuthenticated(user: result.user, tenant: result.tenant);
          }
        } else {
          yield AuthUnauthenticated();
        }
      }
    }

    if (event is LoggedIn) {
      yield AuthLoading();
      final String? token = event.token;
      if (token == null) {
        yield AuthUnauthenticated();
        return;
      }
      await userRepository.persistToken(token);

      try {
        OneSignal.User.addTagWithKey(
            'tenancyName', event.tenancyName.trim().toLowerCase());
      } catch (e) {
        // Push tags are optional for local development.
      }

      final LoginInformationResult? result =
          await userRepository.getCurrentLoginInformation();
      if (result == null || result.user == null || result.user!.id == null) {
        yield AuthUnauthenticated();
      } else {
        yield AuthAuthenticated(user: result.user, tenant: result.tenant);
      }
    }

    if (event is LoggedOut) {
      yield AuthLoading();

      try {
        OneSignal.User.removeTag('tenancyName');
      } catch (error) {
        // Push tags are optional for local development.
      }
      await userRepository.deleteToken();
      yield AuthUnauthenticated();
    }
  }

  void initOnesignal() {
    try {
      OneSignal.initialize('9bf198c9-442b-4619-b5c9-759fc250f15b');
    } catch (error) {
      debugPrint('$error');
    }
  }
}
