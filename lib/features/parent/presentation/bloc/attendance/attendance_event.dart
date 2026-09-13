part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

final class GetAttendanceEvent extends AttendanceEvent {
  const GetAttendanceEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}
