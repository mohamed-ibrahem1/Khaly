import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bill_history.dart';

class StorageService {
  static const String _frequentFriendsKey = 'frequent_friends';
  static const String _billHistoryKey = 'bill_history';

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

  static Future<List<BillHistory>> getBillHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_billHistoryKey) ?? [];
    return encoded
        .map(
          (value) =>
              BillHistory.fromMap(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveBillHistory(BillHistory bill) async {
    final history = await getBillHistory();
    history.removeWhere((item) => item.id == bill.id);
    history.insert(0, bill);
    final limitedHistory = history.take(5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _billHistoryKey,
      limitedHistory.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }
}
