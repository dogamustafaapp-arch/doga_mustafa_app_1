import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/bonds_categories_service.dart';
import '../services/people_firestore_service.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({
    super.key,
    this.customRelationshipSlugs = const [],
  });

  final List<String> customRelationshipSlugs;

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _nameController = TextEditingController();
  String? _relationship;
  bool _isAdding = false;

  static const List<({String value, String label})> _relationships = [
    (value: 'friend', label: 'Arkadaş'),
    (value: 'family', label: 'Aile'),
    (value: 'partner', label: 'Partner'),
    (value: 'pet', label: 'Evcil hayvan'),
    (value: 'other', label: 'Diğer'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addPerson() async {
    final name = _nameController.text.trim();
    final relationship = _relationship ?? 'other';
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir isim girin')),
      );
      return;
    }
    setState(() => _isAdding = true);
    try {
      await PeopleFirestoreService.instance.addPerson(
        name: name,
        relationship: relationship,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Zaman aşımı'),
      );
      if (!mounted) return;
      _nameController.clear();
      setState(() => _relationship = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kişi eklendi')),
      );
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'İstek zaman aşımına uğradı. Bağlantınızı kontrol edip tekrar deneyin.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 28;

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      appBar: AppBar(
        backgroundColor: AppPalette.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kişi ekle',
          style: tt.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Zaman geçirdiğin biri ekle',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aktivite puanlarını ortadaki düğmeden kaydedebilirsin.',
                style: tt.bodyMedium?.copyWith(
                  color: AppPalette.mutedNav,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  hintText: 'örn. Alex',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'İlişki',
                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('İlişki seç'),
                  ),
                  ..._relationships.map(
                    (r) => DropdownMenuItem<String?>(
                      value: r.value,
                      child: Text(r.label),
                    ),
                  ),
                  ...widget.customRelationshipSlugs.map(
                    (slug) => DropdownMenuItem<String?>(
                      value: slug,
                      child: Text(
                        BondsCategoriesService.prettyLabelForSlug(slug),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _relationship = v),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isAdding ? null : _addPerson,
                icon: _isAdding
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(_isAdding ? 'Ekleniyor…' : 'Listeye ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
