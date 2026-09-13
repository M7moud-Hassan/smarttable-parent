import 'package:equatable/equatable.dart';

/// تعميم إداري (شاشتا د٣ ود٤).
class Circular extends Equatable {
  const Circular({
    required this.id,
    required this.title,
    required this.date,
    this.body = '',
    this.issuer = 'إدارة المدرسة',
    this.pdfUrl,
  });

  final String id;
  final String title;

  /// «11 رمضان».
  final String date;

  final String body;
  final String issuer;

  /// رابط نسخة PDF — يُخفى الزر حين لا يوجد.
  final String? pdfUrl;

  /// «11 رمضان · إدارة المدرسة».
  String get byline => '$date · $issuer';

  factory Circular.fromJson(Map<String, dynamic> json) => Circular(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        issuer: json['issuer']?.toString() ?? 'إدارة المدرسة',
        pdfUrl: json['pdf_url']?.toString(),
      );

  @override
  List<Object?> get props => [id, title, date, body, issuer, pdfUrl];
}
