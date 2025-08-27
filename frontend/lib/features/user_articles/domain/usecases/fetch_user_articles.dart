import '../../../../core/usecase/usecase.dart';
import '../../../../core/resources/data_state.dart';
import '../entities/user_article.dart';
import '../repository/user_article_repository.dart';

class FetchUserArticlesUseCase
    implements UseCase<DataState<List<UserArticleEntity>>, int?> {
  final UserArticleRepository repository;
  FetchUserArticlesUseCase(this.repository);

  @override
  Future<DataState<List<UserArticleEntity>>> call({int? params}) {
    return repository.fetchPublished(limit: params ?? 20);
  }
}
