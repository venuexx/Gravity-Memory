import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService extends ChangeNotifier {
  static const _prefCompleted = 'level_completed_';
  static const _prefUnlocked = 'level_unlocked_';
  static const _prefCoins = 'coins';
  static const _prefSound = 'sound';
  static const _prefMusic = 'music';
  static const _prefOldStars = 'level_stars_';
  static const _prefMigrationDone = 'migration_v1_done';
  static const _prefOwnedChars = 'owned_chars';
  static const _prefOwnedTiles = 'owned_tiles';
  static const _prefSelectedChar = 'selected_char';
  static const _prefSelectedTile = 'selected_tile';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // State
  int _coins = 0;
  bool _sound = true;
  bool _music = true;
  Set<int> _completedLevels = {};
  Set<int> _unlockedLevels = {1};
  List<int> _ownedChars = [0];
  List<int> _ownedTiles = [0];
  int _selectedChar = 0;
  int _selectedTile = 0;

  int get coins => _coins;
  bool get sound => _sound;
  bool get music => _music;
  Set<int> get completedLevels => _completedLevels;
  Set<int> get unlockedLevels => _unlockedLevels;
  List<int> get ownedChars => _ownedChars;
  List<int> get ownedTiles => _ownedTiles;
  int get selectedChar => _selectedChar;
  int get selectedTile => _selectedTile;

  bool isUnlocked(int levelId) => _unlockedLevels.contains(levelId);
  bool isCompleted(int levelId) => _completedLevels.contains(levelId);

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _load();
    _initialized = true;
  }

  void _load() {
    _coins = _prefs.getInt(_prefCoins) ?? 0;
    _sound = _prefs.getBool(_prefSound) ?? true;
    _music = _prefs.getBool(_prefMusic) ?? true;
    _selectedChar = _prefs.getInt(_prefSelectedChar) ?? 0;
    _selectedTile = _prefs.getInt(_prefSelectedTile) ?? 0;

    _ownedChars = _prefs.getStringList(_prefOwnedChars)
            ?.map(int.parse)
            .toList() ??
        [0];
    _ownedTiles = _prefs.getStringList(_prefOwnedTiles)
            ?.map(int.parse)
            .toList() ??
        [0];

    for (int i = 1; i <= 100; i++) {
      if (_prefs.getBool('$_prefCompleted$i') == true) {
        _completedLevels.add(i);
      }
      if (_prefs.getBool('$_prefUnlocked$i') == true) {
        _unlockedLevels.add(i);
      }
    }

    _migrateOldData();
  }

  void _migrateOldData() {
    if (_prefs.getBool(_prefMigrationDone) == true) return;

    for (int i = 1; i <= 100; i++) {
      final oldStars = _prefs.getInt('$_prefOldStars$i') ?? 0;
      if (oldStars > 0 && !_completedLevels.contains(i)) {
        _completedLevels.add(i);
        _prefs.setBool('$_prefCompleted$i', true);
      }
    }

    _prefs.setBool(_prefMigrationDone, true);
  }

  Future<void> saveLevel(int levelId) async {
    _completedLevels.add(levelId);
    await _prefs.setBool('$_prefCompleted$levelId', true);

    if (levelId < 100) {
      _unlockedLevels.add(levelId + 1);
      await _prefs.setBool('$_prefUnlocked${levelId + 1}', true);
    }

    notifyListeners();
  }

  Future<void> setSound(bool v) async {
    _sound = v;
    await _prefs.setBool(_prefSound, v);
    notifyListeners();
  }

  Future<void> setMusic(bool v) async {
    _music = v;
    await _prefs.setBool(_prefMusic, v);
    notifyListeners();
  }

  Future<void> purchaseChar(int id, int price) async {
    if (_coins >= price && !_ownedChars.contains(id)) {
      _coins -= price;
      _ownedChars.add(id);
      await _prefs.setInt(_prefCoins, _coins);
      await _prefs.setStringList(
          _prefOwnedChars, _ownedChars.map((e) => e.toString()).toList());
      notifyListeners();
    }
  }

  Future<void> purchaseTile(int id, int price) async {
    if (_coins >= price && !_ownedTiles.contains(id)) {
      _coins -= price;
      _ownedTiles.add(id);
      await _prefs.setInt(_prefCoins, _coins);
      await _prefs.setStringList(
          _prefOwnedTiles, _ownedTiles.map((e) => e.toString()).toList());
      notifyListeners();
    }
  }

  Future<void> selectChar(int id) async {
    _selectedChar = id;
    await _prefs.setInt(_prefSelectedChar, id);
    notifyListeners();
  }

  Future<void> selectTile(int id) async {
    _selectedTile = id;
    await _prefs.setInt(_prefSelectedTile, id);
    notifyListeners();
  }
}
