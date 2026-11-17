import 'package:equatable/equatable.dart';

/// شاشة «إحصاءات ابني» — حصيلة كل ما سجّلته المدرسة عن الطالب.
///
/// نداء واحد (`stats/`) يردّ كل ما تعرضه الشاشة. وهذا مقصود: الحصيلة تُقرأ
/// دفعةً واحدة، ولو جُمعت من نداءات المواظبة والسلوك والإجراءات كلٌّ على حدة
/// لرأى وليّ الأمر أقسام الشاشة تصل متفرّقة، ولاختلف مدى كل رقم عن أخيه حين
/// يتأخّر نداء ويسبق آخر.
///
/// والأرقام تصل محسوبة من الخادم بالدوالّ التي تحسبها بها شاشة المدرسة
/// نفسها، فلا يُحسب هنا شيء: ما يُبنى في التطبيق يختلف عمّا في كشف المدرسة
/// عند أوّل حالة حدّية، ووليّ الأمر يسأل المدرسة عن رقمٍ رآه عندنا.
///
/// وما يحتاج لغةً عربية — اللافتات والجُمل والتقديرات — يصل نصًّا من الخادم:
/// «أكثر أيام غيابه: الأحد» جملةٌ تُبنى من بياناتٍ لا يملكها التطبيق.

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ??
      double.tryParse(value?.toString() ?? '')?.round() ??
      0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _doubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _text(dynamic value) => value?.toString() ?? '';

List<Map<String, dynamic>> _rows(dynamic value) =>
    ((value as List?) ?? []).whereType<Map<String, dynamic>>().toList();

/// فترة في شريط الشاشة. مفتاحها يفهمه الخادم، فلا يحسب التطبيق تاريخاً.
class StatsPeriodOption extends Equatable {
  const StatsPeriodOption({required this.key, required this.label});

  final String key;
  final String label;

  factory StatsPeriodOption.fromJson(Map<String, dynamic> json) =>
      StatsPeriodOption(key: _text(json['key']), label: _text(json['label']));

  @override
  List<Object?> get props => [key, label];
}

/// الفترة المعروضة ومداها — والخيارات تأتي من الخادم لا من قائمةٍ هنا.
class StatsPeriod extends Equatable {
  const StatsPeriod({
    required this.key,
    required this.label,
    required this.options,
  });

  final String key;

  /// «من 1448/2/5 إلى 1448/6/6».
  final String label;

  final List<StatsPeriodOption> options;

  factory StatsPeriod.fromJson(Map<String, dynamic> json) => StatsPeriod(
        key: _text(json['key']),
        label: _text(json['label']),
        options:
            _rows(json['options']).map(StatsPeriodOption.fromJson).toList(),
      );

  @override
  List<Object?> get props => [key, label, options];
}

/// بطاقة من البطاقات الأربع التي تُقرأ أولاً.
class HeadlineStat extends Equatable {
  const HeadlineStat({
    required this.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.tone,
    required this.hint,
  });

  final String key;
  final String title;

  /// رقمٌ أو تقدير («ممتاز») — فنصٌّ لا عدد.
  final String value;

  /// «%» أو «يوم» أو «من 100»، وقد يكون فارغاً.
  final String unit;

  /// `good` أو `warn` أو `bad` — الخادم يقرّر والشاشة تلوّن، فالحدّ يُقال
  /// مرةً واحدة في موضع واحد.
  final String tone;

  final String hint;

  factory HeadlineStat.fromJson(Map<String, dynamic> json) => HeadlineStat(
        key: _text(json['key']),
        title: _text(json['title']),
        value: _text(json['value']),
        unit: _text(json['unit']),
        tone: _text(json['tone']),
        hint: _text(json['hint']),
      );

  @override
  List<Object?> get props => [key, title, value, unit, tone, hint];
}

/// تمييز الغياب: يومٌ كامل أم حصصٌ متفرّقة.
class AbsenceSplit extends Equatable {
  const AbsenceSplit({
    required this.absentDays,
    required this.fullDay,
    required this.sessionDays,
    required this.sessions,
  });

