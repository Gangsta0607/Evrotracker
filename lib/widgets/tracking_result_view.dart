import 'package:flutter/material.dart';
import '../models/tracking_result.dart';
import 'tracking_event_card.dart';
import 'tracking_skeleton.dart';
import 'dart:async';

class TrackingResultView extends StatelessWidget {
  final bool isLoading;
  final TrackingResult? result;
  final String? initialMessage;

  const TrackingResultView({
    super.key,
    required this.isLoading,
    this.result,
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← вот сюда
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: TrackingSkeleton(),
      );
    }
    Future.delayed(Duration(seconds: 5));
    if (result is TrackingSuccess) {
      final events = (result as TrackingSuccess).events;
      if (events.isEmpty) {
        return _buildInfoMessage(
          icon: Icons.info_outline,
          message: 'Информация об отслеживании не найдена.',
        );
      }

      final scrollController = ScrollController();

      return Scrollbar(
        controller: scrollController,
        radius: const Radius.circular(8),
        thickness: 6,
        thumbVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: List.generate(events.length, (index) {
              final event = events[index];
              return TrackingEventCard(
                event: event,
                index: index,
                isFirst: index == 0,
                isLast: index == events.length - 1,
              );
            }),
          ),
        ),
      );
    } else if (result is TrackingFailure) {
      return _buildInfoMessage(
        icon: Icons.error_outline,
        message: 'Ошибка: ${(result as TrackingFailure).message}',
        color: Colors.redAccent,
      );
    } else {
      return _buildInfoMessage(
        icon: Icons.search,
        message: initialMessage ?? 'Здесь будут результаты отслеживания.',
        color: theme.colorScheme.primary,
      );
    }
  }

  Widget _buildInfoMessage({
    required IconData icon,
    required String message,
    Color color = Colors.grey,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
