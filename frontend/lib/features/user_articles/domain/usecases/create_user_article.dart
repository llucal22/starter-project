import '../../../../core/usecase/usecase.dart';
import '../../../../core/resources/data_state.dart';
import '../entities/user_article.dart';
import '../repository/user_article_repository.dart';

class CreateUserArticleUseCase
    implements UseCase<DataState<UserArticleEntity>, UserArticleEntity> {
  final UserArticleRepository repository;
  CreateUserArticleUseCase(this.repository);

  @override
  Future<DataState<UserArticleEntity>> call({UserArticleEntity? params}) {
    return repository.create(params!);
  }
}
