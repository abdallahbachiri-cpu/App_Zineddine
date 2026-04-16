import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/errors/exceptions.dart';
import '../core/errors/failures.dart';
import '../core/mixins/error_handling_mixin.dart';
import '../core/ui/auth_status.dart';
import '../core/ui/view_state.dart';

import 'dart:developer' as devtools;

import '../data/models/user_model.dart';
import '../services/app_service.dart';

class AuthProvider with ChangeNotifier, ErrorHandlingMixin {
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _storage;
  final ApiClient _apiClient;

  AuthProvider({
    required GoogleSignIn googleSignIn,
    required SecureStorageService storage,
    required ApiClient apiClient,
  }) : _googleSignIn = googleSignIn,
       _storage = storage,
       _apiClient = apiClient {
    _apiClient.onTokenExpired = logout;
  }

  SettingsProvider? get settings => getIt<SettingsProvider>();

  User? _user;
  String? _token;
  String? _type;
  ViewState _viewState = ViewState.initial;
  AuthStatus _authStatus = AuthStatus.unknown;

  bool _hasAcceptedSellerTerms = false;

  User? get user => _user;
  String? get type => _type;
  bool get hasAcceptedSellerTerms => _hasAcceptedSellerTerms;
  ViewState get viewState => _viewState;
  AuthStatus get authStatus => _authStatus;
  bool get isLoading => _viewState == ViewState.loading;
  AppService get appService => getIt<AppService>();
  String? tokenDevice;
  String? get fcmToken => tokenDevice;

