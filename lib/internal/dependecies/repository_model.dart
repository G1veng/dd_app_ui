import '../../data/repository/api_data_repository.dart';
import '../../domain/repository/api_repository.dart';
import 'api_modile.dart';

class RepositoryModule {
  static ApiRepository? _apiRepository;
  static ApiRepository apiRepository() {
    return _apiRepository ??
        ApiDataRepository(
          ApiModule.auth(),
        );
  }
}
