import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrackingSkeleton extends StatelessWidget {
  const TrackingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Цвета для shimmer: base и highlight — из темы с небольшими вариациями
    final baseColor = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.6)
        : theme.colorScheme.surfaceVariant;
    final highlightColor = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
        : theme.colorScheme.surfaceVariant.withOpacity(0.7);

    // Цвета для элементов-заглушек
    final placeholderColor = isDark
        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
        : theme.colorScheme.onSurfaceVariant.withOpacity(0.1);

    const itemCount = 5;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (_, index) {
          final isFirst = index == 0;
          final isLast = index == itemCount - 1;
          return _buildPlaceholderCard(
            isFirst: isFirst,
            isLast: isLast,
            placeholderColor: placeholderColor,
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderCard({
    required bool isFirst,
    required bool isLast,
    required Color placeholderColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Временная шкала
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: placeholderColor,
                )
              else
                const SizedBox(height: 20),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: placeholderColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: placeholderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Контент карточки
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: placeholderColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: placeholderColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 20.0, color: placeholderColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 100, height: 16.0, color: placeholderColor),
                      const SizedBox(width: 16),
                      Container(width: 80, height: 16.0, color: placeholderColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
