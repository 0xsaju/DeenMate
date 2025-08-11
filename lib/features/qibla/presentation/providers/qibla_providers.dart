import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/qibla_local_storage.dart';
import '../../data/repositories/qibla_repository_impl.dart';
import '../../data/services/sensor_service.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/repositories/qibla_repository.dart';

/// Qibla Dependency Injection Providers
/// Following Clean Architecture with Riverpod 2.x

// Core Dependencies
final qiblaLocalStorageProvider = Provider<QiblaLocalStorage>((ref) {
  return QiblaLocalStorage();
});

final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

// Repository
final qiblaRepositoryProvider = Provider<QiblaRepository>((ref) {
  return QiblaRepositoryImpl(
    sensorService: ref.read(sensorServiceProvider),
    localStorage: ref.read(qiblaLocalStorageProvider),
  );
});

// Current Qibla Direction Provider
final currentQiblaDirectionProvider = FutureProvider<QiblaDirection>((ref) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getCurrentQiblaDirection();
  
  return result.fold(
    (failure) => throw failure,
    (qiblaDirection) => qiblaDirection,
  );
});

// Qibla Direction for Specific Coordinates Provider
final qiblaDirectionProvider = FutureProvider.family<QiblaDirection, Map<String, double>>((ref, coordinates) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getQiblaDirection(
    latitude: coordinates['latitude']!,
    longitude: coordinates['longitude']!,
  );
  
  return result.fold(
    (failure) => throw failure,
    (qiblaDirection) => qiblaDirection,
  );
});

// Current Sensor Data Provider
final currentSensorDataProvider = FutureProvider<SensorData>((ref) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getCurrentSensorData();
  
  return result.fold(
    (failure) => throw failure,
    (sensorData) => sensorData,
  );
});

// Sensor Availability Provider
final sensorsAvailableProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.areSensorsAvailable();
  
  return result.fold(
    (failure) => false,
    (isAvailable) => isAvailable,
  );
});

// Cached Qibla Direction Provider
final cachedQiblaDirectionProvider = FutureProvider<QiblaDirection?>((ref) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getCachedQiblaDirection();
  
  return result.fold(
    (failure) => null,
    (cachedDirection) => cachedDirection,
  );
});

// Qibla History Provider
final qiblaHistoryProvider = FutureProvider.family<List<QiblaDirection>, Map<String, DateTime>>((ref, params) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getQiblaHistory(
    fromDate: params['fromDate']!,
    toDate: params['toDate']!,
  );
  
  return result.fold(
    (failure) => throw failure,
    (history) => history,
  );
});

// Distance to Kaaba Provider
final distanceToKaabaProvider = FutureProvider.family<double, Map<String, double>>((ref, coordinates) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getDistanceToKaaba(
    latitude: coordinates['latitude']!,
    longitude: coordinates['longitude']!,
  );
  
  return result.fold(
    (failure) => throw failure,
    (distance) => distance,
  );
});

// Magnetic Declination Provider
final magneticDeclinationProvider = FutureProvider.family<double?, Map<String, double>>((ref, coordinates) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getMagneticDeclination(
    latitude: coordinates['latitude']!,
    longitude: coordinates['longitude']!,
  );
  
  return result.fold(
    (failure) => null,
    (declination) => declination,
  );
});

// Location Name Provider
final locationNameProvider = FutureProvider.family<String, Map<String, double>>((ref, coordinates) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.getLocationName(
    latitude: coordinates['latitude']!,
    longitude: coordinates['longitude']!,
  );
  
  return result.fold(
    (failure) => 'Unknown Location',
    (locationName) => locationName,
  );
});

// Qibla Accuracy Validation Provider
final qiblaAccuracyProvider = FutureProvider.family<bool, QiblaDirection>((ref, qiblaDirection) async {
  final repository = ref.read(qiblaRepositoryProvider);
  final result = await repository.validateQiblaAccuracy(qiblaDirection: qiblaDirection);
  
  return result.fold(
    (failure) => false,
    (isAccurate) => isAccurate,
  );
});

// State Notifiers

// Qibla State Notifier
final qiblaStateProvider = StateNotifierProvider<QiblaStateNotifier, QiblaState>((ref) {
  return QiblaStateNotifier(ref.read(qiblaRepositoryProvider));
});

class QiblaStateNotifier extends StateNotifier<QiblaState> {
  QiblaStateNotifier(this._repository) : super(const QiblaState.initial());

  final QiblaRepository _repository;

  Future<void> initializeSensors() async {
    try {
      state = const QiblaState.loading();
      
      final result = await _repository.initializeSensors();
      result.fold(
        (failure) => state = QiblaState.error(failure.message),
        (_) => state = const QiblaState.ready(),
      );
    } catch (e) {
      state = QiblaState.error(e.toString());
    }
  }

  Future<void> calibrateCompass() async {
    try {
      state = const QiblaState.calibrating();
      
      final result = await _repository.calibrateCompass();
      result.fold(
        (failure) => state = QiblaState.error(failure.message),
        (_) => state = const QiblaState.ready(),
      );
    } catch (e) {
      state = QiblaState.error(e.toString());
    }
  }