  /// أيام الغياب كلّها = الكامل + أيام غياب الحصص.
  final int absentDays;
  final int fullDay;
  final int sessionDays;

  /// مجموع الحصص المتغيَّب عنها في أيام غياب الحصص وحدها.
  final int sessions;

  factory AbsenceSplit.fromJson(Map<String, dynamic> json) => AbsenceSplit(
        absentDays: _int(json['absent_days']),
        fullDay: _int(json['full_day']),
        sessionDays: _int(json['session_days']),
        sessions: _int(json['sessions']),
      );

  @override
  List<Object?> get props => [absentDays, fullDay, sessionDays, sessions];
}

/// تمييز التأخّر: عن الطابور أم عن حصة.
class LatenessSplit extends Equatable {
  const LatenessSplit({
    required this.lateDays,
    required this.morningDays,
    required this.sessionDays,
    required this.sessions,
  });

  final int lateDays;
  final int morningDays;
  final int sessionDays;
  final int sessions;

  factory LatenessSplit.fromJson(Map<String, dynamic> json) => LatenessSplit(
        lateDays: _int(json['late_days']),
        morningDays: _int(json['morning_days']),
        sessionDays: _int(json['session_days']),
        sessions: _int(json['sessions']),
      );

  @override
  List<Object?> get props => [lateDays, morningDays, sessionDays, sessions];
}

/// أطول غياب متّصل — لا يصل أصلاً حين لا يتجاوز يوماً واحداً.
class AbsenceStreak extends Equatable {
  const AbsenceStreak({
    required this.days,
    required this.fromHijri,
    required this.toHijri,
  });

  final int days;
  final String fromHijri;
  final String toHijri;

  factory AbsenceStreak.fromJson(Map<String, dynamic> json) => AbsenceStreak(
        days: _int(json['days']),
        fromHijri: _text(json['from_hijri']),
        toHijri: _text(json['to_hijri']),
      );

  @override
  List<Object?> get props => [days, fromHijri, toHijri];
}

/// يوم من أيام الأسبوع وما وقع فيه — ولا يصل يومٌ لا رصد فيه أصلاً.
class WeekdayRow extends Equatable {
  const WeekdayRow({
    required this.day,
    required this.trackedDays,
    required this.absent,
    required this.late,
  });

  final String day;
  final int trackedDays;
  final int absent;
  final int late;

  factory WeekdayRow.fromJson(Map<String, dynamic> json) => WeekdayRow(
        day: _text(json['day']),
        trackedDays: _int(json['tracked_days']),
        absent: _int(json['absent']),
        late: _int(json['late']),
      );

  @override
  List<Object?> get props => [day, trackedDays, absent, late];
}

/// شهر هجريّ ونسبة الحضور فيه.
class AttendanceMonth extends Equatable {
  const AttendanceMonth({
    required this.label,
    required this.trackedDays,
    required this.absent,
    required this.late,
    required this.rate,
  });

  final String label;
  final int trackedDays;
  final int absent;
  final int late;
  final double rate;

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) =>
      AttendanceMonth(
        label: _text(json['label']),
        trackedDays: _int(json['tracked_days']),
        absent: _int(json['absent']),
        late: _int(json['late']),
        rate: _double(json['rate']),
      );

  @override
  List<Object?> get props => [label, trackedDays, absent, late, rate];
}

/// قسم المواظبة كاملاً.
class AttendanceStats extends Equatable {
  const AttendanceStats({
    required this.present,
    required this.absent,
    required this.late,
    required this.permission,
    required this.trackedDays,
    required this.rate,
    required this.absence,
    required this.lateness,
    required this.unexcusedDays,
    required this.excusedDays,
    required this.byWeekday,
    required this.months,
    this.longestAbsence,
    this.classAverageRate,
  });

  final int present;
  final int absent;
  final int late;
  final int permission;

  /// الأيام التي رُصد فيها شيء — وهي مقام النسبة.
  final int trackedDays;

