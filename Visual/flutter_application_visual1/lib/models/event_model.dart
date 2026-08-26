class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String category;
  final String description;
  final int reminderMinutesBefore;
  final bool isCompleted;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.category = 'Geral',
    this.description = '',
    this.reminderMinutesBefore = 30,
    this.isCompleted = false,
  });

  String get dateKey =>
      '--';

  String get formattedDate =>
      '//';

  DateTime get fullDateTime {
    final parts = time.split(':');
    int hour = 0;
    int minute = 0;
    if (parts.isNotEmpty) hour = int.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    String? category,
    String? description,
    int? reminderMinutesBefore,
    bool? isCompleted,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      description: description ?? this.description,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'category': category,
      'description': description,
      'reminderMinutesBefore': reminderMinutesBefore,
      'isCompleted': isCompleted,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '12:00',
      category: map['category'] ?? 'Geral',
      description: map['description'] ?? '',
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 30,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
