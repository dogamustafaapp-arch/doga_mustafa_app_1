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
            content: Text('Request timed out. Check connection or try again.'),
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
    final bottomInset = MediaQuery.paddingOf(context).bottom + 88;

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Manage',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add someone you spend time with. Rate activities from the center button.',
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
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                ),
                items: [
                  ..._relationships.map(
                    (r) => DropdownMenuItem(
                      value: r.value,
                      child: Text(r.label),
                    ),
                  ),
                  ...widget.customRelationshipSlugs.map(
                    (slug) => DropdownMenuItem(
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
