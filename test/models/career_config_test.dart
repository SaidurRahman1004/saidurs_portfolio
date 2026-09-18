import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/career_config_model.dart';

void main() {
  group('CareerConfigModel Duration Tests', () {
    test('Calculates 6+ Months from 5 March 2026 to 18 September 2026', () {
      final startDate = DateTime(2026, 3, 5);
      final currentDate = DateTime(2026, 9, 18);

      final duration = CareerConfigModel.calculateDuration(startDate, targetDate: currentDate);
      expect(duration, '6+ Months');
    });

    test('Advances dynamically to 7+ Months on 5 October 2026', () {
      final startDate = DateTime(2026, 3, 5);
      final futureDate = DateTime(2026, 10, 5);

      final duration = CareerConfigModel.calculateDuration(startDate, targetDate: futureDate);
      expect(duration, '7+ Months');
    });

    test('Advances dynamically to 1+ Year on 5 March 2027', () {
      final startDate = DateTime(2026, 3, 5);
      final oneYearLater = DateTime(2027, 3, 5);

      final duration = CareerConfigModel.calculateDuration(startDate, targetDate: oneYearLater);
      expect(duration, '1+ Year');
    });

    test('Manual override returns custom text when auto calculation is false', () {
      final config = CareerConfigModel(
        careerStartDate: DateTime(2026, 3, 5),
        useAutoCalculation: false,
        manualText: '1+ Year of Experience',
      );

      expect(config.formattedDuration, '1+ Year of Experience');
    });

    test('Auto calculation is used when manual text is empty', () {
      final config = CareerConfigModel(
        careerStartDate: DateTime(2026, 3, 5),
        useAutoCalculation: false,
        manualText: '   ',
      );

      expect(config.formattedDuration, contains('Months'));
    });
  });
}
