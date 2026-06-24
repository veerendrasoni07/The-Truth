import 'timeline_event.dart';

enum ProjectStatus {
  ongoing('Ongoing'),
  delayed('Delayed'),
  completed('Completed'),
  stalled('Stalled'),
  unknown('Unknown');

  const ProjectStatus(this.label);
  final String label;

  static ProjectStatus fromString(String? value) {
    return ProjectStatus.values.firstWhere(
      (s) => s.label.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => ProjectStatus.unknown,
    );
  }
}

class ProjectLedger {
  const ProjectLedger({
    required this.projectId,
    required this.title,
    required this.budgetCrores,
    required this.expectedCompletion,
    required this.status,
    required this.timeline,
  });

  final String projectId;
  final String title;
  final double budgetCrores;
  final String expectedCompletion;
  final ProjectStatus status;
  final List<TimelineEvent> timeline;

  factory ProjectLedger.fromJson(Map<String, dynamic> json) {
    final timelineJson = json['timeline'] as List<dynamic>? ?? [];
    return ProjectLedger(
      projectId: json['project_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Project',
      budgetCrores: _parseBudget(json['budget_crores']),
      expectedCompletion: json['expected_completion'] as String? ?? '—',
      status: ProjectStatus.fromString(json['status'] as String?),
      timeline: timelineJson
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseBudget(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  List<TimelineEvent> get sortedTimeline {
    final copy = List<TimelineEvent>.from(timeline);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }
}
