import '../../domain/models/token_request.dart';
import '../../domain/models/token_response.dart';
import '../../domain/repository/api_repository.dart';
import '../clients/auth_client.dart';

class ApiDataRepository extends ApiRepository {
  final AuthClient _auth;
  ApiDataRepository(this._auth);

  @override
  Future<TokenResponse?> getToken({
    required String login,
    required String password,
  }) async {
    return await _auth.getToken(TokenRequest(
      login: login,
      password: password,
    ));
  }
}
