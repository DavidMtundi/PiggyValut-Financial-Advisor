import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _familyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _signupUsernameController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _familyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _signupUsernameController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    BlocProvider.of<LoginBloc>(context).add(
      LoginButtonPressed(
        tenancyName: _familyController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onSignUp() {
    BlocProvider.of<LoginBloc>(context).add(
      SignUpButtonPressed(
        tenancyName: _familyController.text.trim(),
        name: _firstNameController.text.trim(),
        surname: _lastNameController.text.trim(),
        userName: _signupUsernameController.text.trim(),
        emailAddress: _emailController.text.trim(),
        password: _signupPasswordController.text,
      ),
    );
  }

  void _onGoogleSignIn() {
    final family = _familyController.text.trim();
    if (family.isEmpty) {
      _showMessage('Enter your family name before continuing with Google.');
      return;
    }

    BlocProvider.of<LoginBloc>(context).add(
      GoogleSignInPressed(tenancyName: family),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showMessage(state.errorMessage);
        }
        if (state is SignUpSuccess) {
          _showMessage(state.message, isError: false);
          _tabController.animateTo(0);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Stack(
            children: [
              Column(
                children: [
                  _AuthHeader(primary: primary),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              labelColor: primary,
                              unselectedLabelColor: PiggyAppTheme.lightText,
                              indicatorColor: primary,
                              indicatorWeight: 3,
                              labelStyle: const TextStyle(
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              tabs: const [
                                Tab(
                                  key: Key('login_tab_sign_in'),
                                  text: 'Sign In',
                                ),
                                Tab(
                                  key: Key('login_tab_sign_up'),
                                  text: 'Sign Up',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _SignInFields(
                                    familyController: _familyController,
                                    usernameController: _usernameController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscureSignInPassword,
                                    onTogglePassword: () => setState(() {
                                      _obscureSignInPassword =
                                          !_obscureSignInPassword;
                                    }),
                                  ),
                                  _SignUpFields(
                                    familyController: _familyController,
                                    firstNameController: _firstNameController,
                                    lastNameController: _lastNameController,
                                    emailController: _emailController,
                                    usernameController:
                                        _signupUsernameController,
                                    passwordController:
                                        _signupPasswordController,
                                    obscurePassword: _obscureSignUpPassword,
                                    onTogglePassword: () => setState(() {
                                      _obscureSignUpPassword =
                                          !_obscureSignUpPassword;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                key: Key(_tabController.index == 0
                                    ? 'login_sign_in_button'
                                    : 'login_sign_up_button'),
                                onPressed: isLoading
                                    ? null
                                    : (_tabController.index == 0
                                        ? _onSignIn
                                        : _onSignUp),
                                child: Text(
                                  _tabController.index == 0
                                      ? 'Sign In'
                                      : 'Create Account',
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                key: const Key('login_google_button'),
                                onPressed: isLoading ? null : _onGoogleSignIn,
                                icon: const _GoogleMark(size: 20),
                                label: const Text('Continue with Google'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: PiggyAppTheme.darkerText,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withValues(alpha: 0.85),
            const Color(0xFF1F8A7A),
          ],
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'auth_logo',
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset('graphics/logo.png'),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Welcome to ${UIData.appName}',
            style: const TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue',
            key: const Key('login_subtitle'),
            style: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInFields extends StatelessWidget {
  const _SignInFields({
    required this.familyController,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController familyController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _AuthTextField(
          key: const Key('login_family_field'),
          controller: familyController,
          label: 'Family',
          hint: 'Your family or workspace name',
          icon: Icons.home_work_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          key: const Key('login_username_field'),
          controller: usernameController,
          label: 'Username',
          hint: 'Enter your username',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          key: const Key('login_password_field'),
          controller: passwordController,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignUpFields extends StatelessWidget {
  const _SignUpFields({
    required this.familyController,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController familyController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _AuthTextField(
          key: const Key('signup_family_field'),
          controller: familyController,
          label: 'Family',
          hint: 'Join an existing family workspace',
          icon: Icons.home_work_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _AuthTextField(
                key: const Key('signup_first_name_field'),
                controller: firstNameController,
                label: 'First name',
                hint: 'First',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AuthTextField(
                key: const Key('signup_last_name_field'),
                controller: lastNameController,
                label: 'Last name',
                hint: 'Last',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          key: const Key('signup_email_field'),
          controller: emailController,
          label: 'Email',
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          key: const Key('signup_username_field'),
          controller: usernameController,
          label: 'Username',
          hint: 'Choose a username',
          icon: Icons.alternate_email_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _AuthTextField(
          key: const Key('signup_password_field'),
          controller: passwordController,
          label: 'Password',
          hint: 'At least 8 characters',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: PiggyAppTheme.chipBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final green = Paint()..color = const Color(0xFF34A853);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final red = Paint()..color = const Color(0xFFEA4335);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4,
      3.5,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2,
      1.4,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.0,
      1.2,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4,
      1.4,
      true,
      red,
    );

    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
