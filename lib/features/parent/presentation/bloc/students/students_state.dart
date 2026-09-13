part of 'students_bloc.dart';

sealed class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

final class StudentsInitial extends StudentsState {}

final class StudentsLoading extends StudentsState {}

final class StudentsFailureState extends StudentsState {
  const StudentsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class StudentsLoadedState extends StudentsState {
  const StudentsLoadedState({required this.students, this.selected});

  final List<Student> students;
  final Student? selected;

  @override
  List<Object?> get props => [students, selected];
}
