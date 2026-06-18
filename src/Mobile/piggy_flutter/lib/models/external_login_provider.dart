class ExternalLoginProvider {
  final String name;
  final String? clientId;

  ExternalLoginProvider({required this.name, this.clientId});

  ExternalLoginProvider.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        clientId = json['clientId'];
}
