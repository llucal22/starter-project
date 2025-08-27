import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/user_article.dart';

import 'package:news_app_clean_architecture/injection_container.dart';
import '../../domain/repository/user_article_repository.dart';
import '../../../../core/resources/data_state.dart';

class UserArticleDetailsPage extends StatelessWidget {
  final UserArticleEntity article;
  const UserArticleDetailsPage({super.key, required this.article});


  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final t = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  String _plainTextFromHtml(String html) {
    var s = html;
    RegExp _ci(String p) => RegExp(p, caseSensitive: false, dotAll: true);
    s = s.replaceAll('\r\n', '\n');
    s = s.replaceAll(_ci(r'<br\s*/?>'), '\n');
    s = s.replaceAll(_ci(r'</p>'), '\n\n');
    s = s.replaceAll(_ci(r'<p[^>]*>'), '');
    s = s.replaceAll(_ci(r'</ul>'), '\n');
    s = s.replaceAll(_ci(r'<ul[^>]*>'), '');
    s = s.replaceAll(_ci(r'<li[^>]*>'), '• ');
    s = s.replaceAll(_ci(r'</li>'), '\n');
    s = s.replaceAll(_ci(r'</?(strong|b|em|i|u|span|div|h[1-6])[^>]*>'), '');
    s = s.replaceAll(RegExp(r'<[^>]+>', dotAll: true), '');
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    s = s.replaceAll(RegExp(r'\n{3,}', dotAll: true), '\n\n');
    return s.trim();
  }

  Future<String?> _resolveImageUrl(UserArticleEntity a) async {
    final u = a.urlToImage;
    if (u != null && u.startsWith('http')) return u;
    final p = a.thumbnailPath;
    if (p != null && p.startsWith('/')) {
      try {
        final ref = FirebaseStorage.instance.ref().child(p.substring(1));
        return await ref.getDownloadURL();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (article.id == null) return;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Seguro que quieres eliminar este artículo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = sl<UserArticleRepository>();
    final res = await repo.delete(article.id!);

    Navigator.of(context).pop();

    if (res is DataFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: ${res.error}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Artículo eliminado')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final a = article;
    final contentPlain = _plainTextFromHtml(a.content ?? '');
    final description = (a.description ?? '').trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi artículo')),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _confirmAndDelete(context),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Eliminar artículo'),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            a.title ?? '(sin título)',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: -8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _fmtDate(a.publishedAt ?? a.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (a.readingTime != null)
                Text('${a.readingTime} min read',
                    style: Theme.of(context).textTheme.bodySmall),
              if ((a.language ?? '').isNotEmpty)
                Text((a.language ?? '').toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String?>(
            future: _resolveImageUrl(a),
            builder: (context, snap) {
              final url = snap.data;
              if (snap.connectionState == ConnectionState.waiting) {
                return const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (url == null) return const SizedBox(height: 8);
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
          ],
          if (contentPlain.isNotEmpty)
            Text(
              contentPlain,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.35),
            ),
          const SizedBox(height: 16),
          if ((a.author ?? '').isNotEmpty || (a.sourceName ?? '').isNotEmpty)
            Text(
              [
                if ((a.author ?? '').isNotEmpty) 'by ${a.author}',
                if ((a.sourceName ?? '').isNotEmpty) '(${a.sourceName})',
              ].join(' '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if ((a.tags ?? []).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: [for (final t in a.tags!) Chip(label: Text(t))],
            ),
          ],
        ],
      ),
    );
  }
}
