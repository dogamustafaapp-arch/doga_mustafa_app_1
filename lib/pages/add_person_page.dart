import 'dart:async';

import 'package:flutter/material.dart';

import '../services/people_firestore_service.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add people to your list: friends, family, partner, pet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Alex',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.favorite_border_rounded),
                ),
                items: _relationships
                    .map((r) => DropdownMenuItem(
                          value: r.value,
                          child: Text(r.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _relationship = v),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isAdding ? null : _addPerson,
                icon: _isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(_isAdding ? 'Adding…' : 'Add'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