  final double rate;
  final AbsenceSplit absence;
  final LatenessSplit lateness;
  final int unexcusedDays;
  final int excusedDays;
  final List<WeekdayRow> byWeekday;
  final List<AttendanceMonth> months;
  final AbsenceStreak? longestAbsence;

  /// متوسّط حضور الفصل — مقارنةٌ لا ترتيب، و`null` حين لا فصل للطالب.
  final double? classAverageRate;

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      AttendanceStats(
        present: _int(json['present']),
        absent: _int(json['absent']),
        late: _int(json['late']),
        permission: _int(json['permission']),
        trackedDays: _int(json['tracked_days']),
        rate: _double(json['rate']),
        absence: AbsenceSplit.fromJson(
            (json['absence'] as Map<String, dynamic>?) ?? const {}),
        lateness: LatenessSplit.fromJson(
            (json['lateness'] as Map<String, dynamic>?) ?? const {}),
        unexcusedDays: _int(json['unexcused_days']),
        excusedDays: _int(json['excused_days']),
        longestAbsence: json['longest_absence'] == null
            ? null
            : AbsenceStreak.fromJson(
                json['longest_absence'] as Map<String, dynamic>),
        byWeekday: _rows(json['by_weekday']).map(WeekdayRow.fromJson).toList(),
        months: _rows(json['months']).map(AttendanceMonth.fromJson).toList(),
        classAverageRate: _doubleOrNull(json['class_average_rate']),
      );

  @override
  List<Object?> get props => [
        present,
        absent,
        late,
        permission,
        trackedDays,
        rate,
        absence,
        lateness,
        unexcusedDays,
        excusedDays,
        longestAbsence,
        byWeekday,
        months,
        classAverageRate,
      ];
}

/// كودُ ملاحظةٍ وما حُسم به من درجة المواظبة.
class DeductionRow extends Equatable {
  const DeductionRow({
    required this.code,
    required this.label,
    required this.occurrences,
    required this.deducted,
  });

  final String code;
  final String label;
  final int occurrences;
  final int deducted;

  factory DeductionRow.fromJson(Map<String, dynamic> json) => DeductionRow(
        code: _text(json['code']),
        label: _text(json['label']),
        occurrences: _int(json['occurrences']),
        deducted: _int(json['deducted']),
      );

  @override
  List<Object?> get props => [code, label, occurrences, deducted];
}

/// درجة المواظبة وما حُسم منها، لكل كودٍ على حدة.
class PerseveranceStats extends Equatable {
  const PerseveranceStats({
    required this.grade,
    required this.totalDeducted,
    required this.rows,
    required this.scope,
  });

  final int grade;
  final int totalDeducted;
  final List<DeductionRow> rows;

  /// «الفصل الدراسي الجاري» — مدى الدرجة لا مدى الشاشة: عدّاد الحسم تراكميّ
  /// من بداية الفصل، فيُقال مداه كي لا يُقرأ تحت فترة الشاشة.
  final String scope;

  factory PerseveranceStats.fromJson(Map<String, dynamic> json) =>
      PerseveranceStats(
        grade: _int(json['grade']),
        totalDeducted: _int(json['total_deducted']),
        rows: _rows(json['rows']).map(DeductionRow.fromJson).toList(),
        scope: _text(json['scope']),
      );

  @override
  List<Object?> get props => [grade, totalDeducted, rows, scope];
}

/// ملاحظة تكرّرت — «تأخر عن الحصة × 4».
class TopNote extends Equatable {
  const TopNote({
    required this.title,
    required this.noteType,
    required this.points,
    required this.total,
  });

  final String title;

  /// `positive` أو `negative`.
  final String noteType;

  final int points;
  final int total;

  bool get isPositive => noteType == 'positive';

  factory TopNote.fromJson(Map<String, dynamic> json) => TopNote(
        title: _text(json['title']),
        noteType: _text(json['note_type']),
        points: _int(json['points']),
        total: _int(json['total']),
      );

