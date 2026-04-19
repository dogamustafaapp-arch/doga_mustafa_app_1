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
    (value: 'friend', label: 'Friend'),
    (value: 'family', label: 'Family'),
    (value: 'partner', label: 'Partner'),
    (value: 'pet', label: 'Pet'),
    (value: 'other', label: 'Other'),
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
        const SnackBar(content: Text('Please enter a name')),
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
        onTimeout: () => throw TimeoutException('Add timed out'),
      );
      if (!mounted) return;
      _nameController.clear();
      setState(() => _relationship = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person added')),
      );
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Request timed out. Check your connection and try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e')),
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
          'Add person',
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
                'Add someone you spend time with',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log activity scores from the center button.',
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
                  labelText: 'Name',
                  hintText: 'e.g. Alex',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Choose relationship'),
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
                label: Text(_isAdding ? 'Adding…' : 'Add to list'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
