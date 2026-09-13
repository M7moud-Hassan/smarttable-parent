part of 'exams_bloc.dart';

sealed class ExamsEvent extends Equatable {
  const ExamsEvent();

  @override
  List<Object?> get props => [];
}

final class GetExamsEvent extends ExamsEvent {
  const GetExamsEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class GetExamDetailsEvent extends ExamsEvent {
  const GetExamDetailsEvent({required this.examId});

  final String examId;

  @override
  List<Object?> get props => [examId];
}
