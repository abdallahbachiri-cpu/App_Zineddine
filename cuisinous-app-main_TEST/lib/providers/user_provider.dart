import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../core/errors/exceptions.dart';
import '../core/mixins/error_handling_mixin.dart';
import '../core/ui/view_state.dart';
import '../data/models/user_model.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

class UserProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;

  UserProvider({
    required ApiClient apiClient,
    required AuthProvider authProvider,
  }) : _apiClient = apiClient,
       _authProvider = authProvider;

  ViewState _viewState = ViewState.initial;

  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;

  Future<void> getUserProfile() async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.user, isPrivate: true);
      _authProvider.updateUserData(User.fromRemoteMap(response.data));
      _viewState = ViewState.success;
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch user profile',
      );
    }
    notifyListeners();
  }

  Future<void> updateUserProfile(
    Map<String, dynamic> updateData, {
    File? profileImage,
  }) async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      if (_authProvider.type == null) {
        throw const ValidationException('User type not available');
      }

      var response = await _apiClient.patch(
        ApiEndpoints.userByType(_authProvider.type!),
        body: updateData,
        isPrivate: true,
      );
      if (profileImage != null) {
        final formData = FormData.fromMap({
          'profileImage': await MultipartFile.fromFile(
            profileImage.path,
            filename: 'pic_profile.jpg',
          ),
        });
        final picResponse = await _apiClient.postMultipart(
          ApiEndpoints.userProfileImage,
          formData,
          isPrivate: true,
        );
        response = picResponse;
      }

      _authProvider.updateUserData(User.fromRemoteMap(response.data));
      _viewState = ViewState.success;
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to update profile');
    }
    notifyListeners();
  }

  Future<void> deleteUserProfile() async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      if (_authProvider.type == null) {
        throw const ValidationException('User type not available');
      }
      await _apiClient.delete(
        ApiEndpoints.userByType(_authProvider.type!),
        isPrivate: true,
      );
      await _authProvider.logout();
      _viewState = ViewState.success;
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to delete account');
    }
    notifyListeners();
  }
}
