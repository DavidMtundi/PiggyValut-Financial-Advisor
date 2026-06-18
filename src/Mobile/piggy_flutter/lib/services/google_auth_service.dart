import 'package:google_sign_in/google_sign_in.dart';
import 'package:piggy_flutter/models/models.dart';

class GoogleAuthService {
  GoogleSignIn _googleSignIn({String? serverClientId}) {
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: serverClientId,
    );
  }

  Future<({String providerKey, String accessToken})?> signIn({
    ExternalLoginProvider? provider,
  }) async {
    final googleSignIn = _googleSignIn(
      serverClientId: provider?.clientId,
    );

    final account = await googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      throw Exception('Could not obtain Google access token');
    }

    return (providerKey: account.id, accessToken: accessToken);
  }

  Future<void> signOut() async {
    await _googleSignIn().signOut();
  }
}
