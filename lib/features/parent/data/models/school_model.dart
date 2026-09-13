import 'package:equatable/equatable.dart';

/// نوع سطر التواصل — يحدّد أيقونته. سطرا «ساعات العمل» و«العنوان» بلا رابط
/// يُضغط، فلا يصحّ استنتاج أيقونتهما من الرابط: كلاهما يخرج بالأيقونة نفسها.
enum ContactKind { phone, email, hours, address }

/// سطر معلومة في «تواصل مع المدرسة» و«الدعم الفني»: هاتف، بريد، ساعات عمل…
class ContactRow extends Equatable {
  const ContactRow({
    required this.label,
    required this.value,
    required this.kind,
    this.action,
  });

  final String label;
  final String value;
  final ContactKind kind;

  /// ما يُفتح عند الضغط: `tel:` أو `mailto:` أو `null` لسطر للعرض فقط.
  final String? action;

  factory ContactRow.fromJson(Map<String, dynamic> json) => ContactRow(
        label: json['label']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        kind: ContactKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => ContactKind.hours,
        ),
        action: json['action']?.toString(),
      );

  @override
  List<Object?> get props => [label, value, kind, action];
}

/// بيانات المدرسة (شاشة هـ٥).
class SchoolInfo extends Equatable {
  const SchoolInfo({
    required this.name,
    required this.office,
    required this.rows,
    this.phone = '',
  });

  final String name;

  /// «مكتب وكيل شؤون الطلاب».
  final String office;

  final List<ContactRow> rows;

  /// الرقم الذي يطلبه زر «الاتصال بالمدرسة».
  final String phone;

  factory SchoolInfo.fromJson(Map<String, dynamic> json) => SchoolInfo(
        name: json['name']?.toString() ?? '',
        office: json['office']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        rows: ((json['rows'] as List?) ?? [])
            .map((e) => ContactRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [name, office, rows, phone];
}

/// سؤال شائع قابل للفتح (شاشة هـ٧).
class FaqItem extends Equatable {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        question: json['question']?.toString() ?? '',
        answer: json['answer']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [question, answer];
}

/// صفحة نصّية ثابتة — من نحن، السياسة، الشروط. قالب واحد بثلاثة محتويات.
class StaticPage extends Equatable {
  const StaticPage({
    required this.title,
    required this.updatedAt,
    required this.paragraphs,
  });

  final String title;

  /// «8 رمضان 1447».
  final String updatedAt;

  final List<String> paragraphs;

  factory StaticPage.fromJson(Map<String, dynamic> json) => StaticPage(
        title: json['title']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '',
        paragraphs:
            ((json['paragraphs'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  @override
  List<Object?> get props => [title, updatedAt, paragraphs];
}
