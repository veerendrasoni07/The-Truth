import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/project_ledger.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'timeline_view.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectLedger project;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w500,
        );
    final valueStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        );
    final budget = NumberFormat.decimalPattern('en_IN').format(project.budgetCrores);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${project.projectId}',
                        style: labelStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(status: project.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppTheme.border),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'BUDGET ENVELOPE',
                        value: '₹$budget Crore',
                        labelStyle: labelStyle,
                        valueStyle: valueStyle,
                      ),
                    ),
                    SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                    Expanded(
                      child: _MetricTile(
                        label: 'EXPECTED COMPLETION',
                        value: project.expectedCompletion,
                        labelStyle: labelStyle,
                        valueStyle: valueStyle,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            TimelineView(events: project.sortedTimeline),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}
