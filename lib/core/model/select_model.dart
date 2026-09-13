import 'package:equatable/equatable.dart';

/// عنصر قابل للاختيار في قائمة أو شريط شرائح.
class SelectModel extends Equatable {
  const SelectModel({required this.id, required this.name, this.selected = false});

  final dynamic id;
  final String name;
  final bool selected;

  SelectModel copyWith({dynamic id, String? name, bool? selected}) => SelectModel(
        id: id ?? this.id,
        name: name ?? this.name,
        selected: selected ?? this.selected,
      );

  @override
  List<Object?> get props => [id, name, selected];
}
