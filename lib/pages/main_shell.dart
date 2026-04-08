import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/person_model.dart';
import '../services/bonds_categories_service.dart';
import '../services/people_firestore_service.dart';
import 'activity_vote_page.dart';
import 'add_person_page.dart';
import 'home_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _selectedPersonForVote;
  List<Person> _people = [];
  List<String> _customRelSlugs = [];
  StreamSubscription<List<Person>>? _peopleSub;

  @override
  void initState() {
    super.initState();
    _loadCustomRelationships();
    _peopleSub = PeopleFirestoreService.instance.watchPeople().listen(
      (people) {
        if (mounted) setState(() => _people = people);
      },
      onError: (Object err, StackTrace? st) {
        if (mounted) setState(() => _people = _people);
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _peopleSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomRelationships() async {
    final list = await BondsCategoriesService.instance.getCustomRelationships();
    if (mounted) setState(() => _customRelSlugs = list);
  }

  void _onPersonTap(String name) {
    setState(() {
      _selectedPersonForVote = name;
      _currentIndex = 1;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 1) _selectedPersonForVote = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final personNames = _people.map((p) => p.name).toList();

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            people: _people,
            onPersonTap: _onPersonTap,
            customRelationshipSlugs: _customRelSlugs,
            onCustomCategoriesChanged: _loadCustomRelationships,
          ),
          ActivityVotePage(
            personNames: personNames,
            initialPersonName: _selectedPersonForVote,
          ),
          AddPersonPage(customRelationshipSlugs: _customRelSlugs),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterVoteFab(
        selected: _currentIndex == 1,
        onPressed: () => _onDestinationSelected(1),
      ),
      bottomNavigationBar: _BondsBottomBar(
        currentIndex: _currentIndex,
        onSelect: _onDestinationSelected,
      ),
    );
  }
}

class _CenterVoteFab extends StatelessWidget {
  const _CenterVoteFab({
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: selected ? 10 : 8,
      shadowColor: AppPalette.purpleGrad.withOpacity(0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppPalette.purpleGrad,
                AppPalette.blueGrad,
              ],
            ),
          ),
          child: const Icon(
            Icons.all_inclusive_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _BondsBottomBar extends StatelessWidget {
  const _BondsBottomBar({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return BottomAppBar(
      height: 76,
      padding: const EdgeInsets.only(top: 10),
      color: AppPalette.navBar,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        children: [
          Expanded(
            child: _NavSlot(
              selected: currentIndex == 0,
              icon: Icons.blur_circular_rounded,
              label: 'Bonds',
              activeColor: AppPalette.tealNav,
              onTap: () => onSelect(0),
              textTheme: tt,
            ),
          ),
          const SizedBox(width: 88),
          Expanded(
            child: _NavSlot(
              selected: currentIndex == 2,
              icon: Icons.menu_rounded,
              label: 'Manage',
              activeColor: AppPalette.tealNav,
              onTap: () => onSelect(2),
              textTheme: tt,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.selected,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
    required this.textTheme,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : AppPalette.mutedNav;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
