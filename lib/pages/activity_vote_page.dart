import 'package:flutter/material.dart';

class ActivityVotePage extends StatefulWidget {
  const ActivityVotePage({
    super.key,
    required this.personNames,
    this.initialPersonName,
  });

  final List<String> personNames;
  final String? initialPersonName;

  @override
  State<ActivityVotePage> createState() => _ActivityVotePageState();
}

class _ActivityVotePageState extends State<ActivityVotePage> {
  String? _selectedPerson;
  int? _selectedScore;

  @override
  void initState() {
    super.initState();
    if (widget.initialPersonName != null &&
        widget.personNames.contains(widget.initialPersonName)) {
      _selectedPerson = widget.initialPersonName;
    }
  }

  @override
  void didUpdateWidget(ActivityVotePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPersonName != null &&
        widget.initialPersonName != oldWidget.initialPersonName &&
        widget.personNames.contains(widget.initialPersonName)) {
      setState(() => _selectedPerson = widget.initialPersonName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.personNames;

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
                'Select a person and rate the activity you did together.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String?>(
                value: _selectedPerson,
                decoration: InputDecoration(
                  labelText: 'Select person',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('— Select —'),
                  ),
                  ...names.map(
                    (name) => DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedPerson = v),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Activity',
                  hintText: 'e.g. Coffee, walk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.directions_walk_rounded),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Score (1–5)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final score = i + 1;
                  final isSelected = _selectedScore == score;
                  return FilterChip(
                    label: Text('$score'),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedScore = isSelected ? null : score),
                  );
                }),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_rounded),
                label: const Text('Vote'),
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
