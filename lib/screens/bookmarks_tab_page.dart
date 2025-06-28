import 'package:flutter/material.dart';
import '../models/tracking_result.dart';
import '../services/bookmark_service.dart';
import '../services/tracking_service.dart';
import '../services/tracking_cache_service.dart';
import 'tracking_details_screen.dart';
import '../widgets/bookmark_card.dart';

class BookmarksTabPage extends StatefulWidget {
  const BookmarksTabPage({super.key});

  @override
  State<BookmarksTabPage> createState() => _BookmarksTabPageState();
}

class _BookmarksTabPageState extends State<BookmarksTabPage> {
  final BookmarkService _bookmarkService = BookmarkService();
  final EvropochtaTrackingService _trackingService = EvropochtaTrackingService();
  final TrackingCacheService _cacheService = TrackingCacheService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookmarkService.addListener(_onBookmarksChanged);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    super.dispose();
  }

  void _onBookmarksChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadBookmarks({bool refreshTracking = false}) async {
    setState(() => _isLoading = true);

    // Обновляем внутренний список из SharedPreferences (в BookmarkService)
    await _bookmarkService.loadBookmarks();

    if (refreshTracking) {
      final bookmarks = _bookmarkService.bookmarks;
      for (final b in bookmarks) {
        try {
          final fresh = await _trackingService.getTrackingData(b.trackNumber);
          await _cacheService.set(b.trackNumber, fresh);
          if (fresh is TrackingSuccess && fresh.events.isNotEmpty) {
            await _bookmarkService.upsertBookmark(
              b.trackNumber,
              fresh.events.first.comment,
            );
          }
        } catch (_) {
          // Игнорируем ошибки при обновлении
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _openTrackingDetails(BuildContext context, String trackNumber) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    TrackingResult? result = await _cacheService.get(trackNumber);
    if (result == null) {
      result = await _trackingService.getTrackingData(trackNumber);
      await _cacheService.set(trackNumber, result);
    }

    if (!context.mounted) return;
    Navigator.pop(context);

    final wasDeleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingDetailsScreen(
          trackNumber: trackNumber,
          result: result,
        ),
      ),
    );

    if (wasDeleted == true) {
      await _loadBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarkService.bookmarks;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

if (bookmarks.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmarks_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'У вас пока нет закладок.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


    return RefreshIndicator(
      onRefresh: () => _loadBookmarks(refreshTracking: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          return BookmarkCard(
            bookmark: bookmark,
            onTap: () => _openTrackingDetails(context, bookmark.trackNumber),
          );
        },
      ),
    );
  }
}
