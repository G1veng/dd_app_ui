import 'package:dd_app_ui/data/clients/api_client.dart';
import 'package:dd_app_ui/data/clients/auth_client.dart';
import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/data/services/database.dart';
import 'package:dd_app_ui/domain/models/refresh_token_request_model.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';

class ApiModule {
  static AuthClient? _authClient;
  static ApiClient? _apiClient;

  static AuthClient auth() =>
      _authClient ??
      AuthClient(
        Dio(),
        baseUrl: baseUrl,
      );

  static ApiClient api() =>
      _apiClient ??
      ApiClient(
        _addIntercepters(Dio()),
        baseUrl: baseUrl,
      );

  static Dio _addIntercepters(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        options.headers.addAll({"Authorization": "Bearer $token"});
        return handler.next(options);
      },
      onResponse: (e, handler) async {
        await SharedPrefs.setConnectionState(true);
        return handler.next(e);
      },
      onError: (e, handler) async {
        if (e.type == DioErrorType.connectTimeout) {
          await SharedPrefs.setConnectionState(null);
          return handler.resolve(
              Response(statusCode: 400, requestOptions: e.requestOptions));
        }
        if (e.response?.statusCode == 401) {
          // ignore: deprecated_member_use
          dio.lock();
          RequestOptions options = e.response!.requestOptions;

          var rt = await TokenStorage.getRefreshToken();
          try {
            if (rt != null) {
              var token = await auth()
                  .getRefreshToken(RefreshTokenRequestModel(refreshToken: rt));
              await TokenStorage.setStoredToken(token);
              options.headers["Authorization"] = "Bearer ${token!.accessToken}";
            } else {
              //var service = AuthService();
              //await service.logout();
              await AppNavigator.toAuth();
              return handler
                  .resolve(Response(statusCode: 400, requestOptions: options));
            }
          } catch (e) {
            var service = AuthService();
            //await service.logout();
            await DB.instance.deleteDB();
            await service.cleanToken();
            AppNavigator.toLoader();
            return handler
                .resolve(Response(statusCode: 400, requestOptions: options));
          } finally {
            // ignore: deprecated_member_use
            dio.unlock();
          }

          return handler.resolve(await dio.fetch(options));
        } else {
          return handler.next(e);
        }
      },
    ));

    return dio;
  }
}
