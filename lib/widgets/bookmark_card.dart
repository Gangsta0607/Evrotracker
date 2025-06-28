import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/bookmark_service.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;

  const BookmarkCard({super.key, 
    required this.bookmark,
    required this.onTap,
  });

  String _formatStatus(String status) {
    const keyPhrase = 'Почтовое отправление прибыло для выдачи';
    return status.startsWith(keyPhrase) ? keyPhrase : status;
  }

  Color brighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslBright = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslBright.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: brighten(theme.canvasColor, 0.05),
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя строка
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bookmark.trackNumber,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Последнее обновление:',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        DateFormat('dd.MM.yy HH:mm').format(bookmark.lastChecked),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  _formatStatus(bookmark.lastStatus),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

