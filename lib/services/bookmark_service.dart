import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmark {
  final String trackNumber;
  final String lastStatus;
  final DateTime lastChecked;

  Bookmark({
    required this.trackNumber,
    required this.lastStatus,
    required this.lastChecked,
  });

  factory Bookmark.fromJson(Map<String, dynamic> jsonMap) {
    return Bookmark(
      trackNumber: jsonMap['trackNumber'],
      lastStatus: jsonMap['lastStatus'],
      lastChecked: DateTime.fromMillisecondsSinceEpoch(jsonMap['lastChecked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackNumber': trackNumber,
      'lastStatus': lastStatus,
      'lastChecked': lastChecked.millisecondsSinceEpoch,
    };
  }
}

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();

  factory BookmarkService() {
    return _instance;
  }

  BookmarkService._internal() {
    loadBookmarks();
  }

  static const _key = 'smart_bookmarks';

  List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarksJson = prefs.getStringList(_key) ?? [];
    _bookmarks = bookmarksJson.map((jsonString) {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return Bookmark.fromJson(jsonMap);
    }).toList();
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarksJson =
        _bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_key, bookmarksJson);
  }

  Future<void> upsertBookmark(String trackNumber, String lastStatus) async {
    _bookmarks.removeWhere((b) => b.trackNumber == trackNumber);

    final newBookmark = Bookmark(
      trackNumber: trackNumber,
      lastStatus: lastStatus,
      lastChecked: DateTime.now(),
    );

    _bookmarks.insert(0, newBookmark);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(String trackNumber) async {
    _bookmarks.removeWhere((b) => b.trackNumber == trackNumber);
    await _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String trackNumber) {
    return _bookmarks.any((b) => b.trackNumber == trackNumber);
  }

  Bookmark? getByTrack(String trackNumber) {
    try {
      return _bookmarks.firstWhere((b) => b.trackNumber == trackNumber);
    } catch (_) {
      return null;
    }
  }
}
