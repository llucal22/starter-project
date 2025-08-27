// imports existentes
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

// 🔽 nuevos imports (añádelos cuando crees estos archivos)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/user_articles/data/data_sources/firestore_user_article_data_source.dart';
import 'features/user_articles/data/repository/user_article_repository_impl.dart';
import 'features/user_articles/domain/repository/user_article_repository.dart';
import 'features/user_articles/domain/usecases/fetch_user_articles.dart';
// (opcional, cuando los crees)
// import 'features/user_articles/domain/usecases/create_user_article.dart';
// import 'features/user_articles/domain/usecases/update_user_article.dart';
// import 'features/user_articles/domain/usecases/publish_user_article.dart';
// import 'features/user_articles/domain/usecases/delete_user_article.dart';
import 'features/user_articles/presentation/bloc/user_article/user_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --------------------------
  // Base de datos local (Floor)
  // --------------------------
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // ----
  // Dio
  // ----
  sl.registerSingleton<Dio>(Dio());

  // -----------------------
  // News API (flujo antiguo)
  // -----------------------
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()), // NewsApiService, AppDatabase
  );

  // UseCases (existentes)
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  // Blocs (existentes)
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<LocalArticleBloc>(() => LocalArticleBloc(sl(), sl(), sl()));

  // -----------------------------------
  // User Articles (nuevo flujo paralelo)
  // -----------------------------------

  // Core Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Source
  sl.registerLazySingleton<FirestoreUserArticleDataSource>(
        () => FirestoreUserArticleDataSourceImpl(sl()), // FirebaseFirestore
  );

  // Repository
  sl.registerLazySingleton<UserArticleRepository>(
        () => UserArticleRepositoryImpl(sl()), // FirestoreUserArticleDataSource
  );

  // Use Cases mínimos
  sl.registerFactory<FetchUserArticlesUseCase>(() => FetchUserArticlesUseCase(sl()));
  // (Registra los demás cuando los implementes)
  // sl.registerFactory<CreateUserArticleUseCase>(() => CreateUserArticleUseCase(sl()));
  // sl.registerFactory<UpdateUserArticleUseCase>(() => UpdateUserArticleUseCase(sl()));
  // sl.registerFactory<PublishUserArticleUseCase>(() => PublishUserArticleUseCase(sl()));
  // sl.registerFactory<DeleteUserArticleUseCase>(() => DeleteUserArticleUseCase(sl()));

  // Bloc de User Articles (listado de publicados)
  sl.registerFactory<UserArticleBloc>(() => UserArticleBloc(fetchUseCase: sl()));
}
