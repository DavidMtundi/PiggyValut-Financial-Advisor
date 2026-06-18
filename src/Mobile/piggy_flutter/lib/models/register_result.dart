class RegisterResult {
  final bool canLogin;

  RegisterResult({required this.canLogin});

  RegisterResult.fromJson(Map<String, dynamic> json)
      : canLogin = json['canLogin'] ?? false;
}
