import 'dart:async';

import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final PiggyApiClient piggyApiClient;

  UserRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<bool> resolveTenant(String tenancyName) async {
    final isTenantAvailableResult =
        await piggyApiClient.isTenantAvailable(tenancyName);

    if (isTenantAvailableResult.state == 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(UIData.tenantId, isTenantAvailableResult.tenantId!);
      return true;
    }

    return false;
  }

  Future<String?> authenticate(
      {required String tenancyName,
      required String usernameOrEmailAddress,
      required String password}) async {
    if (!await resolveTenant(tenancyName)) {
      return null;
    }

    final authenticateResult = await piggyApiClient.authenticate(
        usernameOrEmailAddress: usernameOrEmailAddress, password: password);

    return authenticateResult.accessToken;
  }

  Future<RegisterResult> register({
    required String tenancyName,
    required String name,
    required String surname,
    required String userName,
    required String emailAddress,
    required String password,
  }) async {
    if (!await resolveTenant(tenancyName)) {
      throw Exception('Family not found. Check your family name and try again.');
    }

    return piggyApiClient.register(
      name: name,
      surname: surname,
      userName: userName,
      emailAddress: emailAddress,
      password: password,
    );
  }

  Future<String?> externalAuthenticate({
    required String tenancyName,
    required String authProvider,
    required String providerKey,
    required String providerAccessCode,
  }) async {
    if (!await resolveTenant(tenancyName)) {
      return null;
    }

    final result = await piggyApiClient.externalAuthenticate(
      authProvider: authProvider,
      providerKey: providerKey,
      providerAccessCode: providerAccessCode,
    );

    if (result.waitingForActivation) {
      throw Exception('Account created. Please wait for activation.');
    }

    return result.accessToken;
  }

  Future<List<ExternalLoginProvider>> getExternalLoginProviders() async {
    return piggyApiClient.getExternalAuthenticationProviders();
  }

  Future<LoginInformationResult?> getCurrentLoginInformation() async {
    return await piggyApiClient.getCurrentLoginInformations();
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(UIData.authToken);

    return token != null;
  }

  Future<bool> isFirstAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(UIData.firstAccess) ?? true;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(UIData.authToken);
    await prefs.remove(UIData.tenantId);
    return;
  }

  Future<void> persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(UIData.authToken, token);
    return;
  }

  Future<UserSettings> getUserSettings() async {
    return await piggyApiClient.getUserSettings();
  }

  Future<void> changeDefaultCurrency(String currencyCode) async {
    return await piggyApiClient.changeDefaultCurrency(currencyCode);
  }
}
