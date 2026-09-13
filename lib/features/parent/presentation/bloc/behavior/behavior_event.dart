part of 'behavior_bloc.dart';

/// تبويبا شاشة ج٤.
enum BehaviorTab { notes, statistics }

sealed class BehaviorEvent extends Equatable {
  const BehaviorEvent();

  @override
  List<Object?> get props => [];
}

final class GetBehaviorEvent extends BehaviorEvent {
  const GetBehaviorEvent({required this.filter});

  final BehaviorFilterEntity filter;

  @override
  List<Object?> get props => [filter];
}

final class ChangeBehaviorTabEvent extends BehaviorEvent {
  const ChangeBehaviorTabEvent({required this.tab});

  final BehaviorTab tab;

  @override
  List<Object?> get props => [tab];
}
