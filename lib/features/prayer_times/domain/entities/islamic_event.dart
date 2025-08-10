import 'package:equatable/equatable.dart';

class IslamicEvent extends Equatable {
  const IslamicEvent({
    required this.name,
    required this.arabicName,
    required this.date,
    required this.description,
    required this.type,
    this.isImportant = false,
  });

  final String name;
  final String arabicName;
  final DateTime date;
  final String description;
  final IslamicEventType type;
  final bool isImportant;

  @override
  List<Object?> get props => [name, arabicName, date, description, type, isImportant];
}

enum IslamicEventType {
  eid,
  ramadan,
  hajj,
  ashura,
  miraj,
  mawlid,
  lailatul_qadr,
  other,
}
