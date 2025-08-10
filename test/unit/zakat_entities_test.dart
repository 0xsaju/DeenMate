import 'package:deen_mate/features/zakat/domain/entities/zakat_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZakatResult Tests', () {
    test('should create ZakatResult with correct values', () {
      final result = ZakatResult(
        totalZakatableAmount: 10000,
        totalZakat: 250,
        nisabThreshold: 5000,
        isZakatDue: true,
        breakdown: {'cash': 5000.0, 'gold': 5000.0},
        calculationDate: DateTime(2024),
      );

      expect(result.totalZakatableAmount, 10000.0);
      expect(result.totalZakat, 250.0);
      expect(result.nisabThreshold, 5000.0);
      expect(result.isZakatDue, true);
      expect(result.breakdown['cash'], 5000.0);
      expect(result.breakdown['gold'], 5000.0);
    });

    test('should create ZakatCalculation with correct values', () {
      final zakatResult = ZakatResult(
        totalZakatableAmount: 10000,
        totalZakat: 250,
        nisabThreshold: 5000,
        isZakatDue: true,
        breakdown: {'cash': 5000.0, 'gold': 5000.0},
        calculationDate: DateTime(2024),
      );

      final calculation = ZakatCalculation(
        id: 'test-id',
        result: zakatResult,
        createdAt: DateTime(2024),
        userId: 'user-123',
        notes: 'Test calculation',
      );

      expect(calculation.id, 'test-id');
      expect(calculation.result, zakatResult);
      expect(calculation.userId, 'user-123');
      expect(calculation.notes, 'Test calculation');
    });

    test('should create ValidationError with correct values', () {
      const error = ValidationError(
        field: 'cash',
        message: 'Cash amount is required',
      );

      expect(error.field, 'cash');
      expect(error.message, 'Cash amount is required');
    });
  });
}
