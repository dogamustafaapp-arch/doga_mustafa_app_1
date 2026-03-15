import 'package:flutter/material.dart';

import '../data/person_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.people,
    required this.onPersonTap,
  });

  final List<Person> people;
  final void Function(String name) onPersonTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: people.length,
          itemBuilder: (context, index) {
            final p = people[index];
            return _PersonScoreCard(
              name: p.name,
              relationship: p.relationshipLabel,
              score: p.score,
              onTap: () => onPersonTap(p.name),
            );
          },
        ),
      ),
    );
  }
}

class _PersonScoreCard extends StatelessWidget {
  const _PersonScoreCard({
    required this.name,
    required this.relationship,
    required this.score,
    required this.onTap,
  });

  final String name;
  final String relationship;
  final int score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          relationship,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
