import '../entities/user_article.dart';
import '../../../../core/resources/data_state.dart';

abstract class UserArticleRepository {
  Future<DataState<List<UserArticleEntity>>> fetchPublished({int limit = 20});
  Future<DataState<UserArticleEntity>> create(UserArticleEntity article);
  Future<DataState<void>> update(UserArticleEntity article);
  Future<DataState<void>> publish(String id, DateTime publishedAt);
  Future<DataState<void>> delete(String id);
}
