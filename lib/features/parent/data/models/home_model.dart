import 'package:equatable/equatable.dart';

/// خدمة في شبكة «الخدمات المتاحة» على الرئيسية.
enum HomeService {
  schedule,
  attendance,
  behavior,
  adminActions,
  exams,
  circulars,
  health,
}

/// بطاقة خدمة: العنوان ثابت والسطر الثاني عدّاد يأتي من الخادم.
class ServiceCard extends Equatable {
  const ServiceCard(
      {required this.service, required this.title, required this.subtitle});

  final HomeService service;
  final String title;

  /// «6 حصص اليوم»، «3 أيام بدون عذر»…
  final String subtitle;

  factory ServiceCard.fromJson(Map<String, dynamic> json) {
    final rawService = json['service']?.toString() ?? '';
    final serviceName = rawService.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );

    return ServiceCard(
      service: HomeService.values.firstWhere(
        (e) => e.name == serviceName,
        orElse: () => HomeService.schedule,
      ),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [service, title, subtitle];
}

/// تنبيه الغياب أعلى الرئيسية، ومعه زرّا «تقديم عذر» و«كل الفترات».
class AbsenceAlert extends Equatable {
  const AbsenceAlert({
    required this.title,
    required this.detail,
    required this.periodId,
  });

  /// «غياب بدون عذر — 3 أيام».
  final String title;

  /// «من الأحد 10 رمضان إلى الثلاثاء 12 رمضان — عذر واحد يغطي الفترة».
  final String detail;

  /// الفترة التي يفتحها زر «تقديم عذر».
  final String periodId;

  factory AbsenceAlert.fromJson(Map<String, dynamic> json) => AbsenceAlert(
        title: json['title']?.toString() ?? '',
        detail: json['detail']?.toString() ?? '',
        periodId: json['period_id']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [title, detail, periodId];
}

/// محتوى الرئيسية لطالب واحد.
class HomeSummary extends Equatable {
  const HomeSummary({
    required this.services,
    this.absenceAlert,
    this.hasUnreadNotifications = false,
  });

  final List<ServiceCard> services;

  /// `null` حين لا غياب بدون عذر — فتُخفى البطاقة كلها.
  final AbsenceAlert? absenceAlert;

  final bool hasUnreadNotifications;

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
        hasUnreadNotifications: json['has_unread'] == true,
        absenceAlert: json['absence_alert'] == null
            ? null
            : AbsenceAlert.fromJson(
                json['absence_alert'] as Map<String, dynamic>),
        services: ((json['services'] as List?) ?? [])
            .map((e) => ServiceCard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [services, absenceAlert, hasUnreadNotifications];
}

/// مفتاح في شاشة إعدادات التنبيهات (هـ٣).
class NotificationSetting extends Equatable {
  const NotificationSetting({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String key;
  final String title;
  final String subtitle;
  final bool enabled;

  NotificationSetting copyWith({bool? enabled}) => NotificationSetting(
        key: key,
        title: title,
        subtitle: subtitle,
        enabled: enabled ?? this.enabled,
      );

  factory NotificationSetting.fromJson(Map<String, dynamic> json) =>
      NotificationSetting(
        key: json['key']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        enabled: json['enabled'] == true,
      );

  @override
  List<Object?> get props => [key, title, subtitle, enabled];
}

/// معاينة شكل الإشعار على الجهاز في أعلى شاشة هـ٣.
class NotificationPreview extends Equatable {
  const NotificationPreview({
    required this.title,
    required this.body,
    required this.age,
  });

  final String title;
  final String body;
  final String age;

  @override
  List<Object?> get props => [title, body, age];
}
