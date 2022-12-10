import 'package:dd_app_ui/domain/models/create_user_request_model.dart';
import 'package:dd_app_ui/domain/models/refresh_token_request_model.dart';
import 'package:dd_app_ui/domain/models/token_request_model.dart';
import "package:dio/dio.dart";
import 'package:retrofit/retrofit.dart';

import '../../domain/models/token_response_model.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(
    Dio dio, {
    String? baseUrl,
  }) = _AuthClient;

  @POST("/api/Auth/Token")
  Future<TokenResponseModel?> getToken(
    @Body() TokenRequestModel body,
  );

  @POST("/api/Auth/RefreshToken")
  Future<TokenResponseModel?> getRefreshToken(
    @Body() RefreshTokenRequestModel body,
  );

  @POST("/api/User/CreateUser")
  Future createUser(@Body() CreateUserRequestModel body);
}
