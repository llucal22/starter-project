import '../../../../core/usecase/usecase.dart';
import '../../../../core/resources/data_state.dart';
import '../entities/user_article.dart';
import '../repository/user_article_repository.dart';

class UpdateUserArticleUseCase
    implements UseCase<DataState<void>, UserArticleEntity> {
  final UserArticleRepository repository;
  UpdateUserArticleUseCase(this.repository);

  @override
  Future<DataState<void>> call({UserArticleEntity? params}) {
    return repository.update(params!);
  }
}
