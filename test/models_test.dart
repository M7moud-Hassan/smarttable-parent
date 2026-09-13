import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartble_parent/core/enums/attendance_status.dart';
import 'package:smartble_parent/core/enums/note_type.dart';
import 'package:smartble_parent/features/parent/data/models/behavior_model.dart';
import 'package:smartble_parent/features/parent/data/models/exam_model.dart';
import 'package:smartble_parent/features/parent/data/models/parent_model.dart';
import 'package:smartble_parent/features/parent/data/models/student_model.dart';

/// ينزع علامات عزل الاتجاه ليُقارَن النصّ بمحتواه لا بتغليفه.
String _bare(String text) => text.replaceAll(RegExp('[\u2066\u2068\u2069]'), '');

void main() {
  group('ParentUser', () {
    const user = ParentUser(id: 'p1', name: 'أبو عبدالرحمن الحربي', phone: '0551234567');

    test('يعرض رقم الجوال بصيغة الشاشة', () {
      expect(_bare(user.displayPhone), '+966 55 123 4567');
    });

    test('يعزل الرقم عن اتجاه الفقرة العربية', () {
      // بلا العزل ينقلب «+966 55 123 4567» إلى «4567 123 55 966+».
      expect(user.displayPhone, startsWith('\u2066'));
      expect(user.displayPhone, endsWith('\u2069'));
    });

    test('يقنّع الرقم كما في شاشة رمز التحقق', () {
      expect(_bare(user.maskedPhone), '055****567');
    });

    test('يترك الرقم كما هو إذا لم يكن عشر خانات', () {
      const short = ParentUser(id: 'p1', name: 'اسم', phone: '0551');
      // الرقم الناقص يعود كما هو بلا تنسيق ولا علامات عزل.
      expect(short.displayPhone, '0551');
      expect(short.maskedPhone, '0551');
    });
  });

  group('Student', () {
    const student = Student(
      id: 's1',
      name: 'عبدالرحمن محمد الحربي',
      grade: 'الصف الثاني متوسط',
      section: 'فصل 1',
      school: 'متوسطة الأمير سلطان',
    );

    test('يبني سطر الصف كما في التصميم', () {
      expect(student.classLabel, 'الصف الثاني متوسط — فصل 1');
    });

    test('يأخذ الاسم الأول حين لا يُرسل اسم مختصر', () {
      expect(student.firstName, 'عبدالرحمن');
    });
  });

  group('Exam', () {
    Exam exam(int daysAway) => Exam(
          id: 'e',
          subject: 'الرياضيات',
          dayNumber: '17',
          monthName: 'رمضان',
          weekday: 'الأحد',
          from: '07:00',
          to: '08:30',
          place: 'قاعة 3',
          daysAway: daysAway,
        );

    test('يعزل مدى وقت الاختبار', () {
      expect(exam(3).timeLabel, 'الأحد · \u206607:00 - 08:30\u2069');
    });

    test('يصوغ العدّاد بصيغة عربية صحيحة', () {
      expect(exam(0).countdownLabel, 'اليوم');
      expect(exam(1).countdownLabel, 'غداً');
      expect(exam(5).countdownLabel, 'بعد 5 أيام');
      expect(exam(12).countdownLabel, 'بعد 12 يوماً');
    });
  });

  group('BehaviorStatistics', () {
    test('توزّع النسبة على مئة كاملة بلا كسر ضائع', () {
      const stats = BehaviorStatistics(
        total: 7,
        positive: 4,
        needsWork: 3,
        weeks: [],
      );
      expect(stats.positivePercent, 57);
      expect(stats.needsWorkPercent, 43);
      expect(stats.positivePercent + stats.needsWorkPercent, 100);
    });

    test('لا تقسم على صفر حين لا ملاحظات', () {
      const empty = BehaviorStatistics(
        total: 0,
        positive: 0,
        needsWork: 0,
        weeks: [],
      );
      expect(empty.positivePercent, 0);
    });
  });

  group('الحالات المشتركة', () {
    test('لكل حالة مواظبة لون ونصّ', () {
      for (final status in AttendanceStatus.values) {
        expect(status.label, isNotEmpty);
        expect(status.color, isA<Color>());
      }
    });

    test('لكل نوع ملاحظة سلوك لون خلفية ولون نصّ', () {
      for (final type in BehaviorNoteType.values) {
        expect(type.label, isNotEmpty);
        expect(type.background, isNot(type.foreground));
      }
    });
  });
}
