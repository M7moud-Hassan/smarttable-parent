part of 'exams_bloc.dart';

sealed class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

final class ExamsInitial extends ExamsState {}

final class ExamsLoading extends ExamsState {}

final class ExamsFailureState extends ExamsState {
  const ExamsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ExamsLoadedState extends ExamsState {
  const ExamsLoadedState({required this.exams});

  final List<Exam> exams;

  @override
  List<Object?> get props => [exams];
}

final class ExamDetailsLoadedState extends ExamsState {
  const ExamDetailsLoadedState({required this.exam});

  final Exam exam;

  @override
  List<Object?> get props => [exam];
}
