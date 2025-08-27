import 'package:equatable/equatable.dart';

abstract class UserArticleEvent extends Equatable {
  const UserArticleEvent();
  @override
  List<Object?> get props => [];
}

class UserArticleFetchRequested extends UserArticleEvent {
  final int limit;
  const UserArticleFetchRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}
