import 'package:flutter/material.dart';
import '../models/tracking_result.dart';

class TrackingEventCard extends StatelessWidget {
  final TrackingEvent event;
  final int index;
  final bool isFirst;
  final bool isLast;

  const TrackingEventCard({
    super.key,
    required this.event,
    required this.index,
    this.isFirst = false,
    this.isLast = false,
  });

  IconData _getIconForStatus(String status) {
    if (status.contains('Почтовое отправление выдано')) {
      return Icons.check_circle_outline_rounded;
    }
    if (status.contains('Почтовое отправление прибыло для выдачи')) {
      return Icons.inventory_2_outlined;
    }
    return Icons.local_shipping_outlined;
  }

  Color brighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslBright = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslBright.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusIcon = _getIconForStatus(event.comment);
    final isFinalStatus = event.comment.contains('Почтовое отправление выдано');

    final lineColor = Colors.grey[700];
    final iconBgColor = isFirst
        ? (isFinalStatus ? Colors.green.shade600 : theme.colorScheme.primary)
        : Colors.grey[800];
    final iconColor = Colors.white;

    final titleColor = isFirst ? Colors.white : Colors.white70;
    final subtitleColor = Colors.grey[400];
    final cardBgColor = brighten(theme.canvasColor, 0.05);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Временная шкала
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2,
                height: 4,
                color: isFirst ? Colors.transparent : lineColor,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : lineColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Контент карточки
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.comment,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: subtitleColor),
                      const SizedBox(width: 8),
                      Text(event.date, style: TextStyle(color: subtitleColor, fontSize: 14)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: subtitleColor),
                      const SizedBox(width: 8),
                      Text(event.time, style: TextStyle(color: subtitleColor, fontSize: 14)),
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
