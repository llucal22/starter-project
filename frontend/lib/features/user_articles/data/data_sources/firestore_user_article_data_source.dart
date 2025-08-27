import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_article_model.dart';

abstract class FirestoreUserArticleDataSource {
  Future<List<UserArticleModel>> fetchPublished({int limit = 20});
  Future<UserArticleModel> create(UserArticleModel article);
  Future<void> update(UserArticleModel article);
  Future<void> publish(String id, DateTime publishedAt);
  Future<void> delete(String id);
}

class FirestoreUserArticleDataSourceImpl implements FirestoreUserArticleDataSource {
  final FirebaseFirestore db;
  FirestoreUserArticleDataSourceImpl(this.db);

  CollectionReference<Map<String, dynamic>> get col => db.collection('articles');

  @override
  Future<List<UserArticleModel>> fetchPublished({int limit = 20}) async {
    final q = await col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return q.docs.map(UserArticleModel.fromDoc).toList();
  }

  @override
  Future<UserArticleModel> create(UserArticleModel article) async {
    final ref = await col.add({
      ...article.toJson(),
      'thumbnailString': (article.thumbnailString ?? ''),
      'status': article.status ?? 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snap = await ref.get();
    return UserArticleModel.fromDoc(snap);
  }


  @override
  Future<void> update(UserArticleModel article) async {
    await col.doc(article.id).update({
      ...article.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> publish(String id, DateTime publishedAt) async {
    await col.doc(id).update({
      'status': 'published',
      'publishedAt': Timestamp.fromDate(publishedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String id) => col.doc(id).delete();
}
