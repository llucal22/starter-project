import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_article.dart';

DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate()
    : (v is String ? DateTime.tryParse(v) : null);

class UserArticleModel extends UserArticleEntity {
  const UserArticleModel({
    String? id,
    String? author,
    String? title,
    String? description,
    String? content,
    String? url,
    String? urlToImage,
    String? thumbnailPath,
    String? thumbnailString,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? tags,
    String? language,
    int? readingTime,
    String? sourceName,
    String? slug,
  }) : super(
    id: id,
    author: author,
    title: title,
    description: description,
    content: content,
    url: url,
    urlToImage: urlToImage,
    thumbnailPath: thumbnailPath,
    thumbnailString: thumbnailString,
    publishedAt: publishedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    status: status,
    tags: tags,
    language: language,
    readingTime: readingTime,
    sourceName: sourceName,
    slug: slug,
  );

  factory UserArticleModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? {};
    return UserArticleModel(
      id: d.id,
      author: j['author'],
      title: j['title'],
      description: j['description'],
      content: j['content'],
      url: j['url'],
      urlToImage: j['urlToImage'],
      thumbnailPath: j['thumbnailPath'],
      thumbnailString: j['thumbnailString'] ?? '',
      publishedAt: _ts(j['publishedAt']),
      createdAt: _ts(j['createdAt']),
      updatedAt: _ts(j['updatedAt']),
      status: j['status'],
      tags: (j['tags'] as List?)?.map((e) => e.toString()).toList(),
      language: j['language'],
      readingTime: (j['readingTime'] as num?)?.toInt(),
      sourceName: j['sourceName'],
      slug: j['slug'],
    );
  }

  Map<String, dynamic> toJson() => {
    'author': author,
    'title': title,
    'description': description,
    'content': content,
    'url': url,
    'urlToImage': urlToImage,
    'thumbnailPath': thumbnailPath,
    'thumbnailString': thumbnailString ?? '',
    'publishedAt': publishedAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'status': status,
    'tags': tags,
    'language': language,
    'readingTime': readingTime,
    'sourceName': sourceName,
    'slug': slug,
  }..removeWhere((k, v) => v == null);
}

