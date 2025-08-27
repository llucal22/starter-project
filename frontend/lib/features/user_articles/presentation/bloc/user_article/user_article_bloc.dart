import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_article_event.dart';
import 'user_article_state.dart';
import '../../../domain/usecases/fetch_user_articles.dart';
import '../../../domain/entities/user_article.dart';
import '../../../../../core/resources/data_state.dart';

class UserArticleBloc extends Bloc<UserArticleEvent, UserArticleState> {
  final FetchUserArticlesUseCase fetchUseCase;

  UserArticleBloc({required this.fetchUseCase}) : super(UserArticleInitial()) {
    on<UserArticleFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
      UserArticleFetchRequested event,
      Emitter<UserArticleState> emit,
      ) async {
    emit(UserArticleLoading());
    final result = await fetchUseCase(params: event.limit);

    if (result is DataSuccess<List<UserArticleEntity>>) {
      final data = result.data ?? const [];
      if (data.isEmpty) {
        emit(UserArticleEmpty());
      } else {
        emit(UserArticleLoaded(data));
      }
    } else if (result is DataFailed) {
      emit(UserArticleError(result.error?.toString() ?? 'Unknown error'));
    } else {
      emit(const UserArticleError('Unexpected state'));
    }
  }
}
