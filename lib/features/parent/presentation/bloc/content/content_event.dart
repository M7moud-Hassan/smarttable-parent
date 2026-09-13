part of 'content_bloc.dart';

sealed class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

final class GetSchoolEvent extends ContentEvent {
  const GetSchoolEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class GetSupportEvent extends ContentEvent {}

final class GetFaqEvent extends ContentEvent {}

final class GetStaticPageEvent extends ContentEvent {
  const GetStaticPageEvent({required this.kind});

  final StaticPageKind kind;

  @override
  List<Object?> get props => [kind];
}
