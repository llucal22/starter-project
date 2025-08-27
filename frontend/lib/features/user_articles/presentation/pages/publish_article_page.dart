import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../domain/entities/user_article.dart';
import '../../domain/repository/user_article_repository.dart';
import '../../../../core/resources/data_state.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({super.key});

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  // Controllers
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _authorCtrl = TextEditingController(text: 'Anonymous');
  final _sourceCtrl = TextEditingController(text: 'User');
  final _tagCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Image
  XFile? _pickedImage;
  final _picker = ImagePicker();

  // Meta
  String? _language = 'es';
  int _readingTime = 1;
  bool _readingTimeEdited = false; // si el usuario tocó el stepper
  final List<String> _tags = [];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Recalcular lectura cada vez que cambie el contenido (si no lo editó a mano)
    _contentCtrl.addListener(() {
      if (_readingTimeEdited) return;
      final est = _estimateReadingTime(_contentCtrl.text);
      if (est != _readingTime) {
        setState(() => _readingTime = est);
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _descCtrl.dispose();
    _authorCtrl.dispose();
    _sourceCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _pickedImage = img);
    }
  }

  String _slugify(String text) {
    final s = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
    return s.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : s;
  }

  Future<({String? url, String? storagePath})> _uploadImageIfAny() async {
    if (_pickedImage == null) return (url: null, storagePath: null);

    final file = File(_pickedImage!.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}';
    final storagePath = 'media/articles/$fileName';
    final ref = FirebaseStorage.instance.ref().child(storagePath);

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    // Firestore rules esperaban "/media/articles/..."
    return (url: url, storagePath: '/$storagePath');
  }

  void _addTag(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return;
    // separar por comas si el usuario pegó varias
    final parts = t.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    setState(() {
      for (final p in parts) {
        if (!_tags.contains(p)) _tags.add(p);
      }
    });
    _tagCtrl.clear();
  }

  Future<void> _onPublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final up = await _uploadImageIfAny();

      final repo = sl<UserArticleRepository>();
      final now = DateTime.now();

      final draft = UserArticleEntity(
        author: _authorCtrl.text.trim().isEmpty ? 'Anonymous' : _authorCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? _contentCtrl.text.trim().split('\n').first
            : _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        url: '',
        urlToImage: up.url,
        thumbnailPath: up.storagePath,
        thumbnailString: up.url ?? '',
        status: 'draft',
        tags: List<String>.from(_tags),
        language: _language ?? 'es',
        readingTime: _readingTime,
        sourceName: _sourceCtrl.text.trim().isEmpty ? 'User' : _sourceCtrl.text.trim(),
        slug: _slugify(_titleCtrl.text),
        publishedAt: null,
      );


      final createdRes = await repo.create(draft);
      if (createdRes is! DataSuccess<UserArticleEntity> ||
          createdRes.data == null) {
        throw Exception(
            'No se pudo crear el borrador: ${(createdRes as DataFailed?)?.error}');
      }

      final created = createdRes.data!;
      final pubRes = await repo.publish(created.id!, now);
      if (pubRes is DataFailed) {
        throw Exception('No se pudo publicar: ${pubRes.error}');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo publicado ✅')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int _estimateReadingTime(String text) {
    final words =
        text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words / 200).ceil().clamp(1, 60);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : () => Navigator.pop(context),
        ),
        title: const Text('Publish Article'),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _onPublish,
            icon: const Icon(Icons.publish),
            label: _submitting
                ? const Text('Publicando...')
                : const Text('Publish Article'),
          ),
        ),
      ),

      body: AbsorbPointer(
        absorbing: _submitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Write your title here...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El título es obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _authorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                        ),
                        items: const ['es', 'en', 'ca', 'fr', 'de']
                            .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l.toUpperCase()),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _language = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Attach Image'),
                    ),
                    const SizedBox(width: 12),
                    if (_pickedImage != null)
                      Expanded(
                        child: Text(
                          _pickedImage!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 12),

                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickedImage!.path),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (_pickedImage != null) const SizedBox(height: 12),

                TextFormField(
                  controller: _contentCtrl,
                  minLines: 6,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Add article here, .....',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 30)
                      ? 'Añade al menos 30 caracteres'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Short description (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _sourceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Source name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _ReadingTimeStepper(
                        value: _readingTime,
                        onChanged: (v) {
                          setState(() {
                            _readingTimeEdited = true;
                            _readingTime = v.clamp(1, 60);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: -8,
                    children: [
                      for (final t in _tags)
                        Chip(
                          label: Text(t),
                          onDeleted: () =>
                              setState(() => _tags.remove(t)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Add tag (Enter o coma)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _addTag,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addTag(_tagCtrl.text),
                      tooltip: 'Add tag',
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingTimeStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _ReadingTimeStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Reading (min)',
        border: OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: () => onChanged(value - 1),
          ),
          Text('$value'),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