  @override
  List<Object?> get props => [title, noteType, points, total];
}

/// شهر هجريّ وملاحظاته.
class BehaviorMonth extends Equatable {
  const BehaviorMonth({
    required this.label,
    required this.positive,
    required this.negative,
  });

  final String label;
  final int positive;
  final int negative;

  int get total => positive + negative;

  factory BehaviorMonth.fromJson(Map<String, dynamic> json) => BehaviorMonth(
        label: _text(json['label']),
        positive: _int(json['positive']),
        negative: _int(json['negative']),
      );

  @override
  List<Object?> get props => [label, positive, negative];
}

/// قسم السلوك.
class BehaviorStats extends Equatable {
  const BehaviorStats({
    required this.positive,
    required this.negative,
    required this.notes,
    required this.records,
    required this.points,
    required this.band,
    required this.bandKey,
    required this.topNotes,
    required this.months,
  });

  final int positive;
  final int negative;
  final int notes;
  final int records;
  final int points;

  /// «ممتاز» — تقديرٌ يصل محسوباً بحدود المدرسة نفسها.
  final String band;

  final String bandKey;
  final List<TopNote> topNotes;
  final List<BehaviorMonth> months;

  factory BehaviorStats.fromJson(Map<String, dynamic> json) => BehaviorStats(
        positive: _int(json['positive']),
        negative: _int(json['negative']),
        notes: _int(json['notes']),
        records: _int(json['records']),
        points: _int(json['points']),
        band: _text(json['band']),
        bandKey: _text(json['band_key']),
        topNotes: _rows(json['top_notes']).map(TopNote.fromJson).toList(),
        months: _rows(json['months']).map(BehaviorMonth.fromJson).toList(),
      );

  @override
  List<Object?> get props => [
        positive,
        negative,
        notes,
        records,
        points,
        band,
        bandKey,
        topNotes,
        months,
      ];
}

/// صفٌّ معنون بعدد — يتكرّر في الأعذار والإجراءات والمشاركة.
class LabelledCount extends Equatable {
  const LabelledCount({required this.label, required this.total});

  final String label;
  final int total;

  factory LabelledCount.fromJson(Map<String, dynamic> json) => LabelledCount(
        label: _text(json['label']),
        total: _int(json['total']),
      );

  @override
  List<Object?> get props => [label, total];
}

/// الأعذار التي أرسلها وليّ الأمر، وما صنعته الإدارة بها.
class ExcusesStats extends Equatable {
  const ExcusesStats({required this.total, required this.rows});

  final int total;
  final List<LabelledCount> rows;

  factory ExcusesStats.fromJson(Map<String, dynamic> json) => ExcusesStats(
        total: _int(json['total']),
        rows: _rows(json['rows']).map(LabelledCount.fromJson).toList(),
      );

  @override
  List<Object?> get props => [total, rows];
}

/// الإجراءات الإدارية — وما ينتظر ردّ وليّ الأمر منها.
class ProceduresStats extends Equatable {
  const ProceduresStats({
    required this.total,
    required this.awaitingResponse,
    required this.rows,
  });

  final int total;

  /// ما لم يردّ عليه بعد — وهو الوحيد هنا الذي يطلب منه عملاً.
  final int awaitingResponse;

  final List<LabelledCount> rows;

  factory ProceduresStats.fromJson(Map<String, dynamic> json) =>
      ProceduresStats(
        total: _int(json['total']),
        awaitingResponse: _int(json['awaiting_response']),
        rows: _rows(json['rows']).map(LabelledCount.fromJson).toList(),
      );

  @override
  List<Object?> get props => [total, awaitingResponse, rows];
}

/// مشاركة الطالب في «السؤال السريع» داخل الحصة.
class ParticipationStats extends Equatable {
  const ParticipationStats({
    required this.picked,
    required this.rated,
    required this.rows,
    this.understoodRate,
  });

  /// كم مرّة اختاره المعلّم.
  final int picked;

  /// وكم مرّة قُيّم بعد اختياره.
  final int rated;

