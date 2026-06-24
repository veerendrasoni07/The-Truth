class TimelineEvent {
  const TimelineEvent({
    required this.date,
    required this.eventDescription,
  });

  final String date;
  final String eventDescription;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      date: json['date'] as String? ?? '',
      eventDescription: json['event_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'event_description': eventDescription,
      };
}
