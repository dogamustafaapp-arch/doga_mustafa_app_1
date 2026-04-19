import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../bond_strength.dart';
import '../data/person_model.dart';
import '../services/bonds_categories_service.dart';

/// Bond detail: avatar, score, and placeholder recent activity (data layer later).
class PersonProfilePage extends StatelessWidget {
  const PersonProfilePage({
    super.key,
    required this.person,
  });

  final Person person;

  String get _relationshipLabel {
    const builtIn = {
      'friend': 'Arkadaş',
      'family': 'Aile',
      'partner': 'Partner',
      'pet': 'Evcil hayvan',
      'other': 'Diğer',
    };
    final r = person.relationship;
    return builtIn[r] ??
        BondsCategoriesService.prettyLabelForSlug(
          r.replaceAll('-', '_'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPad = MediaQuery.paddingOf(context).top;
    final initial =
        person.name.isNotEmpty ? person.name[0].toUpperCase() : '?';
    final bondColor = BondStrength.colorForScore(person.score);

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
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
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: tt.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    person.name,
                    textAlign: TextAlign.center,
                    style: tt.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.cardGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _relationshipLabel,
                      style: tt.labelLarge?.copyWith(
                        color: AppPalette.mutedNav,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bondColor,
                          boxShadow: [
                            BoxShadow(
                              color: bondColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bağ sıcaklığı',
                              style: tt.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hafifken kehribar tonlarına yakın; bağ güçlendikçe turkuaza kayar. Sayılar bilinçli olarak gizli.',
                              style: tt.bodySmall?.copyWith(
                                color: AppPalette.mutedNav,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son aktiviteler',
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Örnek metin — geçmiş buraya senkron olacak.',
                      style: tt.bodySmall?.copyWith(
                        color: AppPalette.mutedNav,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._placeholderActivities.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ActivityRow(
                        title: a.title,
                        subtitle: a.subtitle,
                        when: a.when,
                        textTheme: tt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: topPad + 4,
            left: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _placeholderActivities = <({String title, String subtitle, String when})>[
  (
    title: 'Kahve & sohbet',
    subtitle: 'Bağ',
    when: '3 gün önce',
  ),
  (
    title: 'Akşam yürüyüşü',
    subtitle: 'Hareket',
    when: '1 hafta önce',
  ),
  (
    title: 'Kısa arama',
    subtitle: 'Kontrol',
    when: '2 hafta önce',
  ),
];

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.when,
    required this.textTheme,
  });

  final String title;
  final String subtitle;
  final String when;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.cardGrey,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppPalette.ringTrack,
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Colors.white54,
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
                  const SizedBox(height: 2),
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
              when,
              style: textTheme.labelSmall?.copyWith(
                color: AppPalette.mutedNav,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