  /// `null` حين لم يُقيَّم بعد، فلا تُعرض نسبةٌ مقامها صفر.
  final double? understoodRate;

  final List<LabelledCount> rows;

  factory ParticipationStats.fromJson(Map<String, dynamic> json) =>
      ParticipationStats(
        picked: _int(json['picked']),
        rated: _int(json['rated']),
        understoodRate: _doubleOrNull(json['understood_rate']),
        rows: _rows(json['rows']).map(LabelledCount.fromJson).toList(),
      );

  @override
  List<Object?> get props => [picked, rated, understoodRate, rows];
}

/// الحالات الصحية المسجّلة — وصفٌ قائم لا حدثٌ في فترة، فلا مدى لها.
class HealthStats extends Equatable {
  const HealthStats({required this.total, required this.names});

  final int total;
  final List<String> names;

  factory HealthStats.fromJson(Map<String, dynamic> json) => HealthStats(
        total: _int(json['total']),
        names:
            ((json['names'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  @override
  List<Object?> get props => [total, names];
}

/// الاختبارات القادمة وأقربها.
class ExamsStats extends Equatable {
  const ExamsStats({
    required this.upcoming,
    this.nextSubject,
    this.nextCountdown,
    this.nextDate,
  });

  final int upcoming;
  final String? nextSubject;

  /// «بعد 3 أيام».
  final String? nextCountdown;

  /// «الأحد 1448/5/7».
  final String? nextDate;

  factory ExamsStats.fromJson(Map<String, dynamic> json) {
    final next = json['next'] as Map<String, dynamic>?;
    return ExamsStats(
      upcoming: _int(json['upcoming']),
      nextSubject: next == null ? null : _text(next['subject']),
      nextCountdown: next == null ? null : _text(next['countdown']),
      nextDate: next == null ? null : _text(next['full_date']),
    );
  }

  @override
  List<Object?> get props => [upcoming, nextSubject, nextCountdown, nextDate];
}

/// كل إحصاءات الابن في المدى المطلوب.
class StudentStats extends Equatable {
  const StudentStats({
    required this.studentName,
    required this.period,
    required this.headline,
    required this.highlights,
    required this.attendance,
    required this.perseverance,
    required this.behavior,
    required this.excuses,
    required this.procedures,
    required this.participation,
    required this.health,
    required this.exams,
  });

  final String studentName;
  final StatsPeriod period;
  final List<HeadlineStat> headline;

  /// جُملٌ تقول ما لا يقوله الرقم وحده: «أكثر أيام غيابه: الأحد (3 أيام)».
  /// تطول وتقصر بحسب ما وراءها، وقد تأتي فارغة.
  final List<String> highlights;

  final AttendanceStats attendance;
  final PerseveranceStats perseverance;
  final BehaviorStats behavior;
  final ExcusesStats excuses;
  final ProceduresStats procedures;
  final ParticipationStats participation;
  final HealthStats health;
  final ExamsStats exams;

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> block(String key) =>
        (json[key] as Map<String, dynamic>?) ?? const {};

    return StudentStats(
      studentName: _text(block('student')['name']),
      period: StatsPeriod.fromJson(block('period')),
      headline: _rows(json['headline']).map(HeadlineStat.fromJson).toList(),
      highlights: ((json['highlights'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      attendance: AttendanceStats.fromJson(block('attendance')),
      perseverance: PerseveranceStats.fromJson(block('perseverance')),
      behavior: BehaviorStats.fromJson(block('behavior')),
      excuses: ExcusesStats.fromJson(block('excuses')),
      procedures: ProceduresStats.fromJson(block('procedures')),
      participation: ParticipationStats.fromJson(block('participation')),
      health: HealthStats.fromJson(block('health')),
      exams: ExamsStats.fromJson(block('exams')),
    );
  }

  @override
  List<Object?> get props => [
        studentName,
        period,
        headline,
        highlights,
        attendance,
        perseverance,
        behavior,
        excuses,
        procedures,
        participation,
        health,
        exams,
      ];
}
