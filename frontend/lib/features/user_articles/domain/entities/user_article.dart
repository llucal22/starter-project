import 'package:equatable/equatable.dart';

class UserArticleEntity extends Equatable {
  final String? id;
  final String? author;
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? urlToImage;
  final String? thumbnailPath;
  final String? thumbnailString;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final List<String>? tags;
  final String? language;
  final int? readingTime;
  final String? sourceName;
  final String? slug;

  const UserArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.content,
    this.url,
    this.urlToImage,
    this.thumbnailPath,
    this.thumbnailString,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.tags,
    this.language,
    this.readingTime,
    this.sourceName,
    this.slug,
  });

  @override
  List<Object?> get props => [
    id, author, title, description, content, url, urlToImage,
    thumbnailPath, thumbnailString,
    publishedAt, createdAt, updatedAt, status,
    tags, language, readingTime, sourceName, slug,
  ];
}
