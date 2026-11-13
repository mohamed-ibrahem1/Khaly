import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _frequentFriendsKey = 'frequent_friends';

  /// Returns the list of frequently-used friend names.
  static Future<List<String>> getFrequentFriends() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_frequentFriendsKey) ?? [];
  }

  /// Replaces the entire frequent-friends list.
  static Future<void> saveFrequentFriends(List<String> friends) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_frequentFriendsKey, friends);
  }

  /// Adds a name to the frequent-friends list if it is not already present.
  static Future<void> addFrequentFriend(String name) async {
    final friends = await getFrequentFriends();
    if (!friends.contains(name)) {
      friends.add(name);
      await saveFrequentFriends(friends);
    }
  }

  /// Removes a name from the frequent-friends list.
  static Future<void> removeFrequentFriend(String name) async {
    final friends = await getFrequentFriends();
    friends.remove(name);
    await saveFrequentFriends(friends);
  }
}
