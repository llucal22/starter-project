import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/user_article.dart';

class UserArticleTile extends StatelessWidget {
  final UserArticleEntity article;
  final VoidCallback? onTap;

  const UserArticleTile({
    super.key,
    required this.article,
    this.onTap,
  });

  Future<String?> _resolveImageUrl() async {

    final u = article.urlToImage;
    if (u != null && (u.startsWith('http://') || u.startsWith('https://'))) {
      return u;
    }

    final ts = article.thumbnailString ?? '';
    try {
      if (ts.startsWith('http://') || ts.startsWith('https://')) return ts;
      if (ts.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(ts);
        return await ref.getDownloadURL();
      }
      if (ts.isNotEmpty) {
        final ref = FirebaseStorage.instance
            .ref()
            .child(ts.startsWith('/') ? ts.substring(1) : ts);
        return await ref.getDownloadURL();
      }
    } catch (_) {}

    final p = article.thumbnailPath;
    if (p != null && p.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child(p.startsWith('/') ? p.substring(1) : p);
        return await ref.getDownloadURL();
      } catch (_) {}
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final title = (article.title ?? '').trim().isEmpty
        ? '(sin título)'
        : article.title!.trim();

    final subtitle = (article.description ?? '').trim().isNotEmpty
        ? article.description!.trim()
        : (article.content ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            FutureBuilder<String?>(
              future: _resolveImageUrl(),
              builder: (context, snap) {
                final url = snap.data;
                Widget child;
                if (snap.connectionState == ConnectionState.done && url != null) {
                  child = Image.network(url, width: 72, height: 72, fit: BoxFit.cover);
                } else {
                  child = Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined, size: 24),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
