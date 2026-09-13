import 'package:equatable/equatable.dart';

/// طالب مرتبط بولي الأمر. يظهر في شاشة اختيار الطالب، في شريط الأبناء أعلى
/// الرئيسية، وفي الشريط الجانبي بنسخة التابلت.
class Student extends Equatable {
  const Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.school,
    this.photo,
    this.unreadCount = 0,
    this.unexcusedAbsences = 0,
    this.shortName,
  });

  final String id;
  final String name;

  /// «الصف الثاني متوسط».
  final String grade;

  /// «فصل 1».
  final String section;

  final String school;
  final String? photo;

  /// عدد التنبيهات غير المقروءة — الشارة الحمراء على صورة الطالب.
  final int unreadCount;

  /// أيام الغياب بدون عذر — تُعرض كشارة في شاشة اختيار الطالب.
  final int unexcusedAbsences;

  /// الاسم الأول وحده، وهو ما يظهر تحت الصورة في شريط الأبناء.
  final String? shortName;

  String get firstName => shortName ?? name.split(' ').first;

  /// «الصف الثاني متوسط — فصل 1».
  String get classLabel => '$grade — $section';

  Student copyWith({int? unreadCount, int? unexcusedAbsences}) => Student(
        id: id,
        name: name,
        grade: grade,
        section: section,
        school: school,
        photo: photo,
        unreadCount: unreadCount ?? this.unreadCount,
        unexcusedAbsences: unexcusedAbsences ?? this.unexcusedAbsences,
        shortName: shortName,
      );

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        grade: json['grade']?.toString() ?? '',
        section: json['section']?.toString() ?? '',
        school: json['school']?.toString() ?? '',
        photo: json['photo']?.toString(),
        unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
        unexcusedAbsences:
            int.tryParse(json['unexcused_absences']?.toString() ?? '') ?? 0,
        shortName: json['short_name']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grade': grade,
        'section': section,
        'school': school,
        'photo': photo,
        'unread_count': unreadCount,
        'unexcused_absences': unexcusedAbsences,
        'short_name': shortName,
      };

  @override
  List<Object?> get props =>
      [id, name, grade, section, school, unreadCount, unexcusedAbsences];
}
