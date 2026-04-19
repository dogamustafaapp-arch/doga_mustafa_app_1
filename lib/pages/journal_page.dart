import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Past activities and notes — placeholder content for now; data layer to be wired later.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _notesController = TextEditingController();

  static const List<({String title, String subtitle, String day})> _demoEntries = [
    (
      title: 'Coffee with Alex',
      subtitle: 'Chat · Connection',
      day: '2 days ago',
    ),
    (
      title: 'Sam — walk',
      subtitle: 'Movement · Quality time',
      day: '5 days ago',
    ),
    (
      title: 'Jordan, phone call',
      subtitle: 'Check-in',
      day: '1 week ago',
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Journal',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Past activities',
                  style: tt.titleSmall?.copyWith(
                    color: AppPalette.mutedNav,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: _demoEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final e = _demoEntries[i];
                  return _JournalActivityCard(
                    title: e.title,
                    subtitle: e.subtitle,
                    day: e.day,
                    textTheme: tt,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'My notes',
                  style: tt.titleSmall?.copyWith(
                    color: AppPalette.mutedNav,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
                child: TextField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'How are you feeling today? (saving not wired yet)',
                    hintStyle: TextStyle(
                      color: AppPalette.mutedNav.withValues(alpha: 0.85),
                    ),
                    filled: true,
                    fillColor: AppPalette.cardGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }
}

class _JournalActivityCard extends StatelessWidget {
  const _JournalActivityCard({
    required this.title,
    required this.subtitle,
    required this.day,
    required this.textTheme,
  });

  final String title;
  final String subtitle;
  final String day;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.cardGrey,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppPalette.purpleGrad.withValues(alpha: 0.55),
                      AppPalette.blueGrad.withValues(alpha: 0.45),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedNav,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                day,
                style: textTheme.labelSmall?.copyWith(
                  color: AppPalette.mutedNav,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
