import 'package:flutter/material.dart';
import '../models/tracking_result.dart';
import '../services/bookmark_service.dart';
import '../widgets/tracking_result_view.dart';

class TrackingDetailsScreen extends StatefulWidget {
  final String trackNumber;
  final TrackingResult? result;

  const TrackingDetailsScreen({
    super.key,
    required this.trackNumber,
    required this.result,
  });

  @override
  State<TrackingDetailsScreen> createState() => _TrackingDetailsScreenState();
}

class _TrackingDetailsScreenState extends State<TrackingDetailsScreen> {
  final _bookmarkService = BookmarkService();
  bool _isBookmarked = true;

  Future<void> _removeBookmark() async {
    await _bookmarkService.removeBookmark(widget.trackNumber);
    if (mounted) {
      setState(() => _isBookmarked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Закладка "${widget.trackNumber}" удалена')),
      );
      Navigator.pop(context, true); // Возвращаем флаг удаления
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackNumber),
        actions: [
          if (_isBookmarked)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Удалить из закладок',
              onPressed: _removeBookmark,
            ),
        ],
      ),
      body: result == null
          ? const Center(child: Text('Нет данных об отслеживании.'))
          : TrackingResultView(
              isLoading: false,
              result: result,
              initialMessage: 'Нет данных для отображения.',
            ),
    );
  }
}