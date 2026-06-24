import 'package:flutter_test/flutter_test.dart';
import 'package:public_memory_tracker/models/project_ledger.dart';
import 'package:public_memory_tracker/models/timeline_event.dart';

void main() {
  test('ProjectLedger parses ledger JSON shape', () {
    final project = ProjectLedger.fromJson({
      'project_id': 'delhi_dehradun_expressway',
      'title': 'Delhi-Dehradun Expressway',
      'budget_crores': 13000.0,
      'expected_completion': 'June 2025',
      'status': 'Delayed',
      'timeline': [
        {
          'date': '2026-06',
          'event_description': '72% overall physical completion noted.',
        },
      ],
    });

    expect(project.projectId, 'delhi_dehradun_expressway');
    expect(project.status.label, 'Delayed');
    expect(project.timeline, hasLength(1));
    expect(project.sortedTimeline.first.date, '2026-06');
  });

  test('TimelineEvent round-trips JSON keys', () {
    const event = TimelineEvent(
      date: '2026-06',
      eventDescription: 'Test event',
    );

    final restored = TimelineEvent.fromJson(event.toJson());
    expect(restored.date, event.date);
    expect(restored.eventDescription, event.eventDescription);
  });
}
