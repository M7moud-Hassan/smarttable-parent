import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/push_notifications_service.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/base_entity.dart';
import '../../domain/entities/service_entities.dart';
import '../models/admin_action_model.dart';
import '../models/attendance_model.dart';
import '../models/behavior_model.dart';
import '../models/circular_model.dart';
import '../models/exam_model.dart';
import '../models/health_model.dart';
import '../models/home_model.dart';
import '../models/notification_model.dart';
import '../models/parent_model.dart';
import '../models/schedule_model.dart';
import '../models/school_model.dart';
import '../models/student_model.dart';
import 'db.dart';

/// تنفيذ `Db` فوق واجهة الخادم.
///
/// نقاط الواجهة في `st_follower/parent_api` من مشروع `smarttable`، وكلّها
/// تردّ بالغلاف نفسه: `{data, success, message}`. فتُقرأ `data` في موضع واحد
/// هنا، ولا تعرف أي شاشة شكل الردّ.
class DbRemote implements Db {
  DbRemote({required this.dio});

  final Dio dio;

  // ─── نداءات الخادم ───────────────────────────────────────────────────────

  /// يقرأ `data` من الغلاف، ويرفع الرسالة العربية التي أرسلها الخادم.
  ///
  /// رسالة الخادم أدقّ من أي نصّ عامّ: هي التي تقول «الرقم غير مسجّل لدى أي
  /// طالب» أو «الرمز غير صحيح»، وهي ما ينبغي أن يراه وليّ الأمر.
  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      final payload = response.data;
      if (payload is Map && payload['success'] == false) {
        throw ServerException(payload['message']?.toString() ?? '');
      }
      return payload is Map ? payload['data'] : payload;
    } on DioException catch (error) {
      throw _failure(error);
    }
  }

  Future<Map<String, dynamic>> _object(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final data = await _send(method, path, query: query, body: body);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> _list(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final data = await _send(method, path, query: query, body: body);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  /// يحوّل خطأ الشبكة إلى استثناء يحمل نصّاً يُقرأ.
  AppException _failure(DioException error) {
    final data = error.response?.data;
    final message = data is Map
        ? (data['message'] ?? data['detail'] ?? data['msg'])?.toString()
        : null;

    if (error.response?.statusCode == 401) {
      return UnauthorizedException(message ?? 'انتهت الجلسة. سجّل الدخول مرة أخرى.');
    }
    if (message != null && message.isNotEmpty) {
      return ServerException(message);
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ServerException('تعذّر الوصول إلى الخادم. تحقّق من الاتصال.');
      case DioExceptionType.connectionError:
        return ServerException('لا يوجد اتصال بالخادم.');
      default:
        return ServerException('تعذّر إكمال الطلب. حاول مرة أخرى.');
    }
  }

  /// الطالب المختار حين لا تمرّره الشاشة صريحاً.
  Map<String, dynamic> _student(String studentId) => {
        'student':
            studentId.isNotEmpty ? studentId : (AppUtils.selectedStudent?.id ?? ''),
      };

  /// مرفَقٌ يُرسل مع النموذج — الملف بمساره من الجهاز.
  Future<FormData> _form(
      Map<String, dynamic> fields, String? filePath, String fileField) async {
    final data = FormData();
    fields.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          data.fields.add(MapEntry(key, item.toString()));
        }
      } else {
        data.fields.add(MapEntry(key, value.toString()));
      }
    });
    if (filePath != null && filePath.isNotEmpty) {
      data.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(filePath),
      ));
    }
    return data;
  }

  // ─── المصادقة ────────────────────────────────────────────────────────────

  @override
  Future<ParentUser> Function(LoginEntity) get login => (entity) async {
        final data = await _object('POST', 'auth/login/', body: {
          'username': entity.username,
          'password': entity.password,
        });
        return _acceptSession(data);
      };

  /// يثبّت رمز الوصول ويعيد وليّ الأمر — يشترك فيه الدخول وإنشاء الحساب.
  ParentUser _acceptSession(Map<String, dynamic> data) {
    final access = data['access']?.toString() ?? '';
    if (access.isEmpty) {
      throw ServerException('لم يُصدر الخادم رمز دخول.');
    }
    AppUtils.instance.setTokens(
      access: access,
      refresh: data['refresh']?.toString() ?? '',
    );
    // الرمز يُسجَّل الآن: قبل الدخول لا يُعرف صاحب الجهاز، فلا يصل إشعار.
    unawaited(PushNotificationsService.instance.syncToken());

    final parent = data['parent'];
    return ParentUser.fromJson(
      parent is Map<String, dynamic> ? parent : const {},
    );
  }

  @override
  Future<String> Function(PhoneEntity) get requestOtp => (entity) async {
        final data =
            await _object('POST', 'auth/request-code/', body: {'phone': entity.phone});
        final phone = data['phone']?.toString() ?? entity.phone;
        AppUtils.pendingPhone = phone;
        return phone;
      };

  @override
  Future<bool> Function(OtpEntity) get verifyOtp => (entity) async {
        final data = await _object('POST', 'auth/verify-code/', body: {
          'phone': entity.phone,
          'code': entity.code,
        });
        return data['verified'] == true;
      };

  @override
  Future<ParentUser> Function(CreateAccountEntity) get createAccount => (entity) async {
        final data = await _object('POST', 'auth/create-account/', body: {
          'phone': entity.phone,
          'username': entity.username,
          'email': entity.email,
          'password': entity.password,
        });
        return _acceptSession(data);
      };

  @override
  Future<String> Function(PhoneEntity) get forgotPassword => (entity) async {
        final data =
            await _object('POST', 'auth/forgot-password/', body: {'phone': entity.phone});
        final phone = data['phone']?.toString() ?? entity.phone;
        // شاشة تحديث كلمة المرور لا تسأل عن الرقم، فيُحمل من هنا إليها.
        AppUtils.pendingPhone = phone;
        return phone;
      };

  @override
  Future<bool> Function(ResetPasswordEntity) get resetPassword => (entity) async {
        // `token` في هذه الشاشة هو رمز التحقّق الذي وصل في الرسالة.
        await _send('POST', 'auth/reset-password/', body: {
          'phone': AppUtils.pendingPhone,
          'code': entity.token,
          'new_password': entity.password,
        });
        return true;
      };

  @override
  Future<bool> Function(ChangePasswordEntity) get changePassword => (entity) async {
        await _send('POST', 'auth/change-password/', body: {
          'current_password': entity.currentPassword,
          'new_password': entity.newPassword,
        });
        return true;
      };

  @override
  Future<bool> Function() get deleteAccount => () async {
        await _send('POST', 'auth/delete-account/');
        return true;
      };

  // ─── الحساب والأبناء ─────────────────────────────────────────────────────

  @override
  Future<ParentUser> Function() get me => () async {
        return ParentUser.fromJson(await _object('GET', 'auth/me/'));
      };

  @override
  Future<ParentUser> Function(ProfileEntity) get updateProfile => (entity) async {
        final data = await _object(
          'PATCH',
          'auth/me/',
          body: await _form({
            'name': entity.name,
            'email': entity.email,
            'national_id': entity.nationalId,
            'workplace': entity.workplace,
          }, entity.avatarPath, 'avatar'),
        );
        return ParentUser.fromJson(data);
      };

  @override
  Future<List<Student>> Function() get students => () async {
        final rows = await _list('GET', 'students/');
        return rows.map(Student.fromJson).toList();
      };

  // ─── الرئيسية والإشعارات ─────────────────────────────────────────────────

  @override
  Future<HomeSummary> Function(StudentEntity) get home => (entity) async {
        return HomeSummary.fromJson(
          await _object('GET', 'home/', query: _student(entity.studentId)),
        );
      };

  @override
  Future<List<ParentNotification>> Function() get notifications => () async {
        final data = await _object('GET', 'notifications/');
        final items = (data['items'] as List?) ?? const [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(ParentNotification.fromJson)
            .toList();
      };

  @override
  Future<bool> Function() get markAllRead => () async {
        await _send('POST', 'notifications/');
        return true;
      };

  @override
  Future<List<NotificationSetting>> Function() get notificationSettings => () async {
        final rows = await _list('GET', 'settings/alerts/');
        return rows.map(NotificationSetting.fromJson).toList();
      };

  @override
  Future<bool> Function(NotificationSettingsEntity) get saveNotificationSettings =>
      (entity) async {
        await _send('PUT', 'settings/alerts/', body: entity.settings);
        return true;
      };

  // ─── الخدمات ─────────────────────────────────────────────────────────────

  @override
  Future<WeekSchedule> Function(StudentEntity) get schedule => (entity) async {
        return WeekSchedule.fromJson(
          await _object('GET', 'schedule/', query: _student(entity.studentId)),
        );
      };

  @override
  Future<AttendanceReport> Function(StudentEntity) get attendance => (entity) async {
        return AttendanceReport.fromJson(await _object(
          'GET',
          'attendance/',
          query: {..._student(entity.studentId), 'period': 'term'},
        ));
      };

  @override
  Future<ExcuseForm> Function(IdEntity) get absencePeriod => (entity) async {
        return ExcuseForm.fromJson(await _object(
          'GET',
          'excuses/',
          query: {..._student(''), 'period': entity.id},
        ));
      };

  @override
  Future<bool> Function(ExcuseEntity) get submitExcuse => (entity) async {
        if (entity.dayIds.isEmpty) {
          throw ValidationException('اختر يوماً واحداً على الأقل.');
        }
        if (entity.reason.trim().isEmpty) {
          throw ValidationException('اختر سبب الغياب.');
        }
        await _send(
          'POST',
          'excuses/',
          query: _student(entity.studentId),
          body: await _form({
            'days': entity.dayIds,
            'reason': entity.reason,
            'note': entity.note,
          }, entity.attachmentPath, 'attachment'),
        );
        return true;
      };

  @override
  Future<BehaviorReport> Function(BehaviorFilterEntity) get behavior => (filter) async {
        return BehaviorReport.fromJson(await _object('GET', 'behavior/', query: {
          ..._student(filter.studentId),
          'period': filter.period.name,
          if (filter.type != null) 'type': filter.type!.name,
        }));
      };

  @override
  Future<HealthRecord> Function(StudentEntity) get health => (entity) async {
        return HealthRecord.fromJson(
          await _object('GET', 'health/', query: _student(entity.studentId)),
        );
      };

  @override
  Future<bool> Function(HealthEntity) get saveHealth => (entity) async {
        await _send(
          'PUT',
          'health/',
          query: _student(entity.studentId),
          body: await _form({
            'selected': entity.diseases,
            'instructions': entity.instructions,
          }, entity.reportPath, 'report'),
        );
        return true;
      };

  @override
  Future<List<Exam>> Function(StudentEntity) get exams => (entity) async {
        final rows = await _list('GET', 'exams/', query: _student(entity.studentId));
        return rows.map(Exam.fromJson).toList();
      };

  @override
  Future<Exam> Function(IdEntity) get examDetails => (entity) async {
        return Exam.fromJson(
          await _object('GET', 'exams/${entity.id}/', query: _student('')),
        );
      };

  @override
  Future<List<Circular>> Function(StudentEntity) get circulars => (entity) async {
        final rows = await _list('GET', 'circulars/', query: _student(entity.studentId));
        return rows.map(Circular.fromJson).toList();
      };

  @override
  Future<Circular> Function(IdEntity) get circularDetails => (entity) async {
        return Circular.fromJson(
          await _object('GET', 'circulars/${entity.id}/', query: _student('')),
        );
      };

  @override
  Future<List<AdminAction>> Function(StudentEntity) get adminActions => (entity) async {
        final rows = await _list('GET', 'procedures/', query: _student(entity.studentId));
        return rows.map(AdminAction.fromJson).toList();
      };

  @override
  Future<bool> Function(ActionResponseEntity) get respondToAction =>
      (entity) async {
        // الردّ يُحفظ على الإجراء نفسه لا كإشعارٍ مقروء: المدرسة تسأل «هل
        // اطّلع؟ هل سيحضر؟»، وتقرأ الجواب في صفحة الإجراء.
        await _send(
          'POST',
          'procedures/${entity.actionId}/respond/',
          query: _student(''),
          body: {
            'response': entity.confirmAttendance ? 'attending' : 'seen',
          },
        );
        return true;
      };

  // ─── محتوى ثابت ──────────────────────────────────────────────────────────

  @override
  Future<SchoolInfo> Function(StudentEntity) get school => (entity) async {
        return SchoolInfo.fromJson(
          await _object('GET', 'school/', query: _student(entity.studentId)),
        );
      };

  @override
  Future<SchoolInfo> Function() get support => () async {
        return SchoolInfo.fromJson(await _object('GET', 'support/'));
      };

  @override
  Future<List<FaqItem>> Function() get faq => () async {
        final rows = await _list('GET', 'faq/');
        return rows.map(FaqItem.fromJson).toList();
      };

  @override
  Future<StaticPage> Function(StaticPageEntity) get staticPage => (entity) async {
        return StaticPage.fromJson(
          await _object('GET', 'pages/${entity.kind.slug}/'),
        );
      };
}

/// اسم الصفحة الثابتة في المسار.
extension StaticPageSlug on StaticPageKind {
  String get slug => switch (this) {
        StaticPageKind.about => 'about',
        StaticPageKind.privacy => 'privacy',
        StaticPageKind.terms => 'terms',
      };
}
