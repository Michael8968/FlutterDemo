import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo/features/symptom_tracker/domain/entities/symptom_category.dart';
import 'package:flutter_demo/features/symptom_tracker/domain/entities/symptom_entry.dart';
import 'package:flutter_demo/features/symptom_tracker/domain/entities/body_part.dart';

void main() {
  group('SymptomEntry', () {
    test('should create SymptomEntry correctly', () {
      final now = DateTime.now();
      final entry = SymptomEntry(
        id: '1',
        timestamp: now,
        symptomName: '头痛',
        type: SymptomType.pain,
        severity: 5,
        bodyParts: const ['head'],
        triggers: const ['压力', '睡眠不足'],
        createdAt: now,
      );

      expect(entry.symptomName, '头痛');
      expect(entry.type, SymptomType.pain);
      expect(entry.severity, 5);
      expect(entry.severityLevel, SeverityLevel.moderate);
    });

    test('should calculate severity level correctly', () {
      expect(SeverityLevel.fromScore(1), SeverityLevel.mild);
      expect(SeverityLevel.fromScore(3), SeverityLevel.mild);
      expect(SeverityLevel.fromScore(4), SeverityLevel.moderate);
      expect(SeverityLevel.fromScore(5), SeverityLevel.moderate);
      expect(SeverityLevel.fromScore(6), SeverityLevel.severe);
      expect(SeverityLevel.fromScore(8), SeverityLevel.severe);
      expect(SeverityLevel.fromScore(9), SeverityLevel.critical);
      expect(SeverityLevel.fromScore(10), SeverityLevel.critical);
    });

    test('should format duration correctly', () {
      final now = DateTime.now();

      final entry30min = SymptomEntry(
        id: '1',
        timestamp: now,
        symptomName: '头痛',
        type: SymptomType.pain,
        severity: 5,
        durationMinutes: 30,
        createdAt: now,
      );
      expect(entry30min.durationDisplay, '30 分钟');

      final entry90min = SymptomEntry(
        id: '2',
        timestamp: now,
        symptomName: '头痛',
        type: SymptomType.pain,
        severity: 5,
        durationMinutes: 90,
        createdAt: now,
      );
      expect(entry90min.durationDisplay, '1 小时 30 分钟');

      final entry2hours = SymptomEntry(
        id: '3',
        timestamp: now,
        symptomName: '头痛',
        type: SymptomType.pain,
        severity: 5,
        durationMinutes: 120,
        createdAt: now,
      );
      expect(entry2hours.durationDisplay, '2 小时');
    });
  });

  group('SymptomTemplates', () {
    test('should have templates for all symptom types', () {
      for (final type in SymptomType.values) {
        if (type != SymptomType.other) {
          final templates = SymptomTemplates.getByType(type);
          expect(templates.isNotEmpty, true,
            reason: 'Type ${type.displayName} should have templates');
        }
      }
    });

    test('should find template by id', () {
      final headache = SymptomTemplates.findById('headache');
      expect(headache, isNotNull);
      expect(headache!.name, '头痛');
      expect(headache.type, SymptomType.pain);
    });

    test('should search templates by name', () {
      final results = SymptomTemplates.search('头');
      expect(results.isNotEmpty, true);
      expect(results.any((t) => t.name == '头痛'), true);
      expect(results.any((t) => t.name == '头晕'), true);
    });
  });

  group('BodyPart', () {
    test('should get body parts by region', () {
      final headParts = BodyPart.getByRegion(BodyRegion.head);
      expect(headParts.isNotEmpty, true);
      expect(headParts.contains(BodyPart.head), true);
      expect(headParts.contains(BodyPart.eye), true);
      expect(headParts.contains(BodyPart.throat), true);
    });

    test('should have display names for all body parts', () {
      for (final part in BodyPart.values) {
        expect(part.displayName.isNotEmpty, true);
      }
    });
  });
}
