import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackingBookmarkCard extends StatelessWidget {
  final String trackNumber;
  final DateTime lastChecked;
  final String lastStatus;
  final VoidCallback onTap;

  const TrackingBookmarkCard({
    super.key,
    required this.trackNumber,
    required this.lastChecked,
    required this.lastStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхний ряд: номер и дата
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Левая часть - номер трека (две строки)
                  Expanded(
                    flex: 3,
                    child: Text(
                      trackNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Правая часть - "последнее обновление:" + дата (2 строки)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'последнее обновление:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(lastChecked),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Статус в виде "чипа"
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  lastStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
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
