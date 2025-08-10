import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';

import 'location.dart';
import 'prayer_tracking.dart';
import 'prayer_calculation_settings.dart';
import 'athan_settings.dart';
import 'calculation_method.dart';

/// Prayer time entity representing Islamic prayer times for a specific date and location
class PrayerTimes extends Equatable {
  const PrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.location,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.calculationMethod,
    required this.metadata,
    this.lastUpdated,
  });

  final DateTime date;
  final String hijriDate;
  final Location location;
  final PrayerTime fajr;
  final PrayerTime sunrise;
  final PrayerTime dhuhr;
  final PrayerTime asr;
  final PrayerTime maghrib;
  final PrayerTime isha;
  final PrayerTime midnight;
  final String calculationMethod;
  final Map<String, dynamic> metadata;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [
        date,
        hijriDate,
        location,
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        midnight,
        calculationMethod,
        metadata,
        lastUpdated,
      ];

  PrayerTimes copyWith({
    DateTime? date,
    String? hijriDate,
    Location? location,
    PrayerTime? fajr,
    PrayerTime? sunrise,
    PrayerTime? dhuhr,
    PrayerTime? asr,
    PrayerTime? maghrib,
    PrayerTime? isha,
    PrayerTime? midnight,
    String? calculationMethod,
    Map<String, dynamic>? metadata,
    DateTime? lastUpdated,
  }) {
    return PrayerTimes(
      date: date ?? this.date,
      hijriDate: hijriDate ?? this.hijriDate,
      location: location ?? this.location,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      midnight: midnight ?? this.midnight,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hijriDate': hijriDate,
        'location': location.toJson(),
        'fajr': fajr.toJson(),
        'sunrise': sunrise.toJson(),
        'dhuhr': dhuhr.toJson(),
        'asr': asr.toJson(),
        'maghrib': maghrib.toJson(),
        'isha': isha.toJson(),
        'midnight': midnight.toJson(),
        'calculationMethod': calculationMethod,
        'metadata': metadata,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      date: DateTime.parse(json['date'] as String),
      hijriDate: json['hijriDate'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      fajr: PrayerTime.fromJson(json['fajr'] as Map<String, dynamic>),
      sunrise: PrayerTime.fromJson(json['sunrise'] as Map<String, dynamic>),
      dhuhr: PrayerTime.fromJson(json['dhuhr'] as Map<String, dynamic>),
      asr: PrayerTime.fromJson(json['asr'] as Map<String, dynamic>),
      maghrib: PrayerTime.fromJson(json['maghrib'] as Map<String, dynamic>),
      isha: PrayerTime.fromJson(json['isha'] as Map<String, dynamic>),
      midnight: PrayerTime.fromJson(json['midnight'] as Map<String, dynamic>),
      calculationMethod: json['calculationMethod'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
    );
  }
}

/// Individual prayer time with status and formatting
class PrayerTime extends Equatable {
  const PrayerTime({
    required this.name,
    required this.time,
    required this.status,
    this.isCompleted = false,
    this.notes,
  });

  final String name;
  final DateTime time;
  final PrayerStatus status;
  final bool isCompleted;
  final String? notes;

  @override
  List<Object?> get props => [name, time, status, isCompleted, notes];

  PrayerTime copyWith({
    String? name,
    DateTime? time,
    PrayerStatus? status,
    bool? isCompleted,
    String? notes,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time.toIso8601String(),
        'status': status.name,
        'isCompleted': isCompleted,
        'notes': notes,
      };

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'] as String,
      time: DateTime.parse(json['time'] as String),
      status: PrayerStatus.values.firstWhere((e) => e.name == json['status']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Enum for prayer status
enum PrayerStatus {
  upcoming,
  current,
  completed,
  missed,
  inProgress,
}

/// Prayer names in different languages
class PrayerNames {
  static const Map<String, String> arabic = {
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
    'midnight': 'منتصف الليل',
  };

  static const Map<String, String> english = {
    'fajr': 'Fajr',
    'sunrise': 'Sunrise',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'midnight': 'Midnight',
  };

  static const Map<String, String> bengali = {
    'fajr': 'ফজর',
    'sunrise': 'সূর্যোদয়',
    'dhuhr': 'যুহর',
    'asr': 'আসর',
    'maghrib': 'মাগরিব',
    'isha': 'ইশা',
    'midnight': 'মধ্যরাত',
  };
}

// Extension methods for PrayerTimes
extension PrayerTimesExtension on PrayerTimes {
  /// Get all prayer times as a list
  List<PrayerTime> get allPrayers => [fajr, dhuhr, asr, maghrib, isha];

  /// Get current prayer based on current time
  PrayerTime? get currentPrayer {
    final now = DateTime.now();
    final prayers = [fajr, dhuhr, asr, maghrib, isha];
    
    for (final prayer in prayers) {
      if (prayer.status == PrayerStatus.current) {
        return prayer;
      }
    }
    return null;
  }

  /// Get next prayer based on current time
  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    final prayers = [fajr, dhuhr, asr, maghrib, isha];
    
    for (final prayer in prayers) {
      if (prayer.status == PrayerStatus.upcoming) {
        return prayer;
      }
    }
    return null;
  }

  /// Check if it's currently night time (between Isha and Fajr)
  bool get isNightTime {
    final now = DateTime.now();
    return now.isAfter(isha.time) && now.isBefore(fajr.time);
  }

  /// Get all prayer times for today
  List<PrayerTime> get todayPrayers => [fajr, dhuhr, asr, maghrib, isha];

  /// Get time until next prayer
  Duration get timeUntilNextPrayer {
    final nextPrayer = this.nextPrayer;
    if (nextPrayer == null) return Duration.zero;
    return nextPrayer.time.difference(DateTime.now());
  }
}

// Extension methods for PrayerTime
extension PrayerTimeExtension on PrayerTime {
  /// Check if prayer time has passed
  bool get hasPassed => DateTime.now().isAfter(time);

  /// Check if prayer is currently active
  bool get isActive => status == PrayerStatus.current;

  /// Get formatted time string
  String getFormattedTime([bool use24Hour = true]) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Get time until this prayer
  Duration get timeUntil {
    final now = DateTime.now();
    return time.difference(now);
  }
}
