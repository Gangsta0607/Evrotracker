import 'package:flutter/material.dart';
import '../models/tracking_result.dart';
import '../services/bookmark_service.dart';
import '../services/tracking_service.dart';
import '../services/tracking_cache_service.dart';
import '../widgets/tracking_result_view.dart';

class TrackingTabPage extends StatefulWidget {
  const TrackingTabPage({super.key});

  @override
  State<TrackingTabPage> createState() => _TrackingTabPageState();
}

class _TrackingTabPageState extends State<TrackingTabPage> {
  final _textController = TextEditingController();
  final _trackingService = EvropochtaTrackingService();
  final _cacheService = TrackingCacheService();
  final _bookmarkService = BookmarkService();

  bool _isLoading = false;
  TrackingResult? _result;
  bool _isBookmarked = false;
  String? _searchedTrackNumber;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkBookmarkStatus);
    _bookmarkService.addListener(_onBookmarksChanged);
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onBookmarksChanged() {
    // Обновляем статус закладки, если трек совпадает с текущим поиском
    final trackNumber = _searchedTrackNumber;
    if (trackNumber != null && mounted) {
      final bookmarked = _bookmarkService.isBookmarked(trackNumber);
      if (bookmarked != _isBookmarked) {
        setState(() {
          _isBookmarked = bookmarked;
        });
      }
    }
  }

  Future<void> _refreshTracking() async {
    final trackNumber = _searchedTrackNumber;
    if (trackNumber == null || trackNumber.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _trackingService.getTrackingData(trackNumber);
    await _cacheService.set(trackNumber, result);

    if (result is TrackingSuccess &&
        result.events.isNotEmpty &&
        _bookmarkService.isBookmarked(trackNumber)) {
      await _bookmarkService.upsertBookmark(trackNumber, result.events.first.comment);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
      });
    }
  }

  Future<void> _checkBookmarkStatus() async {
    final trackNumber = _textController.text.trim();
    if (trackNumber == _searchedTrackNumber) {
      final isBookmarked = _bookmarkService.isBookmarked(trackNumber);
      if (mounted && _isBookmarked != isBookmarked) {
        setState(() => _isBookmarked = isBookmarked);
      }
    }
  }

  Future<void> _trackPackage() async {
    final trackNumber = _textController.text.trim();
    if (trackNumber.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
      _searchedTrackNumber = trackNumber;
    });

    await _checkBookmarkStatus();

    TrackingResult? result = await _cacheService.get(trackNumber);
    if (result == null) {
      result = await _trackingService.getTrackingData(trackNumber);
      await _cacheService.set(trackNumber, result);
    }

    if (result is TrackingSuccess &&
        result.events.isNotEmpty &&
        _bookmarkService.isBookmarked(trackNumber)) {
      await _bookmarkService.upsertBookmark(trackNumber, result.events.first.comment);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final trackNumber = _searchedTrackNumber;
    if (trackNumber == null || trackNumber.isEmpty) return;

    if (_isBookmarked) {
      await _bookmarkService.removeBookmark(trackNumber);
    } else {
      await _addBookmarkWithTrackingData(trackNumber);
    }

    await _checkBookmarkStatus();
  }

  Future<void> _addBookmarkWithTrackingData(String trackNumber) async {
    final cachedResult = await _cacheService.get(trackNumber);

    if (cachedResult is TrackingSuccess && cachedResult.events.isNotEmpty) {
      final lastStatus = cachedResult.events.first.comment;
      await _bookmarkService.upsertBookmark(trackNumber, lastStatus);
    } else {
      final freshResult = await _trackingService.getTrackingData(trackNumber);
      if (freshResult is TrackingSuccess && freshResult.events.isNotEmpty) {
        await _cacheService.set(trackNumber, freshResult);
        final lastStatus = freshResult.events.first.comment;
        await _bookmarkService.upsertBookmark(trackNumber, lastStatus);
      } else {
        throw Exception("Невозможно сохранить: нет данных об отправлении");
      }
    }
  }

  void _clearSearch() {
    _textController.clear();
    setState(() {
      _result = null;
      _searchedTrackNumber = null;
      _isBookmarked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshTracking,
            child: TrackingResultView(
              isLoading: _isLoading,
              result: _result,
              initialMessage: 'Введите трек-номер и нажмите поиск.',
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Трек-номер',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1.5),
                ),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchedTrackNumber != null &&
                        _searchedTrackNumber!.isNotEmpty &&
                        _searchedTrackNumber == _textController.text.trim())
                      IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: _isBookmarked
                              ? Colors.amber.shade700
                              : Colors.grey.shade600,
                        ),
                        tooltip: 'Добавить/удалить из закладок',
                        onPressed: _toggleBookmark,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          _searchedTrackNumber != null &&
                                  _searchedTrackNumber ==
                                      _textController.text.trim()
                              ? Icons.close_rounded
                              : Icons.search,
                        ),
                        onPressed: _isLoading
                            ? null
                            : (_searchedTrackNumber != null &&
                                    _searchedTrackNumber ==
                                        _textController.text.trim()
                                ? _clearSearch
                                : _trackPackage),
                      ),
                    ),
                  ],
                ),
              ),
              onSubmitted: _isLoading ? null : (_) => _trackPackage(),
              onChanged: (text) {
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}
