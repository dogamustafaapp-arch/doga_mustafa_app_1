import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../bond_strength.dart';
import '../data/person_model.dart';
import '../services/bonds_categories_service.dart';
import 'bonds_map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.people,
    required this.onPersonTap,
    required this.customRelationshipSlugs,
    required this.onAddPersonTap,
    required this.onSettingsTap,
    this.onCustomCategoriesChanged,
  });

  final List<Person> people;
  final void Function(Person person) onPersonTap;
  final List<String> customRelationshipSlugs;
  final VoidCallback onAddPersonTap;
  final VoidCallback onSettingsTap;
  final Future<void> Function()? onCustomCategoriesChanged;

  static List<Person> sortedByScore(List<Person> people) {
    final copy = List<Person>.from(people);
    copy.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  /// Built-in: all | family | friends | pets | favorites | or custom slug.
  String _categoryId = 'all';
  Set<String> _favoriteIds = {};
  bool _searchOpen = false;
  bool _mapViewMode = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_categoryId != 'all' &&
        !{'family', 'friends', 'pets', 'favorites'}.contains(_categoryId) &&
        !widget.customRelationshipSlugs.contains(_categoryId)) {
      setState(() => _categoryId = 'all');
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await BondsCategoriesService.instance.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids);
  }

  Future<void> _toggleFavorite(String personId) async {
    final next = await BondsCategoriesService.instance.toggleFavorite(personId);
    if (mounted) setState(() => _favoriteIds = next);
  }

  bool _categoryMatch(Person p) {
    switch (_categoryId) {
      case 'all':
        return true;
      case 'family':
        return p.relationship == 'family';
      case 'friends':
        return p.relationship == 'friend' || p.relationship == 'partner';
      case 'pets':
        return p.relationship == 'pet';
      case 'favorites':
        return _favoriteIds.contains(p.id);
      default:
        return p.relationship == _categoryId;
    }
  }

  List<Person> get _afterCategory {
    return widget.people.where(_categoryMatch).toList();
  }

  List<Person> get _visiblePeople {
    final sorted = HomePage.sortedByScore(_afterCategory);
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return sorted;
    return sorted
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();
    final submitted = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppPalette.cardGrey,
          title: Text(
            'New category',
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Work, Neighbors',
              hintStyle: TextStyle(color: AppPalette.mutedNav.withValues(alpha: 0.8)),
              filled: true,
              fillColor: AppPalette.charcoal,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppPalette.mutedNav.withValues(alpha: 0.35)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppPalette.blueGrad, width: 1.5),
              ),
            ),
            onSubmitted: (_) => Navigator.pop(ctx, controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppPalette.mutedNav)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (submitted == null || !mounted) return;
    final msg =
        await BondsCategoriesService.instance.addCustomRelationship(submitted);
    if (!mounted) return;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    await widget.onCustomCategoriesChanged?.call();
    final slug = BondsCategoriesService.slugify(submitted);
    if (slug.isNotEmpty) {
      setState(() => _categoryId = slug);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasAny = widget.people.isNotEmpty;
    final afterCat = _afterCategory;
    final visible = _visiblePeople;
    final query = _searchController.text.trim();
    final categoryEmpty = hasAny && afterCat.isEmpty;
    final searchMiss = hasAny && !categoryEmpty && visible.isEmpty;

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Bonds',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PREMIUM',
                            style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppPalette.purpleGrad,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onAddPersonTap,
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: _InstagramStyleAddPersonIcon(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  accent: AppPalette.tealNav,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onSettingsTap,
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white.withValues(alpha: 0.88),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategorySearchRow(
                showCategoryStrip: hasAny,
                selectedId: _categoryId,
                customSlugs: widget.customRelationshipSlugs,
                mapViewMode: _mapViewMode,
                searchOpen: _searchOpen,
                onCategorySelected: (id) => setState(() => _categoryId = id),
                onToggleMapView: () => setState(() {
                  _mapViewMode = !_mapViewMode;
                  if (_mapViewMode) {
                    _searchOpen = false;
                    _searchController.clear();
                  }
                }),
                onToggleSearch: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (_searchOpen) {
                    _mapViewMode = false;
                  }
                  if (!_searchOpen) {
                    _searchController.clear();
                  }
                }),
                onAddCategory: _addCategoryDialog,
              ),
            ),
            if (_searchOpen && !_mapViewMode && hasAny)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: _BondsSearchField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            if (_mapViewMode)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: SizedBox(
                    height: (MediaQuery.sizeOf(context).height * 0.56)
                        .clamp(300.0, 600.0),
                    width: double.infinity,
                    child: const BondsMapPreview(),
                  ),
                ),
              )
            else if (!hasAny)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyBondsHint(textTheme: tt),
              )
            else if (categoryEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyCategoryHint(
                  textTheme: tt,
                  categoryId: _categoryId,
                ),
              )
            else if (searchMiss)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NoSearchResultsHint(
                  textTheme: tt,
                  query: query,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = visible[index];
                    return _BondCard(
                      rank: index + 1,
                      name: p.name,
                      score: p.score,
                      isFavorite: _favoriteIds.contains(p.id),
                      onTap: () => widget.onPersonTap(p),
                      onFavoriteTap: () => _toggleFavorite(p.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySearchRow extends StatelessWidget {
  const _CategorySearchRow({
    required this.showCategoryStrip,
    required this.selectedId,
    required this.customSlugs,
    required this.mapViewMode,
    required this.searchOpen,
    required this.onCategorySelected,
    required this.onToggleMapView,
    required this.onToggleSearch,
    required this.onAddCategory,
  });

  final bool showCategoryStrip;
  final String selectedId;
  final List<String> customSlugs;
  final bool mapViewMode;
  final bool searchOpen;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onToggleMapView;
  final VoidCallback onToggleSearch;
  final VoidCallback onAddCategory;

  static const _builtIn = <String, String>{
    'all': 'All',
    'family': 'Family',
    'friends': 'Friends',
    'pets': 'Pets',
    'favorites': 'Favorites',
  };

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, String>>[
      ..._builtIn.entries,
      ...customSlugs.map(
        (s) => MapEntry(s, BondsCategoriesService.prettyLabelForSlug(s)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showCategoryStrip)
            Expanded(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entries.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == entries.length) {
                      return _CategoryChip(
                        label: null,
                        icon: Icons.add_rounded,
                        selected: false,
                        compact: true,
                        onTap: onAddCategory,
                      );
                    }
                    final e = entries[i];
                    return _CategoryChip(
                      label: e.value,
                      selected: selectedId == e.key,
                      onTap: () => onCategorySelected(e.key),
                    );
                  },
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 6),
          Material(
            color: mapViewMode
                ? AppPalette.blueGrad.withValues(alpha: 0.22)
                : AppPalette.cardGrey,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onToggleMapView,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  mapViewMode
                      ? Icons.view_list_rounded
                      : Icons.map_rounded,
                  size: 22,
                  color:
                      mapViewMode ? AppPalette.blueGrad : AppPalette.mutedNav,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: searchOpen
                ? AppPalette.blueGrad.withValues(alpha: 0.22)
                : AppPalette.cardGrey,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onToggleSearch,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: searchOpen ? AppPalette.blueGrad : AppPalette.mutedNav,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    this.label,
    this.icon,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String? label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: selected
          ? AppPalette.blueGrad.withValues(alpha: 0.28)
          : AppPalette.cardGrey,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 8 : 9,
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: selected ? AppPalette.blueGrad : AppPalette.mutedNav,
                )
              : Text(
                  label ?? '',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    color: selected ? Colors.white : AppPalette.mutedNav,
                  ),
                ),
        ),
      ),
    );
  }
}

