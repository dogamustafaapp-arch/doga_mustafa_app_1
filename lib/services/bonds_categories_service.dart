import 'package:shared_preferences/shared_preferences.dart';

/// Local prefs for bond list filters: favorites and user-defined relationship buckets.
class BondsCategoriesService {
  BondsCategoriesService._();
  static final BondsCategoriesService instance = BondsCategoriesService._();

  static const _kFavorites = 'bonds_favorite_ids';
  static const _kCustomRels = 'bonds_custom_relationships';

  static const reservedSlugs = {
    'all',
    'family',
    'friend',
    'friends',
    'partner',
    'pet',
    'pets',
    'other',
    'favorites',
  };

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kFavorites) ?? []).toSet();
  }

  Future<Set<String>> toggleFavorite(String personId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kFavorites) ?? [];
    final set = list.toSet();
    if (set.contains(personId)) {
      set.remove(personId);
    } else {
      set.add(personId);
    }
    final out = set.toList()..sort();
    await prefs.setStringList(_kFavorites, out);
    return set;
  }

  Future<List<String>> getCustomRelationships() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kCustomRels) ?? [];
    return List<String>.from(list);
  }

  /// Returns error message if invalid, null if saved.
  Future<String?> addCustomRelationship(String displayName) async {
    final slug = slugify(displayName);
    if (slug.isEmpty) return 'Bir isim girin';
    if (reservedSlugs.contains(slug)) {
      return 'Bu ad ayrılmış';
    }
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_kCustomRels) ?? []);
    if (list.contains(slug)) return 'Bu kategori zaten var';
    list.add(slug);
    list.sort();
    await prefs.setStringList(_kCustomRels, list);
    return null;
  }

  static String slugify(String raw) {
    final s = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return s.replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  static String prettyLabelForSlug(String slug) {
    if (slug.isEmpty) return slug;
    return slug
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
