import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/login/login_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  const LoginPage({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    final theme = PiggyAppTheme.buildLightTheme();

    return Theme(
      data: theme,
      child: Scaffold(
        body: BlocProvider(
          create: (context) => LoginBloc(
            authBloc: BlocProvider.of<AuthBloc>(context),
            userRepository: userRepository,
          ),
          child: const LoginForm(),
        ),
      ),
    );
  }
}
