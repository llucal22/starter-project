import '../../../../core/usecase/usecase.dart';
import '../../../../core/resources/data_state.dart';
import '../repository/user_article_repository.dart';

class DeleteUserArticleUseCase
    implements UseCase<DataState<void>, String> {
  final UserArticleRepository repository;
  DeleteUserArticleUseCase(this.repository);

  @override
  Future<DataState<void>> call({String? params}) {
    return repository.delete(params!);
  }
}