  Future<void> initialize() async {
    try {
      tokenDevice = await appService.getDeviceToken();
      _token = await _storage.getAccessToken();
      _type = await _storage.getType();
      if (_token != null) {
        await fetchUserProfile();
        _authStatus = AuthStatus.authenticated;
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      devtools.log(
        '[AuthProvider] Initialize error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      await _storage.clearTokens();
      _token = null;
      _user = null;
      _type = null;
      _authStatus = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    devtools.log('[GoogleSignIn] Starting Google sign-in flow');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final (account, googleAuth) = await _handleGoogleSignIn();
      try {
        await _performAuthRequest(
          endpoint: ApiEndpoints.authLogin,
          expectedStatusCode: 200,
          googleToken: googleAuth.accessToken!,
          account: account,
        );
      } on ApiException catch (e, stackTrace) {
        devtools.log(
          '[GoogleSignIn] Login attempt failed: ${e.message}',
          error: e,
          stackTrace: stackTrace,
        );

        if (e.statusCode == 401) {
          devtools.log('[GoogleSignIn] Attempting registration');
          if (settings?.settings == null) {
            await settings?.loadSettings();
          }

          settings!.markAsCompletedRegister(false);

          await _performAuthRequest(
            endpoint: ApiEndpoints.authRegister,
            expectedStatusCode: 200,
            googleToken: googleAuth.accessToken!,
            account: account,
          );
        } else {
          handleError(e, stackTrace);
          _viewState = ViewState.error;
          notifyListeners();
          return;
        }
      }
      _viewState = ViewState.success;
      _authStatus = AuthStatus.authenticated;
    } catch (e, stackTrace) {
      devtools.log(
        '[GoogleSignIn] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _viewState = ViewState.error;
      error = 'Unable to authenticate with Google. Please try again.';
      rethrow;
    } finally {
      devtools.log('[GoogleSignIn] Notifying listeners. User: $_user');
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    devtools.log('[AppleSignIn] Starting Apple sign-in flow');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw ApiException(403, 'Apple Sign-In failed: no identity token');
      }

      if (settings?.settings == null) {
        await settings?.loadSettings();
      }
      settings!.markAsGoogleAuthUser();

      final firstName =
          credential.givenName?.isNotEmpty == true
              ? credential.givenName!
              : 'Apple';
      final lastName =
          credential.familyName?.isNotEmpty == true
              ? credential.familyName!
              : 'User';
      final email = credential.email ?? '';

      try {
        await _performAppleAuthRequest(
          endpoint: ApiEndpoints.authLogin,
          identityToken: identityToken,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
      } on ApiException catch (e, stackTrace) {
        devtools.log(
          '[AppleSignIn] Login attempt failed: ${e.message}',
          error: e,
          stackTrace: stackTrace,
        );

        if (e.statusCode == 401) {
          devtools.log('[AppleSignIn] Attempting registration');
          settings!.markAsCompletedRegister(false);

          await _performAppleAuthRequest(
            endpoint: ApiEndpoints.authRegister,
            identityToken: identityToken,
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
        } else {
          handleError(e, stackTrace);
          _viewState = ViewState.error;
          notifyListeners();
          return;
        }
      }

      _viewState = ViewState.success;
      _authStatus = AuthStatus.authenticated;
    } catch (e, stackTrace) {
      devtools.log('[AppleSignIn] Error: $e', error: e, stackTrace: stackTrace);
      _viewState = ViewState.error;
      error = 'Unable to authenticate with Apple. Please try again.';
      rethrow;
    } finally {
      devtools.log('[AppleSignIn] Notifying listeners. User: $_user');
      notifyListeners();
    }
  }

  Future<void> _performAppleAuthRequest({
    required String endpoint,
    required String identityToken,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    devtools.log('[AppleAuthRequest] Starting $endpoint');
    try {
      final response = await _apiClient.post(
        endpoint,
        body: {
          'fcm_token': tokenDevice,
          'appleToken': identityToken,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'local': settings?.currentLanguage,
          'rememberMe': true,
        },
        isPrivate: false,
      );

      devtools.log(
        '[AppleAuthRequest] $endpoint response: ${response.statusCode}',
      );

      final data = response.data as Map<String, dynamic>;
      _validateAuthResponse(data);

      await _storage.saveJwtTokens(
        accessToken: data['accessToken']!.toString(),
        refreshToken: data['refreshToken']!.toString(),
        userType: data['user']['type']?.toString(),
      );
      _type = data['user']['type']?.toString();
      _token = data['accessToken']?.toString();

      _user = User.fromRemoteMap(data['user']);

      if (_user != null) {
        _hasAcceptedSellerTerms = await _storage.hasAcceptedSellerTerms(
          _user!.id,
        );
        await appService.setUserId(_user!.id);
      }

      devtools.log('[AppleAuthRequest] User parsed successfully: $_user');
    } catch (e, stackTrace) {
      devtools.log(
        '[AppleAuthRequest] $endpoint failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<(GoogleSignInAccount, GoogleSignInAuthentication)>
  _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        devtools.log('[GoogleSignIn] User canceled sign-in');
        throw ApiException(403, 'Google Sign-In canceled');
      }

      final googleAuth = await account.authentication;
      if (googleAuth.accessToken == null) {
        devtools.log('[GoogleSignIn] No access token received');
        throw ApiException(403, 'Google Sign-In failed: no access token');
      }
      devtools.log('[GoogleSignIn] Sign-in successful');

      if (settings?.settings == null) {
        await settings?.loadSettings();
      }

      settings!.markAsGoogleAuthUser();

      return (account, googleAuth);
    } catch (e, stackTrace) {
      devtools.log(
        '[GoogleSignIn] Authentication error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _performAuthRequest({
    required String endpoint,
    required int expectedStatusCode,
    required String googleToken,
    required GoogleSignInAccount account,
  }) async {
    devtools.log('[AuthRequest] Starting $endpoint $googleToken');
    try {
      final response = await _apiClient.post(
        endpoint,
        body: {
          'fcm_token': tokenDevice,
          'googleToken': googleToken,
          'local': settings?.currentLanguage,
          'rememberMe': true,
        },
        isPrivate: false,
      );

      devtools.log('[AuthRequest] $endpoint response: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;
      _validateAuthResponse(data);

      await _storage.saveJwtTokens(
        accessToken: data['accessToken']!.toString(),
        refreshToken: data['refreshToken']!.toString(),
        userType: data['user']['type']?.toString(),
      );
      _type = data['user']['type']?.toString();
      _token = data['accessToken']?.toString();

      _user = User.fromRemoteMap(
        data['user'],
      ).copyWith(oAuthAccessToken: googleToken, oAuthId: account.id);

      if (_user != null) {
        _hasAcceptedSellerTerms = await _storage.hasAcceptedSellerTerms(
          _user!.id,
        );
        await appService.setUserId(_user!.id);
      }

      devtools.log('[AuthRequest] User parsed successfully: $_user');
    } catch (e, stackTrace) {
      devtools.log(
        '[AuthRequest] $endpoint failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _validateAuthResponse(Map<String, dynamic> data) {
    final missingKeys = [
      if (data['accessToken'] == null) 'accessToken',
      if (data['refreshToken'] == null) 'refreshToken',
      if (data['user'] == null) 'user',
    ];

    if (missingKeys.isNotEmpty) {
      throw const FormatException('Invalid authentication response structure');
    }
  }

  Future<void> login(String email, String password) async {
    devtools.log('[EmailAuth] Starting login for $email');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        body: {
          'email': email,
          'password': password,
          'rememberMe': true,
          "fcm_token": tokenDevice,
        },
        isPrivate: false,
      );
      devtools.log(
        '[EmailAuth] Response received. Status: ${response.statusCode}',
      );
      await _handleAuthResponse(response);
      _viewState = ViewState.success;
      _authStatus = AuthStatus.authenticated;
      devtools.log("*********************************************");
      devtools.log("user id: ${_user!.id}");
      final storedId = await appService.getUserId();
      devtools.log(
        '[EmailAuth] User ID retrieved from SharedPreferences: $storedId',
      );

      devtools.log('[EmailAuth] Login successful for $email. User: $_user');
    } catch (e, stackTrace) {
      devtools.log('[EmailAuth] Login failed: $e');
      _viewState = ViewState.error;
      _authStatus = AuthStatus.unauthenticated;
      handleError(e, stackTrace, fallbackMessage: 'Invalid email or password');
    }
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    devtools.log('[Registration] Starting registration for $email');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'locale': settings?.currentLanguage,
          'fcm_token': tokenDevice,
        },
        isPrivate: false,
      );
      await _handleAuthResponse(response);
      _viewState = ViewState.success;
      _authStatus = AuthStatus.authenticated;
      devtools.log('[Registration] Successful registration for $email');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Registration failed. Please try again.',
      );
    }
    notifyListeners();
  }

  Future<void> _handleAuthResponse(Response response) async {
    devtools.log(
      '[AuthResponse] Handling response code ${response.statusCode}',
    );

    final data = response.data as Map<String, dynamic>;
    _validateAuthResponse(data);

    await _storage.saveJwtTokens(
      accessToken: data['accessToken']!.toString(),
      refreshToken: data['refreshToken']!.toString(),
      userType: data['user']['type']?.toString(),
    );

    _user = User.fromRemoteMap(data['user']);
    _type = data['user']['type']?.toString();

    if (_user != null) {
      _hasAcceptedSellerTerms = await _storage.hasAcceptedSellerTerms(
        _user!.id,
      );
      await appService.setUserId(_user!.id);
    }

    clearError();
    devtools.log('[AuthResponse] User set: $_user');
  }

  Future<void> fetchUserProfile() async {
    devtools.log('[UserProfile] Fetching user profile');
    try {
      final response = await _apiClient.get(ApiEndpoints.user);
      final data = response.data as Map<String, dynamic>;
      _user = User.fromRemoteMap(data);

      if (_user != null && _user!.type != null) {
        await _storage.saveUserType(_user!.type!);
        _type = _user!.type!;
        devtools.log('[UserProfile] User type updated to: $_type');
      }

      if (_user != null) {
        _hasAcceptedSellerTerms = await _storage.hasAcceptedSellerTerms(
          _user!.id,
        );
      }

      devtools.log('[UserProfile] Profile fetched successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch user profile',
      );
      await logout();
    }
  }

  Future<void> updateUserType(
    String? type,
    String? phoneNumber,
    String? email,
    String? firstName,
    String? lastName,
    String? middleName,
  ) async {
    devtools.log(
      "[UserUpdate] type $type phoneNumber $phoneNumber email $email firstName $firstName lastName $lastName middleName $middleName",
    );
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.user,
        body: {
          if (phoneNumber != null) "phoneNumber": phoneNumber,
          if (firstName != null) "firstName": firstName,
          if (lastName != null) "lastName": lastName,
          if (middleName != null) "middleName": middleName,
          if (type != null) "type": type,
        },
      );

      final data = response.data as Map<String, dynamic>;
      _user = User.fromRemoteMap(data);

      if (_user != null && _user!.type != null) {
        await _storage.saveUserType(_user!.type!);
        _type = type;
      } else {
        await fetchUserProfile();
      }

      devtools.log('[UserType] Updated successfully');
      clearError();
      notifyListeners();
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to update account type',
      );
    }
  }

