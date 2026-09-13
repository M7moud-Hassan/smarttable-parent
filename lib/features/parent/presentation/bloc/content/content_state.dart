part of 'content_bloc.dart';

sealed class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

final class ContentInitial extends ContentState {}

final class ContentLoading extends ContentState {}

final class ContentFailureState extends ContentState {
  const ContentFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class SchoolLoadedState extends ContentState {
  const SchoolLoadedState({required this.info});

  final SchoolInfo info;

  @override
  List<Object?> get props => [info];
}

final class FaqLoadedState extends ContentState {
  const FaqLoadedState({required this.items});

  final List<FaqItem> items;

  @override
  List<Object?> get props => [items];
}

final class StaticPageLoadedState extends ContentState {
  const StaticPageLoadedState({required this.page});

  final StaticPage page;

  @override
  List<Object?> get props => [page];
}
