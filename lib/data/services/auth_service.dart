import 'dart:io';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/exceptions/user_exists_excetion.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';
import 'package:dio/dio.dart';
import '../../domain/repository/api_repository.dart';
import '../../domain/exceptions/nonetwork_exception.dart';
import '../../domain/exceptions/wrong_credential_exception.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependecies/repository_model.dart';

class AuthService {
  final ApiRepository _api = RepositoryModule.apiRepository();
  final DataService _dataService = DataService();

  Future createUser({
    required name,
    required email,
    required password,
    required retryPassword,
    required birthDate,
    required created,
    required id,
  }) async {
    try {
      await _api.createUser(
        name: name,
        email: email,
        password: password,
        retryPassword: retryPassword,
        birthDate: birthDate,
        created: created,
        id: id,
      );
    } on DioError catch (e) {
      if (<int>[403].contains(e.response?.statusCode)) {
        throw UserExistsException();
      }
    }
  }

  Future auth(String? login, String? password) async {
    if (login != null && password != null) {
      try {
        var token = await _api.getToken(
          login: login,
          password: password,
        );
        if (token != null) {
          await TokenStorage.setStoredToken(
            token,
          );
          var user = await _api.getUser();
          if (user != null) {
            SharedPrefs.setStoredUser(
              user,
            );
          }
        }
      } on DioError catch (e) {
        if (e.error is SocketException) {
          throw NoNetworkException();
        } else if (<int>[404].contains(e.response?.statusCode)) {
          throw WrongCredentionalException();
        }
      }
    }
  }

  Future<bool> checkAuth() async {
    var res = false;
    User? user;

    if (await TokenStorage.getAccessToken() != null) {
      try {
        user = await _api.getUser();
      } on DioError {
        await SharedPrefs.setStoredUser(null);
        await AuthService().cleanToken();
        AppNavigator.toLoader();
      }

      if (user != null) {
        await SharedPrefs.setStoredUser(user);
        await _dataService.cuUser(user);
      }

      res = true;
    }

    return res;
  }

  Future cleanToken() async {
    await TokenStorage.setStoredToken(null);
  }
}
