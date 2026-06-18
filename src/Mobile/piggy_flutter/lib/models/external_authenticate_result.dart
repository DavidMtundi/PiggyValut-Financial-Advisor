class ExternalAuthenticateResult {
  final String? accessToken;
  final bool waitingForActivation;

  ExternalAuthenticateResult({
    this.accessToken,
    this.waitingForActivation = false,
  });

  ExternalAuthenticateResult.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        waitingForActivation = json['waitingForActivation'] ?? false;
}
