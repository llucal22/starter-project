import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import '../bloc/user_article/user_article_bloc.dart';
import '../bloc/user_article/user_article_event.dart';
import '../bloc/user_article/user_article_state.dart';
import '../widgets/user_article_tile.dart';

class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserArticleBloc>()..add(const UserArticleFetchRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis artículos')),
        body: BlocBuilder<UserArticleBloc, UserArticleState>(
          builder: (context, state) {
            if (state is UserArticleInitial || state is UserArticleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserArticleError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is UserArticleEmpty) {
              return const Center(child: Text('No hay artículos publicados todavía.'));
            }
            if (state is UserArticleLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final art = state.articles[i];
                  return UserArticleTile(
                    article: art,
                    onTap: () async {
                      final removed = await Navigator.pushNamed(
                        context,
                        '/MyArticleDetails',
                        arguments: art,
                      );
                      if (removed == true && context.mounted) {
                        context.read<UserArticleBloc>().add(const UserArticleFetchRequested());
                      }
                    },

                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
