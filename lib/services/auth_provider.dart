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
    }
    return false;
  }
}