class _BondsSearchField extends StatelessWidget {
  const _BondsSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static final _borderMuted =
      AppPalette.mutedNav.withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: tt.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppPalette.blueGrad,
          decoration: InputDecoration(
            hintText: 'Search by name',
            hintStyle: tt.bodyMedium?.copyWith(
              color: AppPalette.mutedNav.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppPalette.mutedNav.withValues(alpha: 0.85),
              size: 22,
            ),
            suffixIcon: hasText
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppPalette.mutedNav.withValues(alpha: 0.85),
                      size: 20,
                    ),
                    tooltip: 'Clear',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _borderMuted),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _borderMuted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppPalette.blueGrad,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: AppPalette.cardGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 10,
            ),
            isDense: true,
          ),
        );
      },
    );
  }
}

class _NoSearchResultsHint extends StatelessWidget {
  const _NoSearchResultsHint({
    required this.textTheme,
    required this.query,
  });

  final TextTheme textTheme;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppPalette.mutedNav.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Try a different search.'
                  : 'Nobody matches “$query”. Try another name.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppPalette.mutedNav,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryHint extends StatelessWidget {
  const _EmptyCategoryHint({
    required this.textTheme,
    required this.categoryId,
  });

  final TextTheme textTheme;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    String title;
    String body;
    switch (categoryId) {
      case 'favorites':
        title = 'No favorites yet';
        body = 'Tap the star on a bond to add them here.';
        break;
      case 'friends':
        title = 'No friends or partners';
        body =
            'When adding someone, choose Friend or Partner (add-person icon at the top).';
        break;
      case 'pets':
        title = 'No pets';
        body = 'When adding someone, set relationship to Pet.';
        break;
      case 'family':
        title = 'No family';
        body = 'When adding someone, set relationship to Family.';
        break;
      default:
        title = 'No one in this category';
        body =
            'Assign this category when adding a person, or pick another filter.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off_rounded,
              size: 48,
              color: AppPalette.mutedNav.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: AppPalette.mutedNav,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header add-person control (outline person + small plus badge).
class _InstagramStyleAddPersonIcon extends StatelessWidget {
  const _InstagramStyleAddPersonIcon({
    required this.color,
    required this.accent,
  });

  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.person_outline_rounded, size: 24, color: color),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              decoration: const BoxDecoration(
                color: AppPalette.charcoal,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(1),
              child: Icon(Icons.add_circle_rounded, size: 14, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBondsHint extends StatelessWidget {
  const _EmptyBondsHint({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.diversity_3_rounded,
              size: 56,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 20),
            Text(
              'No bonds yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add someone with the add-person icon on the top right, then log activities from the center button.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppPalette.mutedNav,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BondCard extends StatelessWidget {
  const _BondCard({
    required this.rank,
    required this.name,
    required this.score,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final int rank;
  final String name;
  final int score;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Material(
      color: AppPalette.cardGrey,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withValues(alpha: 0.08),
              highlightColor: Colors.white.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$rank',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFFC084FC),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onFavoriteTap,
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            style: IconButton.styleFrom(
              foregroundColor:
                  isFavorite ? AppPalette.ringProgress : AppPalette.mutedNav,
              minimumSize: const Size(40, 48),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 26,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 5,
                height: 44,
                decoration: BoxDecoration(
                  color: BondStrength.colorForScore(score),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
