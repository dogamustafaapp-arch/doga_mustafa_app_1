import 'dart:async';

import 'package:flutter/material.dart';

import '../data/person_model.dart';
import '../services/people_firestore_service.dart';
import 'home_page.dart';
import 'add_person_page.dart';
import 'activity_vote_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _selectedPersonForVote;
  List<Person> _people = [];
  StreamSubscription<List<Person>>? _peopleSub;

  @override
  void initState() {
    super.initState();
    _peopleSub = PeopleFirestoreService.instance.watchPeople().listen(
      (people) {
        if (mounted) setState(() => _people = people);
      },
      onError: (Object err, StackTrace? st) {
        // Keep listening; avoid losing future updates after one error.
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

  void _onPersonTap(String name) {
    setState(() {
      _selectedPersonForVote = name;
      _currentIndex = 2;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 2) _selectedPersonForVote = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final personNames = _people.map((p) => p.name).toList();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            people: _people,
            onPersonTap: _onPersonTap,
          ),
          const AddPersonPage(),
          ActivityVotePage(
            personNames: personNames,
            initialPersonName: _selectedPersonForVote,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.thumb_up_outlined),
            selectedIcon: Icon(Icons.thumb_up_rounded),
            label: 'Vote',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add_rounded),
            label: 'Add Person',
          ),
          
        ],
      ),
    );
  }
}
