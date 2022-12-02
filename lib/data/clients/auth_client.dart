import 'package:dd_app_ui/domain/models/token_request.dart';
import "package:dio/dio.dart";
import 'package:retrofit/retrofit.dart';

import '../../domain/models/token_response.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  @POST("/api/Auth/Token")
  Future<TokenResponse> getToken(@Body() TokenRequest body);
}
