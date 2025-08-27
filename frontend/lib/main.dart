import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'config/routes/routes.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/pages/home/daily_news.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/user_articles/presentation/pages/my_articles_page.dart';
import 'features/user_articles/presentation/pages/publish_article_page.dart';
import 'features/user_articles/presentation/pages/user_article_details_page.dart';
import 'features/user_articles/domain/entities/user_article.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (_) => sl<RemoteArticlesBloc>()
            ..add(const GetArticles()),
        ),
        BlocProvider<LocalArticleBloc>(
          create: (_) => sl<LocalArticleBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        theme: theme(),

        initialRoute: '/',

        routes: {
          '/': (_) => const DailyNews(),
          '/MyArticles': (_) => const MyArticlesPage(),
          '/PublishArticle': (_) => const PublishArticlePage(),
        },

        onGenerateRoute: (settings) {
          if (settings.name == '/MyArticleDetails') {
            final art = settings.arguments as UserArticleEntity;
            return MaterialPageRoute(
              builder: (_) => UserArticleDetailsPage(article: art),
            );
          }
          return AppRoutes.onGenerateRoutes(settings);
        },

        onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const DailyNews()),
      ),
    );
  }
}
