import 'package:dio/dio.dart';
import '../../domain/repository/user_article_repository.dart';
import '../../domain/entities/user_article.dart';
import '../../../../core/resources/data_state.dart';
import '../data_sources/firestore_user_article_data_source.dart';
import '../models/user_article_model.dart';

class UserArticleRepositoryImpl implements UserArticleRepository {
  final FirestoreUserArticleDataSource ds;
  UserArticleRepositoryImpl(this.ds);

  // Helper para envolver cualquier error en DioError
  DioError _asDioError(Object e) {
    if (e is DioError) return e;
    return DioError(
      requestOptions: RequestOptions(path: '/firestore/user_articles'),
      error: e,
      type: DioErrorType.unknown,
    );
  }

  @override
  Future<DataState<List<UserArticleEntity>>> fetchPublished({int limit = 20}) async {
    try {
      final list = await ds.fetchPublished(limit: limit);
      return DataSuccess<List<UserArticleEntity>>(list);
    } catch (e) {
      return DataFailed<List<UserArticleEntity>>(_asDioError(e));
    }
  }

  @override
  Future<DataState<UserArticleEntity>> create(UserArticleEntity a) async {
    try {
      // crea un modelo a partir de la entity (añade un fromEntity si no lo tienes)
      final created = await ds.create(UserArticleModel(
        author: a.author,
        title: a.title,
        description: a.description,
        content: a.content,
        url: a.url,
        urlToImage: a.urlToImage,
        thumbnailPath: a.thumbnailPath,
        status: a.status ?? 'draft',
        tags: a.tags,
        language: a.language,
        readingTime: a.readingTime,
        sourceName: a.sourceName,
        slug: a.slug,
      ));
      return DataSuccess<UserArticleEntity>(created);
    } catch (e) {
      return DataFailed<UserArticleEntity>(_asDioError(e));
    }
  }

  @override
  Future<DataState<void>> update(UserArticleEntity a) async {
    try {
      await ds.update(UserArticleModel(
        id: a.id,
        author: a.author,
        title: a.title,
        description: a.description,
        content: a.content,
        url: a.url,
        urlToImage: a.urlToImage,
        thumbnailPath: a.thumbnailPath,
        publishedAt: a.publishedAt,
        status: a.status,
        tags: a.tags,
        language: a.language,
        readingTime: a.readingTime,
        sourceName: a.sourceName,
        slug: a.slug,
      ));
      return const DataSuccess<void>(null);
    } catch (e) {
      return DataFailed<void>(_asDioError(e));
    }
  }

  @override
  Future<DataState<void>> publish(String id, DateTime publishedAt) async {
    try {
      await ds.publish(id, publishedAt);
      return const DataSuccess<void>(null);
    } catch (e) {
      return DataFailed<void>(_asDioError(e));
    }
  }

  @override
  Future<DataState<void>> delete(String id) async {
    try {
      await ds.delete(id);
      return const DataSuccess<void>(null);
    } catch (e) {
      return DataFailed<void>(_asDioError(e));
    }
  }
}
