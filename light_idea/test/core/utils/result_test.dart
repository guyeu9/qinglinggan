import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/core/utils/result.dart';

void main() {
  group('Result', () {
    group('ResultSuccess', () {
      test('should create success result with data', () {
        final result = Result.success('test data');

        expect(result.isSuccess, true);
        expect(result.isError, false);
        expect(result.dataOrNull, 'test data');
        expect(result.errorOrNull, isNull);
      });

      test('should handle nullable data', () {
        final result = Result<String?>.success(null);

        expect(result.isSuccess, true);
        expect(result.dataOrNull, isNull);
      });
    });

    group('ResultError', () {
      test('should create error result with message', () {
        final result = Result<dynamic>.error('Something went wrong');

        expect(result.isSuccess, false);
        expect(result.isError, true);
        expect(result.errorOrNull, 'Something went wrong');
        expect(result.dataOrNull, isNull);
      });

      test('should create error result with exception', () {
        final exception = Exception('Test exception');
        final result = Result<dynamic>.error('Error', exception);

        expect(result.isError, true);
        expect(result.errorOrNull, 'Error');
        expect(result.dataOrNull, isNull);
      });
    });

    group('when', () {
      test('should call onSuccess callback on success', () {
        final result = Result.success('data');
        var successCalled = false;
        var errorCalled = false;

        result.when(
          onSuccess: (data) {
            successCalled = true;
            expect(data, 'data');
          },
          onError: (error, _) {
            errorCalled = true;
          },
        );

        expect(successCalled, true);
        expect(errorCalled, false);
      });

      test('should call onError callback on error', () {
        final result = Result<dynamic>.error('error message');
        var successCalled = false;
        var errorCalled = false;

        result.when(
          onSuccess: (data) {
            successCalled = true;
          },
          onError: (error, _) {
            errorCalled = true;
            expect(error, 'error message');
          },
        );

        expect(successCalled, false);
        expect(errorCalled, true);
      });
    });

    group('map', () {
      test('should transform success value', () {
        final result = Result.success(5);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.dataOrNull, 10);
      });

      test('should not transform error value', () {
        final result = Result<int>.error('error');
        final mapped = result.map((value) => value * 2);

        expect(mapped.isError, true);
        expect(mapped.errorOrNull, 'error');
      });
    });
  });
}
