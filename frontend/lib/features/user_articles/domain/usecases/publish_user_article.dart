import '../../../../core/usecase/usecase.dart';
import '../../../../core/resources/data_state.dart';
import '../repository/user_article_repository.dart';

class PublishUserArticleParams {
  final String id;
  final DateTime publishedAt;
  const PublishUserArticleParams({required this.id, required this.publishedAt});
}

class PublishUserArticleUseCase
    implements UseCase<DataState<void>, PublishUserArticleParams> {
  final UserArticleRepository repository;
  PublishUserArticleUseCase(this.repository);

  @override
  Future<DataState<void>> call({PublishUserArticleParams? params}) {
    return repository.publish(params!.id, params.publishedAt);
  }
}
