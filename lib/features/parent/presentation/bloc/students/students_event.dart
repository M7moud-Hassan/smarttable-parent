part of 'students_bloc.dart';

sealed class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

final class GetStudentsEvent extends StudentsEvent {}

final class SelectStudentEvent extends StudentsEvent {
  const SelectStudentEvent({required this.student});

  final Student student;

  @override
  List<Object?> get props => [student];
}
