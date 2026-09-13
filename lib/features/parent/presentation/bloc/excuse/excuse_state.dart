part of 'excuse_bloc.dart';

sealed class ExcuseState extends Equatable {
  const ExcuseState();

  @override
  List<Object?> get props => [];
}

final class ExcuseInitial extends ExcuseState {}

final class ExcuseLoading extends ExcuseState {}

final class ExcuseFailureState extends ExcuseState {
  const ExcuseFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure, DateTime.now().microsecondsSinceEpoch];
}

final class ExcuseSubmittedState extends ExcuseState {}

/// حالة النموذج بكل ما فيه — تُبَثّ كاملة عند كل تغيير، فلا تحتفظ الشاشة
/// بحالة موازية تنحرف عن حالة البلوك.
final class ExcuseFormState extends ExcuseState {
  const ExcuseFormState({
    required this.period,
    required this.days,
    required this.reasons,
    required this.reason,
    required this.note,
    required this.attachment,
  });

  final AttendanceEntry period;
  final List<AbsenceDay> days;

  /// أسباب الغياب كما يرسلها الخادم.
  final List<String> reasons;
  final String? reason;
  final String note;
  final String? attachment;

  List<AbsenceDay> get selectedDays => days.where((d) => d.selected).toList();

  bool get canSubmit => selectedDays.isNotEmpty && reason != null;

  /// «3 أيام مختارة» أو «لم تختر أي يوم».
  String get selectionLabel {
    final count = selectedDays.length;
    if (count == 0) return 'لم تختر أي يوم';
    if (count == 1) return 'يوم واحد مختار';
    if (count == 2) return 'يومان مختاران';
    return '$count أيام مختارة';
  }

  /// استُثني يوم من وسط الفترة، فبقي بلا عذر بين يومين معذورين.
  bool get hasGap {
    final flags = days.map((d) => d.selected).toList();
    final first = flags.indexOf(true);
    final last = flags.lastIndexOf(true);
    if (first == -1) return false;
    for (var i = first; i <= last; i++) {
      if (!flags[i]) return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [period, days, reasons, reason, note, attachment];
}
