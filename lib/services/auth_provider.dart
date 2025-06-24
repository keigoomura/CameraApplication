import 'dart:io' show Platform;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  FlutterAppAuth appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _androidClientId = '668765901266-k2i109ou4b5n46jphtocgp4gup5161l0.apps.googleusercontent.com';
  final String _iosClientId = '668765901266-ho05kel58kvkg0966a0vose1gojmhifl.apps.googleusercontent.com';

  // Reversed client IDs for redirect URL
  final String _androidClientIdReversed = 'com.googleusercontent.apps.668765901266-k2i109ou4b5n46jphtocgp4gup5161l0';
  final String _iosClientIdReversed = 'com.googleusercontent.apps.668765901266-ho05kel58kvkg0966a0vose1gojmhifl';
  final String _issuer = 'https://accounts.google.com';
  final List<String> _scopes = ['openid', 'profile', 'email'];

  String get _clientId => Platform.isAndroid ? _androidClientId : _iosClientId;
  String get _clientIdReversed => Platform.isAndroid ? _androidClientIdReversed : _iosClientIdReversed;
  String get _redirectUrl => '$_clientIdReversed:/oauthredirect';

  Future<bool> login() async {
    try {
      final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: _scopes,
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'id_token', value: result.idToken);
        return true;
      }
    } 
    
    catch (e, stackTrace) {
      print('OAuth login failed: $e');
      print(stackTrace);
      rethrow; // Re-throw the exception for handling in login_screen.dart
    }
    return false;
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final TokenResponse? result = await appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          refreshToken: refreshToken,
          issuer: _issuer,
          scopes: _scopes,
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'id_token', value: result.idToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken ?? refreshToken);
        return true;
      }
    } 
    
    catch (e, stackTrace) {
      print('Token refresh failed: $e');
      print(stackTrace);
    }
    return false;
  }

  Future<void> logout() async {
    try {
      // Commenting out end session request because signing out of google accounts is not needed
      // final idToken = await _secureStorage.read(key: 'id_token');
      // if (idToken == null) return;

      // await appAuth.endSession(
      //   EndSessionRequest(
      //     idTokenHint: idToken,
      //     postLogoutRedirectUrl: _redirectUrl,
      //     issuer: _issuer,
      //   ),
      // );

      await _secureStorage.deleteAll();
    } 

    catch (e, stackTrace) {
      print('Logout failed: $e');
      print(stackTrace);
    }
  }
}