import 'package:shared_preferences/shared_preferences.dart';

class HymnFavoriteService {
  static const _key = 'hymn_favorites';

  static Future<Set<int>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<bool> isFavorite(int hymnNumber) async {
    final set = await getAll();
    return set.contains(hymnNumber);
  }

  static Future<bool> toggle(int hymnNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getAll();
    if (set.contains(hymnNumber)) {
      set.remove(hymnNumber);
    } else {
      set.add(hymnNumber);
    }
    await prefs.setStringList(_key, set.map((e) => e.toString()).toList());
    return set.contains(hymnNumber);
  }
}
