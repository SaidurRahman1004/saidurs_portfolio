import 'package:cloud_firestore/cloud_firestore.dart';

class CareerConfigModel {
  final DateTime careerStartDate;
  final bool useAutoCalculation;
  final String? manualText;

  const CareerConfigModel({
    required this.careerStartDate,
    this.useAutoCalculation = true,
    this.manualText,
  });

  factory CareerConfigModel.defaultConfig() {
    return CareerConfigModel(
      careerStartDate: DateTime(2026, 3, 5), // 5 March 2026
      useAutoCalculation: true,
      manualText: null,
    );
  }

  factory CareerConfigModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return CareerConfigModel.defaultConfig();

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime(2026, 3, 5);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime(2026, 3, 5);
    }

    return CareerConfigModel(
      careerStartDate: parseDate(data['careerStartDate'] ?? data['startDate']),
      useAutoCalculation: data['useAutoCalculation'] ?? true,
      manualText: data['manualText']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'careerStartDate': Timestamp.fromDate(careerStartDate),
      'useAutoCalculation': useAutoCalculation,
      'manualText': manualText,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get formattedDuration {
    if (!useAutoCalculation && manualText != null && manualText!.trim().isNotEmpty) {
      return manualText!.trim();
    }
    return calculateDuration(careerStartDate);
  }

  static String calculateDuration(DateTime startDate, {DateTime? targetDate}) {
    final now = targetDate ?? DateTime.now();
    if (now.isBefore(startDate)) return '1 Month';

    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    if (days < 0) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years <= 0) {
      final totalMonths = months <= 0 ? 1 : months;
      return '$totalMonths+ Months';
    } else {
      if (months <= 1) {
        return '$years+ Year${years > 1 ? 's' : ''}';
      } else if (months >= 10) {
        final nextYear = years + 1;
        return '$nextYear+ Years';
      } else {
        return '$years.${(months * 10 / 12).round()}+ Years';
      }
    }
  }

  CareerConfigModel copyWith({
    DateTime? careerStartDate,
    bool? useAutoCalculation,
    String? manualText,
  }) {
    return CareerConfigModel(
      careerStartDate: careerStartDate ?? this.careerStartDate,
      useAutoCalculation: useAutoCalculation ?? this.useAutoCalculation,
      manualText: manualText ?? this.manualText,
    );
  }
}
