import 'dart:io';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dio/dio.dart';
import '../../domain/repository/api_repository.dart';
import '../../exceptions/nonetwork_exception.dart';
import '../../exceptions/wrong_credential_exception.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependecies/repository_model.dart';

class AuthService {
  final ApiRepository _api = RepositoryModule.apiRepository();
  final DataService _dataService = DataService();

  Future createUser(
      {required name,
      required email,
      required password,
      required retryPassword,
      required birthDate}) async {
    await _api.createUser(
      name: name,
      email: email,
      password: password,
      retryPassword: retryPassword,
      birthDate: birthDate,
    );
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

    if (await TokenStorage.getAccessToken() != null) {
      var user = await _api.getUser();

      if (user != null) {
        await SharedPrefs.setStoredUser(user);
        await _dataService.cuUser(user);
      }

      res = true;
    }

    return res;
  }

  Future logout() async {
    await TokenStorage.setStoredToken(null);
  }
}
