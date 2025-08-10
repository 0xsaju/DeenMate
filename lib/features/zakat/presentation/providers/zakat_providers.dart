import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/pdf_generator_service.dart';
import '../../data/datasources/metal_prices_api.dart';
import '../../data/datasources/zakat_local_storage.dart';
import '../../data/repositories/zakat_repository_impl.dart';
import '../../domain/repositories/zakat_repository.dart';
import '../../domain/usecases/calculate_zakat_usecase.dart';
import 'zakat_calculator_notifier.dart';

part 'zakat_providers.freezed.dart';

// Basic providers without code generation for now
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final metalPricesApiProvider = Provider<MetalPricesApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MetalPricesApi(dio);
});

final zakatLocalStorageProvider = Provider<ZakatLocalStorage>((ref) {
  return ZakatLocalStorage();
});

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

final zakatRepositoryProvider = Provider<ZakatRepository>((ref) {
  final metalPricesApi = ref.watch(metalPricesApiProvider);
  final localStorage = ref.watch(zakatLocalStorageProvider);
  final pdfGenerator = ref.watch(pdfGeneratorServiceProvider);
  final connectivity = ref.watch(connectivityProvider);
  final uuid = ref.watch(uuidProvider);

  return ZakatRepositoryImpl(
    metalPricesApi: metalPricesApi,
    localStorage: localStorage,
    pdfGenerator: pdfGenerator,
    connectivity: connectivity,
    uuid: uuid,
  );
});

final calculateZakatUsecaseProvider = Provider<CalculateZakatUsecase>((ref) {
  final repository = ref.watch(zakatRepositoryProvider);
  return CalculateZakatUsecase(repository);
});

// State notifier providers
final zakatCalculatorNotifierProvider = StateNotifierProvider<ZakatCalculatorNotifier, ZakatCalculatorState>((ref) {
  final usecase = ref.watch(calculateZakatUsecaseProvider);
  final repository = ref.watch(zakatRepositoryProvider);
  return ZakatCalculatorNotifier(usecase, repository);
});

final metalPricesNotifierProvider = StateNotifierProvider<MetalPricesNotifier, MetalPricesState>((ref) {
  final api = ref.watch(metalPricesApiProvider);
  return MetalPricesNotifier(api);
});

// Metal prices state notifier
class MetalPricesNotifier extends StateNotifier<MetalPricesState> {
  final MetalPricesApi _api;
  
  MetalPricesNotifier(this._api) : super(const MetalPricesState.loading());
  
  Future<void> fetchMetalPrices() async {
    state = const MetalPricesState.loading();
    try {
      final prices = await _api.getMetalPrices();
      state = MetalPricesState.loaded(prices);
    } catch (e) {
      state = MetalPricesState.error(e.toString());
    }
  }
}

// Metal prices state
@freezed
class MetalPricesState with _$MetalPricesState {
  const factory MetalPricesState.loading() = _Loading;
  const factory MetalPricesState.loaded(Map<String, double> prices) = _Loaded;
  const factory MetalPricesState.error(String message) = _Error;
}