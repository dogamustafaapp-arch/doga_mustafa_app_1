import 'package:flutter/material.dart';

import '../app_theme.dart';

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
                'Vote',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick who you were with, what you did, and how it felt (1–5).',
                style: tt.bodyMedium?.copyWith(
                  color: AppPalette.mutedNav,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              DropdownButtonFormField<String?>(
                value: _selectedPerson,
                decoration: const InputDecoration(
                  labelText: 'Who',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Choose someone'),
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
                decoration: const InputDecoration(
                  labelText: 'Activity',
                  hintText: 'e.g. Coffee, walk',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How was it?',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '1 = not great · 5 = amazing',
                style: tt.bodySmall?.copyWith(color: AppPalette.mutedNav),
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(5, (i) {
                  final score = i + 1;
                  final selected = _selectedScore == score;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 4 ? 8 : 0),
                      child: _ScorePill(
                        score: score,
                        selected: selected,
                        onTap: () => setState(
                          () => _selectedScore = selected ? null : score,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_rounded),
                label: const Text('Save vote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppPalette.blueGrad : AppPalette.cardGrey,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              '$score',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
