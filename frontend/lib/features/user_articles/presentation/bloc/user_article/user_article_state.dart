import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_article.dart';

abstract class UserArticleState extends Equatable {
  const UserArticleState();
  @override
  List<Object?> get props => [];
}

class UserArticleInitial extends UserArticleState {}

class UserArticleLoading extends UserArticleState {}

class UserArticleLoaded extends UserArticleState {
  final List<UserArticleEntity> articles;
  const UserArticleLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

class UserArticleEmpty extends UserArticleState {}

class UserArticleError extends UserArticleState {
  final String message;
  const UserArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