  Future<void> emailConfirmationAsync(String email, String pin) async {
    devtools.log('[EmailConfirmation] $email $pin');
    try {
      await _apiClient.post(
        ApiEndpoints.userEmailConfirmationVerify,
        body: {"email": email, "token": pin},
      );

      await fetchUserProfile();
      devtools.log('[EmailConfirmation] Confirmed successfully');
      notifyListeners();
    } on ApiFailure catch (e) {
      error = e.message;
      notifyListeners();
    } catch (e, stackTrace) {
      devtools.log(
        '[EmailConfirmation] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      error = 'Failed to confirm email';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    devtools.log('[Logout] Initiating logout');
    try {
      await _googleSignIn.signOut();
      await _storage.clearTokens();
      await _storage.clearUserType();
      await _apiClient.clearJwtToken();
      await appService.clearUserId();
      _token = null;
      _type = null;
      _user = null;
      _authStatus = AuthStatus.unauthenticated;
      _viewState = ViewState.initial;
      _hasAcceptedSellerTerms = false;
      devtools.log('[Logout] Completed successfully');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to logout');
    }
    notifyListeners();
  }

  void updateUserData(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> resendEmailConfirmationCode(String email) async {
    devtools.log('[ResendEmailConfirmation] $email');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      await _apiClient.post(
        ApiEndpoints.userEmailConfirmationSend,
        body: {"email": email},
      );
      _viewState = ViewState.success;
      devtools.log('[ResendEmailConfirmation] Code sent successfully');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to send confirmation code',
      );
    }
    notifyListeners();
  }

  Future<void> requestPasswordReset(String email) async {
    devtools.log('[PasswordReset] Requesting password reset for $email');
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      await _apiClient.post(
        ApiEndpoints.userPasswordResetRequest,
        body: {"email": email},
        isPrivate: false,
      );
      _viewState = ViewState.success;
      devtools.log('[PasswordReset] Reset request sent successfully');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to send password reset request',
      );
    }
    notifyListeners();
  }

  Future<void> validateUserTypeConsistency() async {
    if (_user != null && _user!.type != null) {
      final storedType = await _storage.getType();
      if (storedType != _user!.type) {
        devtools.log(
          '[AuthProvider] User type mismatch detected. Stored: $storedType, User: ${_user!.type}',
        );
        await _storage.saveUserType(_user!.type!);
        _type = _user!.type!;
        notifyListeners();
      }
    }
  }

  String? get currentUserType => _user?.type ?? _type;

  Future<void> acceptSellerTerms() async {
    if (_user == null) return;
    await _storage.markSellerTermsAccepted(_user!.id);
    _hasAcceptedSellerTerms = true;
    notifyListeners();
  }
}
