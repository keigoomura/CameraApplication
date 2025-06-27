import 'dart:io' show Platform;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

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

      if( result == null) {
        debugPrint('Authorization failed or cancelled');
        return false;
      }

      else {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'id_token', value: result.idToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken);
        final expiresAt = DateTime.now().add(const Duration(seconds: 3600));
        await _secureStorage.write(key: 'access_token_expiration', value: expiresAt.toIso8601String());

        debugPrint('Successfully logged in');
        return true;
      }
    } 
    
    catch (e, stackTrace) {
      debugPrint('OAuth login failed: $e');
      print(stackTrace);
      rethrow; // Re-throw the exception for handling in login_screen.dart
    }
  }

  // Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    final expiration = await _secureStorage.read(key: 'access_token_expiration');

    if (expiration == null) {
      debugPrint('No access token expiration found');
      return true; 
    }

    final expirationTime = DateTime.tryParse(expiration);
    if (expirationTime == null) {
      debugPrint('Invalid access token expiration format');
      return true;
    }
    debugPrint('Access token expiration time: $expirationTime');
    return DateTime.now().isAfter(expirationTime);
  }


  Future<bool> _refreshToken() async {
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

      if (result != null && result.accessToken != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'id_token', value: result.idToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken ?? refreshToken);
        final newExpiresAt = DateTime.now().add(const Duration(seconds: 3600));
        await _secureStorage.write(key: 'access_token_expiration', value: newExpiresAt.toIso8601String());
        
        debugPrint('Access Token refreshed');
        return true;
      }
    } 
    
    catch (e, stackTrace) {
      debugPrint('Token refresh failed: $e');
      print(stackTrace);
    }
    return false;
  }

  // Creates new refresh token if access token is expired
  Future<bool> isFreshToken() async {
    final isExpired = await isAccessTokenExpired();
    if (isExpired) {
      debugPrint('Access token is expired, refreshing...');
      return await _refreshToken();
    }
    debugPrint('Access token is still valid');
    return true;
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
      debugPrint("User logged out and secure storage cleared.");
    }

    catch (e, stackTrace) {
      debugPrint('Logout failed: $e');
      print(stackTrace);
    }
  }

  // Manual simulation for testing token refresh flow
  Future<void> simulateRefreshFlow() async {
    final oldAccessToken = await _secureStorage.read(key: 'access_token');
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (oldAccessToken == null || refreshToken == null) {
      debugPrint("No token or refresh token found. Please login first.");
      return;
    }

    final success = await _refreshToken();

    if (success) {
      final newAccessToken = await _secureStorage.read(key: 'access_token');
      debugPrint(oldAccessToken != newAccessToken
          ? "Token was successfully refreshed."
          : "Token unchanged (server may have returned same token).");
    }
  }
}