  Future<void> getCurrentQiblaDirection() async {
    try {
      state = const QiblaState.loading();
      
      final result = await _repository.getCurrentQiblaDirection();
      result.fold(
        (failure) => state = QiblaState.error(failure.message),
        (qiblaDirection) => state = QiblaState.loaded(qiblaDirection),
      );
    } catch (e) {
      state = QiblaState.error(e.toString());
    }
  }

  Future<void> getQiblaDirection(double latitude, double longitude) async {
    try {
      state = const QiblaState.loading();
      
      final result = await _repository.getQiblaDirection(
        latitude: latitude,
        longitude: longitude,
      );
      result.fold(
        (failure) => state = QiblaState.error(failure.message),
        (qiblaDirection) => state = QiblaState.loaded(qiblaDirection),
      );
    } catch (e) {
      state = QiblaState.error(e.toString());
    }
  }

  Future<void> clearCache() async {
    try {
      final result = await _repository.clearCache();
      result.fold(
        (failure) => state = QiblaState.error(failure.message),
        (_) => state = const QiblaState.ready(),
      );
    } catch (e) {
      state = QiblaState.error(e.toString());
    }
  }
}

// Qibla State Classes
sealed class QiblaState {
  const QiblaState();
  
  const factory QiblaState.initial() = QiblaInitial;
  const factory QiblaState.loading() = QiblaLoading;
  const factory QiblaState.calibrating() = QiblaCalibrating;
  const factory QiblaState.ready() = QiblaReady;
  const factory QiblaState.loaded(QiblaDirection qiblaDirection) = QiblaLoaded;
  const factory QiblaState.error(String message) = QiblaError;
}

class QiblaInitial extends QiblaState {
  const QiblaInitial();
}

class QiblaLoading extends QiblaState {
  const QiblaLoading();
}

class QiblaCalibrating extends QiblaState {
  const QiblaCalibrating();
}

class QiblaReady extends QiblaState {
  const QiblaReady();
}

class QiblaLoaded extends QiblaState {
  const QiblaLoaded(this.qiblaDirection);
  final QiblaDirection qiblaDirection;
}

class QiblaError extends QiblaState {
  const QiblaError(this.message);
  final String message;
}

// Qibla History State Notifier
final qiblaHistoryStateProvider = StateNotifierProvider<QiblaHistoryStateNotifier, QiblaHistoryState>((ref) {
  return QiblaHistoryStateNotifier(ref.read(qiblaRepositoryProvider));
});

class QiblaHistoryStateNotifier extends StateNotifier<QiblaHistoryState> {
  QiblaHistoryStateNotifier(this._repository) : super(const QiblaHistoryState.initial());

  final QiblaRepository _repository;

  Future<void> loadHistory(DateTime fromDate, DateTime toDate) async {
    try {
      state = const QiblaHistoryState.loading();
      
      final result = await _repository.getQiblaHistory(
        fromDate: fromDate,
        toDate: toDate,
      );
      result.fold(
        (failure) => state = QiblaHistoryState.error(failure.message),
        (history) => state = QiblaHistoryState.loaded(history),
      );
    } catch (e) {
      state = QiblaHistoryState.error(e.toString());
    }
  }

  Future<void> exportData(DateTime fromDate, DateTime toDate) async {
    try {
      state = const QiblaHistoryState.exporting();
      
      final result = await _repository.exportQiblaData(
        fromDate: fromDate,
        toDate: toDate,
      );
      result.fold(
        (failure) => state = QiblaHistoryState.error(failure.message),
        (exportData) => state = QiblaHistoryState.exported(exportData),
      );
    } catch (e) {
      state = QiblaHistoryState.error(e.toString());
    }
  }
}

// Qibla History State Classes
sealed class QiblaHistoryState {
  const QiblaHistoryState();
  
  const factory QiblaHistoryState.initial() = QiblaHistoryInitial;
  const factory QiblaHistoryState.loading() = QiblaHistoryLoading;
  const factory QiblaHistoryState.loaded(List<QiblaDirection> history) = QiblaHistoryLoaded;
  const factory QiblaHistoryState.exporting() = QiblaHistoryExporting;
  const factory QiblaHistoryState.exported(String exportData) = QiblaHistoryExported;
  const factory QiblaHistoryState.error(String message) = QiblaHistoryError;
}

class QiblaHistoryInitial extends QiblaHistoryState {
  const QiblaHistoryInitial();
}

class QiblaHistoryLoading extends QiblaHistoryState {
  const QiblaHistoryLoading();
}

class QiblaHistoryLoaded extends QiblaHistoryState {
  const QiblaHistoryLoaded(this.history);
  final List<QiblaDirection> history;
}

class QiblaHistoryExporting extends QiblaHistoryState {
  const QiblaHistoryExporting();
}

class QiblaHistoryExported extends QiblaHistoryState {
  const QiblaHistoryExported(this.exportData);
  final String exportData;
}

class QiblaHistoryError extends QiblaHistoryState {
  const QiblaHistoryError(this.message);
  final String message;
}
