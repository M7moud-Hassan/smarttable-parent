import 'package:smartble_parent/core/enums/attendance_status.dart';
import 'package:smartble_parent/core/enums/note_type.dart';
import 'package:smartble_parent/features/parent/data/models/admin_action_model.dart';
import 'package:smartble_parent/features/parent/data/models/attendance_model.dart';
import 'package:smartble_parent/features/parent/data/models/behavior_model.dart';
import 'package:smartble_parent/features/parent/data/models/circular_model.dart';
import 'package:smartble_parent/features/parent/data/models/exam_model.dart';
import 'package:smartble_parent/features/parent/data/models/health_model.dart';
import 'package:smartble_parent/features/parent/data/models/home_model.dart';
import 'package:smartble_parent/features/parent/data/models/notification_model.dart';
import 'package:smartble_parent/features/parent/data/models/parent_model.dart';
import 'package:smartble_parent/features/parent/data/models/schedule_model.dart';
import 'package:smartble_parent/features/parent/data/models/school_model.dart';
import 'package:smartble_parent/features/parent/data/models/student_model.dart';

/// محتوى الشاشات كما ورد حرفياً في حزمة التسليم — تجهيزةُ اختبار لا بيانات.
///
/// التطبيق يقرأ من الخادم وحده (`DbRemote`). وهذا الملف يبقى في `test/` ليُرسم
/// به كل شاشة في اختبار اللقطات فتُقارن بلقطات الحزمة: المحتوى نفسه الذي
/// رُسمت به، فأي فرق في اللقطة فرقٌ في الشاشة لا في البيانات.
class DesignData {
  DesignData._();

  // ─── ولي الأمر والأبناء ──────────────────────────────────────────────────
  static ParentUser parent = const ParentUser(
    id: 'p1',
    name: 'أبو عبدالرحمن الحربي',
    phone: '0551234567',
    username: 'abu.abdulrahman',
    email: 'abu@mail.com',
    nationalId: '1098234567',
    workplace: 'موظف قطاع خاص',
    schoolName: 'متوسطة الأمير سلطان',
  );

  static const List<Student> students = [
    Student(
      id: 's1',
      name: 'عبدالرحمن محمد الحربي',
      shortName: 'عبدالرحمن',
      grade: 'الصف الثاني متوسط',
      section: 'فصل 1',
      school: 'متوسطة الأمير سلطان',
      unreadCount: 3,
      unexcusedAbsences: 3,
    ),
    Student(
      id: 's2',
      name: 'سارة محمد الحربي',
      shortName: 'سارة',
      grade: 'الصف الخامس الابتدائي',
      section: 'فصل 3',
      school: 'ابتدائية النخيل',
      unreadCount: 0,
      unexcusedAbsences: 0,
    ),
    Student(
      id: 's3',
      name: 'فيصل محمد الحربي',
      shortName: 'فيصل',
      grade: 'الصف الثالث الثانوي',
      section: 'فصل 2',
      school: 'ثانوية النخيل',
      unreadCount: 1,
      unexcusedAbsences: 1,
    ),
  ];

  // ─── B1 الرئيسية ─────────────────────────────────────────────────────────
  static HomeSummary home(String studentId) {
    final hasAbsence = studentId == 's1';
    return HomeSummary(
      hasUnreadNotifications: true,
      absenceAlert: hasAbsence
          ? const AbsenceAlert(
              title: 'غياب بدون عذر — 3 أيام',
              detail: 'من الأحد 10 رمضان إلى الثلاثاء 12 رمضان — عذر واحد يغطي الفترة',
              periodId: 'period-1',
            )
          : null,
      services: [
        const ServiceCard(
          service: HomeService.schedule,
          title: 'الجدول المدرسي',
          subtitle: '6 حصص اليوم',
        ),
        ServiceCard(
          service: HomeService.attendance,
          title: 'تقرير المواظبة',
          subtitle: hasAbsence ? '3 أيام بدون عذر' : 'لا غياب بدون عذر',
        ),
        const ServiceCard(
          service: HomeService.behavior,
          title: 'تقرير السلوك',
          subtitle: '7 ملاحظة هذا الشهر',
        ),
        const ServiceCard(
          service: HomeService.adminActions,
          title: 'الإجراءات الإدارية',
          subtitle: '3 إجراء يتطلب اطلاعك',
        ),
        const ServiceCard(
          service: HomeService.exams,
          title: 'مواعيد الاختبارات',
          subtitle: 'أقربها بعد 3 أيام',
        ),
        const ServiceCard(
          service: HomeService.circulars,
          title: 'التعاميم الإدارية',
          subtitle: 'تعميم جديد',
        ),
        const ServiceCard(
          service: HomeService.health,
          title: 'الحالة الصحية',
          subtitle: 'ربو',
        ),
      ],
    );
  }

  // ─── B2 الإشعارات ────────────────────────────────────────────────────────
  static List<ParentNotification> notifications = [
    const ParentNotification(
      id: 'n1',
      title: '3 أيام غياب بدون عذر — عبدالرحمن',
      body: 'من الأحد 10 رمضان إلى الثلاثاء 12 رمضان · عذر واحد يغطي الفترة',
      age: 'متراكم',
      target: NotificationTarget.attendance,
      studentId: 's1',
    ),
    const ParentNotification(
      id: 'n2',
      title: 'سُجّل غياب بدون عذر — فيصل',
      body: 'الثلاثاء 12 رمضان',
      age: 'متراكم',
      target: NotificationTarget.attendance,
      studentId: 's3',
    ),
    const ParentNotification(
      id: 'n3',
      title: 'تم قبول عذر الغياب بتاريخ 6 رمضان',
      body: 'اعتمدت الإدارة العذر الطبي المرفق',
      age: 'أمس',
      target: NotificationTarget.excuseResult,
      studentId: 's1',
    ),
    const ParentNotification(
      id: 'n4',
      title: 'ملاحظة سلوك إيجابية جديدة',
      body: 'من أ. خالد العمري — تعاون في تنظيم النشاط الصفي',
      age: 'أمس',
      target: NotificationTarget.behavior,
      studentId: 's1',
    ),
    const ParentNotification(
      id: 'n5',
      title: 'اختبار الرياضيات بعد 5 أيام',
      body: 'الأحد 17 رمضان · 07:00 — قاعة الاختبارات 3',
      age: 'قبل يومين',
      target: NotificationTarget.exam,
      studentId: 's1',
      targetId: 'e1',
    ),
    const ParentNotification(
      id: 'n6',
      title: 'تعميم جديد: تعليمات الاختبارات',
      body: 'إدارة المدرسة — يُرجى الاطلاع',
      age: 'قبل 3 أيام',
      target: NotificationTarget.circular,
      studentId: 's1',
      targetId: 'c1',
    ),
    const ParentNotification(
      id: 'n7',
      title: 'استدعاء ولي الأمر — يتطلب ردّك',
      body: 'بسبب تكرار الغياب بدون عذر · الأحد 17 رمضان الساعة 09:00',
      age: 'اليوم',
      target: NotificationTarget.adminAction,
      studentId: 's1',
    ),
    const ParentNotification(
      id: 'n8',
      title: 'حُسمت درجتان من درجات المواظبة',
      body: 'إجراء مرتبط بملاحظة غياب بدون عذر — يتطلب اطلاعك',
      age: 'قبل 5 أيام',
      target: NotificationTarget.adminAction,
      studentId: 's1',
    ),
  ];

  // ─── ج1 الجدول المدرسي ───────────────────────────────────────────────────
  static const List<Lesson> _lessons = [
    Lesson(
        order: 'الأولى',
        subject: 'القرآن الكريم',
        teacher: 'أ. سعد الدوسري',
        from: '07:00',
        to: '07:45'),
    Lesson(
        order: 'الثانية',
        subject: 'لغتي الخالدة',
        teacher: 'أ. خالد العمري',
        from: '07:50',
        to: '08:35'),
    Lesson(
        order: 'الثالثة',
        subject: 'الرياضيات',
        teacher: 'أ. ماجد القحطاني',
        from: '08:40',
        to: '09:25',
        isCurrent: true),
    Lesson(
        order: 'الرابعة',
        subject: 'العلوم',
        teacher: 'أ. فهد الزهراني',
        from: '09:45',
        to: '10:30'),
    Lesson(
        order: 'الخامسة',
        subject: 'اللغة الإنجليزية',
        teacher: 'أ. تركي السالم',
        from: '10:35',
        to: '11:20'),
    Lesson(
        order: 'السادسة',
        subject: 'التربية البدنية',
        teacher: 'أ. نواف الشمري',
        from: '11:25',
        to: '12:10'),
  ];

  /// أيام غير اليوم الحالي تعرض الجدول نفسه بلا حصّة مميّزة.
  static List<Lesson> _plain() => _lessons
      .map((l) => Lesson(
            order: l.order,
            subject: l.subject,
            teacher: l.teacher,
            from: l.from,
            to: l.to,
          ))
      .toList();

  static WeekSchedule schedule = WeekSchedule(
    hijriMonth: 'رمضان 1447',
    remainingInCurrentLesson: '15:20',
    days: [
      ScheduleDay(id: 'd1', weekday: 'الأحد', dayNumber: '10', lessons: _plain()),
      ScheduleDay(id: 'd2', weekday: 'الاثنين', dayNumber: '11', lessons: _plain()),
      const ScheduleDay(
          id: 'd3',
          weekday: 'الثلاثاء',
          dayNumber: '12',
          lessons: _lessons,
          isToday: true),
      ScheduleDay(id: 'd4', weekday: 'الأربعاء', dayNumber: '13', lessons: _plain()),
      ScheduleDay(id: 'd5', weekday: 'الخميس', dayNumber: '14', lessons: _plain()),
    ],
  );

  // ─── ج2 تقرير المواظبة ───────────────────────────────────────────────────
  static const AttendanceEntry absencePeriod = AttendanceEntry(
    id: 'period-1',
    title: 'غياب متصل — 3 أيام',
    status: AttendanceStatus.absent,
    detail: 'من الأحد 10 رمضان إلى الثلاثاء 12 رمضان',
    canSubmitExcuse: true,
    days: [
      AbsenceDay(id: 'day-12', label: 'الثلاثاء 12 رمضان'),
      AbsenceDay(id: 'day-11', label: 'الاثنين 11 رمضان'),
      AbsenceDay(id: 'day-10', label: 'الأحد 10 رمضان'),
    ],
  );

  static AttendanceReport attendance = const AttendanceReport(
    termLabel: 'الفصل الدراسي الثاني',
    percentage: 91,
    presentDays: 42,
    lateDays: 1,
    absentDays: 4,
    warning: 'غياب بدون عذر: 3 أيام في فترة واحدة متصلة',
    entries: [
      absencePeriod,
      AttendanceEntry(
        id: 'a2',
        title: 'الخميس 7 رمضان',
        status: AttendanceStatus.late,
        detail: 'تأخر 12 دقيقة عن الحصة الأولى',
      ),
      AttendanceEntry(
        id: 'a3',
        title: 'غياب يوم واحد',
        status: AttendanceStatus.absent,
        detail: 'الأربعاء 6 رمضان',
        excuseStatus: ExcuseStatus.accepted,
      ),
      AttendanceEntry(
        id: 'a4',
        title: 'الثلاثاء 5 رمضان',
        status: AttendanceStatus.present,
        detail: 'يوم كامل',
      ),
    ],
  );

  /// أسباب الغياب المعروضة كشرائح في شاشة تقديم العذر.
  static const List<String> excuseReasons = [
    'مرض',
    'ظرف عائلي',
    'سفر',
    'موعد رسمي',
    'أخرى',
  ];

  // ─── ج4 تقرير السلوك ─────────────────────────────────────────────────────
  static const List<BehaviorNote> behaviorNotes = [
    BehaviorNote(
      id: 'b1',
      type: BehaviorNoteType.positive,
      body: 'مشاركة متميزة في حل تمارين الوحدة',
      teacher: 'أ. ماجد القحطاني',
      subject: 'الرياضيات',
      date: '12 رمضان',
    ),
    BehaviorNote(
      id: 'b2',
      type: BehaviorNoteType.needsWork,
      body: 'إزعاج داخل الفصل أثناء الشرح',
      teacher: 'أ. ماجد القحطاني',
      subject: 'الرياضيات',
      date: '11 رمضان',
    ),
    BehaviorNote(
      id: 'b3',
      type: BehaviorNoteType.positive,
      body: 'تعاون مع زملائه في تنظيم النشاط الصفي',
      teacher: 'أ. خالد العمري',
      subject: 'لغتي الخالدة',
      date: '10 رمضان',
    ),
    BehaviorNote(
      id: 'b4',
      type: BehaviorNoteType.needsWork,
      body: 'عدم إنجاز الواجب المنزلي',
      teacher: 'أ. فهد الزهراني',
      subject: 'العلوم',
      date: '7 رمضان',
    ),
    BehaviorNote(
      id: 'b5',
      type: BehaviorNoteType.positive,
      body: 'التزام كامل بالواجبات المنزلية',
      teacher: 'أ. خالد العمري',
      subject: 'لغتي الخالدة',
      date: '6 رمضان',
    ),
    BehaviorNote(
      id: 'b6',
      type: BehaviorNoteType.positive,
      body: 'روح رياضية عالية في المباراة الودية',
      teacher: 'أ. نواف الشمري',
      subject: 'التربية البدنية',
      date: '5 رمضان',
    ),
    BehaviorNote(
      id: 'b7',
      type: BehaviorNoteType.needsWork,
      body: 'تكرار نسيان الكتاب المدرسي',
      teacher: 'أ. تركي السالم',
      subject: 'اللغة الإنجليزية',
      date: '3 رمضان',
    ),
  ];

  static const List<String> subjects = [
    'الرياضيات',
    'لغتي الخالدة',
    'العلوم',
    'التربية البدنية',
    'اللغة الإنجليزية',
    'القرآن الكريم',
  ];

  static const List<String> teachers = [
    'أ. ماجد القحطاني',
    'أ. خالد العمري',
    'أ. فهد الزهراني',
    'أ. نواف الشمري',
    'أ. تركي السالم',
    'أ. سعد الدوسري',
  ];

  static const BehaviorStatistics behaviorStatistics = BehaviorStatistics(
    total: 7,
    positive: 4,
    needsWork: 3,
    weeks: [
      BehaviorBreakdown(label: 'قبل 3', positive: 2, needsWork: 1),
      BehaviorBreakdown(label: 'قبل 2', positive: 1, needsWork: 1),
      BehaviorBreakdown(label: 'قبل 1', positive: 1, needsWork: 1),
      BehaviorBreakdown(label: 'الحالي', positive: 2, needsWork: 1),
    ],
  );

  // ─── ج5 الحالة الصحية ────────────────────────────────────────────────────
  static HealthRecord health = const HealthRecord(
    available: [
      'ربو',
      'سكري',
      'حساسية طعام',
      'حساسية دواء',
      'صرع',
      'أنيميا',
      'أمراض القلب',
    ],
    selected: ['ربو'],
    instructions: '',
    reportName: 'تقرير_الربو_1447.pdf',
  );

  // ─── د1 / د2 الاختبارات ──────────────────────────────────────────────────
  static const List<Exam> exams = [
    Exam(
      id: 'e1',
      subject: 'الرياضيات',
      dayNumber: '17',
      monthName: 'رمضان',
      weekday: 'الأحد',
      from: '07:00',
      to: '08:30',
      place: 'قاعة الاختبارات 3',
      daysAway: 5,
      fullDate: 'الأحد 17 رمضان 1447',
      teacher: 'أ. ماجد القحطاني',
      details: [
        ExamDetailRow(label: 'الدرجة', value: '10 درجات من مجموع الفصل'),
        ExamDetailRow(label: 'المدة', value: '90 دقيقة — حصتان متصلتان'),
        ExamDetailRow(label: 'المقرر', value: 'من صفحة 42 إلى صفحة 78'),
      ],
      topics: [
        'المعادلات من الدرجة الأولى',
        'النسبة والتناسب',
        'مساحة الأشكال المركبة',
        'تمثيل البيانات بالأعمدة',
      ],
      notes:
          'يُسمح باستخدام الآلة الحاسبة العادية فقط. أحضر معك مسطرة ومنقلة، وراجع تمارين الوحدة الرابعة في كتاب النشاط قبل الاختبار.',
    ),
    Exam(
      id: 'e2',
      subject: 'العلوم',
      dayNumber: '19',
      monthName: 'رمضان',
      weekday: 'الثلاثاء',
      from: '07:00',
      to: '07:45',
      place: 'الفصل 2/1',
      daysAway: 7,
      fullDate: 'الثلاثاء 19 رمضان 1447',
      teacher: 'أ. فهد الزهراني',
    ),
    Exam(
      id: 'e3',
      subject: 'لغتي الخالدة',
      dayNumber: '21',
      monthName: 'رمضان',
      weekday: 'الخميس',
      from: '07:00',
      to: '09:00',
      place: 'قاعة الاختبارات 2',
      daysAway: 9,
      fullDate: 'الخميس 21 رمضان 1447',
      teacher: 'أ. خالد العمري',
    ),
    Exam(
      id: 'e4',
      subject: 'اللغة الإنجليزية',
      dayNumber: '24',
      monthName: 'رمضان',
      weekday: 'الأحد',
      from: '07:00',
      to: '08:30',
      place: 'قاعة الاختبارات 3',
      daysAway: 12,
      fullDate: 'الأحد 24 رمضان 1447',
      teacher: 'أ. تركي السالم',
    ),
  ];

  // ─── د3 / د4 التعاميم ────────────────────────────────────────────────────
  static const List<Circular> circulars = [
    Circular(
      id: 'c1',
      title: 'تعليمات اختبارات الفصل الدراسي الثاني',
      date: '11 رمضان',
      pdfUrl: 'https://www.smartble.net/circulars/c1.pdf',
      body:
          'تبدأ اختبارات الفصل الدراسي الثاني يوم الأحد 17 رمضان وتستمر حتى الخميس 28 رمضان. يُرجى من أولياء الأمور التأكد من حضور الطالب قبل موعد الاختبار بنصف ساعة، وإحضار البطاقة المدرسية والأدوات الخاصة به. لا يُسمح بإدخال الأجهزة الذكية إلى قاعات الاختبار، ولن يُقبل أي عذر عن التأخر إلا بموافقة الإدارة المسبقة.',
    ),
    Circular(
      id: 'c2',
      title: 'الجدول المدرسي المحدّث للفصل الثاني',
      date: '6 رمضان',
      pdfUrl: 'https://www.smartble.net/circulars/c2.pdf',
      body:
          'اعتمدت الإدارة الجدول المدرسي المحدّث للفصل الدراسي الثاني، ويسري ابتداءً من يوم الأحد القادم. يمكن الاطلاع على جدول الطالب من شاشة «الجدول المدرسي» داخل التطبيق.',
    ),
    Circular(
      id: 'c3',
      title: 'تعميم بشأن الزي المدرسي',
      date: '28 شعبان',
      body:
          'نأمل من أولياء الأمور متابعة التزام الطلاب بالزي المدرسي المعتمد طوال أيام الدراسة، حرصاً على انضباط البيئة المدرسية.',
    ),
  ];

  // ─── د5 الإجراءات الإدارية ───────────────────────────────────────────────
  static List<AdminAction> adminActions = [
    const AdminAction(
      id: 'ac1',
      title: 'استدعاء ولي الأمر',
      date: '12 رمضان',
      issuer: 'وكيل شؤون الطلاب',
      source: AdminActionSource.attendance,
      state: AdminActionState.needsAttendance,
      linkedNote: 'غياب بدون عذر — 3 أيام متصلة',
      occurrenceLabel: 'المرة الثانية على هذه الملاحظة',
      body:
          'يُرجى الحضور لمقابلة وكيل شؤون الطلاب يوم الأحد 17 رمضان الساعة 09:00 لمناقشة تكرار الغياب.',
      appointment: 'الأحد 17 رمضان الساعة 09:00',
    ),
    const AdminAction(
      id: 'ac2',
      title: 'إشعار ولي الأمر بالملاحظة',
      date: '12 رمضان',
      issuer: 'وكيل شؤون الطلاب',
      source: AdminActionSource.attendance,
      state: AdminActionState.needsAcknowledge,
      linkedNote: 'غياب بدون عذر — 3 أيام متصلة',
      occurrenceLabel: 'المرة الأولى على هذه الملاحظة',
      body:
          'سُجّل غياب متصل لثلاثة أيام بدون عذر مقبول. نأمل الاطلاع ومتابعة انتظام الطالب.',
    ),
    const AdminAction(
      id: 'ac3',
      title: 'حسم درجات المواظبة',
      date: '6 رمضان',
      issuer: 'نظام المواظبة',
      source: AdminActionSource.attendance,
      state: AdminActionState.needsAcknowledge,
      linkedNote: 'غياب بدون عذر — يومان',
      occurrenceLabel: 'المرة الأولى على هذه الملاحظة',
      highlight: 'حُسم 2 من 10 درجات',
      body:
          'يُحسم من درجة المواظبة عند كل يوم غياب بدون عذر مقبول، وتُعاد الدرجة عند قبول العذر.',
    ),
    const AdminAction(
      id: 'ac4',
      title: 'إحالة إلى المرشد الطلابي',
      date: '3 رمضان',
      issuer: 'معلم الرياضيات',
      source: AdminActionSource.behavior,
      state: AdminActionState.seen,
      linkedNote: 'إزعاج داخل الفصل أثناء الشرح',
      occurrenceLabel: 'المرة الثالثة على هذه الملاحظة',
      body:
          'أُحيل الطالب للمرشد الطلابي بعد تكرار الملاحظة ثلاث مرات، لجلسة إرشادية ومتابعة أسبوعية.',
    ),
    const AdminAction(
      id: 'ac5',
      title: 'إشعار ولي الأمر بالملاحظة',
      date: '2 رمضان',
      issuer: 'وكيل شؤون الطلاب',
      source: AdminActionSource.behavior,
      state: AdminActionState.seen,
      linkedNote: 'عدم الالتزام بالزي المدرسي',
      occurrenceLabel: 'المرة الثانية على هذه الملاحظة',
      body: 'تكرر عدم الالتزام بالزي المدرسي المعتمد. نأمل التعاون في متابعة الطالب.',
    ),
    const AdminAction(
      id: 'ac6',
      title: 'تنبيه شفهي للطالب',
      date: '28 شعبان',
      issuer: 'وكيل شؤون الطلاب',
      source: AdminActionSource.behavior,
      state: AdminActionState.seen,
      linkedNote: 'عدم الالتزام بالزي المدرسي',
      occurrenceLabel: 'المرة الأولى على هذه الملاحظة',
      body: 'نُبّه الطالب شفهياً داخل المدرسة، ولا يتطلب الإجراء أكثر من اطلاعكم.',
    ),
  ];

  // ─── هـ3 التنبيهات ───────────────────────────────────────────────────────
  static const List<NotificationPreview> notificationPreviews = [
    NotificationPreview(
      title: 'سُجّل غياب بدون عذر',
      body: 'عبدالرحمن — الثلاثاء 12 رمضان · قدّم عذر الغياب من التطبيق',
      age: 'الآن',
    ),
    NotificationPreview(
      title: 'ملاحظة سلوك جديدة',
      body: 'مشاركة متميزة في حل تمارين الوحدة — أ. ماجد القحطاني',
      age: 'قبل 5 د',
    ),
    NotificationPreview(
      title: 'استدعاء ولي الأمر',
      body: 'الأحد 17 رمضان الساعة 09:00 — يتطلب تأكيد حضورك',
      age: 'قبل ساعة',
    ),
  ];

  static List<NotificationSetting> notificationSettings = [
    const NotificationSetting(
      key: 'attendance',
      title: 'الغياب والتأخر',
      subtitle: 'إشعار فوري عند تسجيل غياب أو تأخر',
      enabled: true,
    ),
    const NotificationSetting(
      key: 'behavior',
      title: 'ملاحظات السلوك',
      subtitle: 'الإيجابية وما يحتاج إلى تحسين',
      enabled: true,
    ),
    const NotificationSetting(
      key: 'actions',
      title: 'الإجراءات الإدارية',
      subtitle: 'الإشعارات التي تتطلب اطلاعك',
      enabled: true,
    ),
    const NotificationSetting(
      key: 'exams',
      title: 'مواعيد الاختبارات',
      subtitle: 'تذكير قبل الاختبار بثلاثة أيام',
      enabled: true,
    ),
    const NotificationSetting(
      key: 'circulars',
      title: 'التعاميم الإدارية',
      subtitle: 'كل تعميم جديد من الإدارة',
      enabled: false,
    ),
    const NotificationSetting(
      key: 'excuse_result',
      title: 'نتيجة عذر الغياب',
      subtitle: 'قبول أو رفض العذر المُقدَّم',
      enabled: true,
    ),
  ];

  // ─── هـ5 / هـ6 التواصل ───────────────────────────────────────────────────
  static const SchoolInfo school = SchoolInfo(
    name: 'متوسطة الأمير سلطان',
    office: 'مكتب وكيل شؤون الطلاب',
    phone: '0114567890',
    rows: [
      ContactRow(
          label: 'هاتف المدرسة',
          value: '\u2066011 456 7890\u2069',
          kind: ContactKind.phone,
          action: 'tel:0114567890'),
      ContactRow(
          label: 'البريد الإلكتروني',
          value: 'info@sultan.edu.sa',
          kind: ContactKind.email,
          action: 'mailto:info@sultan.edu.sa'),
      ContactRow(
          label: 'ساعات العمل',
          value: 'الأحد - الخميس · \u206607:00 - 14:00\u2069',
          kind: ContactKind.hours),
      ContactRow(label: 'العنوان', value: 'حي النخيل، الرياض', kind: ContactKind.address),
    ],
  );

  static const SchoolInfo support = SchoolInfo(
    name: 'الدعم الفني',
    office: '',
    phone: '920001234',
    rows: [
      ContactRow(
          label: 'الدعم الهاتفي',
          value: '\u2066920 001 234\u2069',
          kind: ContactKind.phone,
          action: 'tel:920001234'),
      ContactRow(
          label: 'البريد',
          value: 'support@smartble.sa',
          kind: ContactKind.email,
          action: 'mailto:support@smartble.sa'),
      ContactRow(
          label: 'زمن الاستجابة', value: 'خلال 24 ساعة عمل', kind: ContactKind.hours),
    ],
  );

  // ─── هـ7 الأسئلة الشائعة ─────────────────────────────────────────────────
  static const List<FaqItem> faq = [
    FaqItem(
      question: 'كيف أربط ابناً جديداً بحسابي؟',
      answer:
          'الربط يتم من إدارة المدرسة: زوّدها برقم جوالك المسجّل، فتربط سجل الطالب به ويظهر في التطبيق تلقائياً.',
    ),
    FaqItem(
      question: 'ما المدة المتاحة لتقديم عذر الغياب؟',
      answer:
          'يمكن تقديم العذر خلال ثلاثة أيام عمل من تاريخ الغياب، وتراجعه الإدارة خلال يوم عمل ويصلك إشعار بالنتيجة.',
    ),
    FaqItem(
      question: 'من يرى بيانات الحالة الصحية؟',
      answer:
          'تظهر لمرشد الصحة المدرسية فقط، وتُستخدم عند الطوارئ. ولا يطّلع عليها المعلمون ولا بقية منسوبي المدرسة.',
    ),
    FaqItem(
      question: 'لماذا لا تظهر درجات الاختبارات؟',
      answer:
          'يعرض التطبيق مواعيد الاختبارات وتفاصيلها التي يكتبها المعلم. أما الدرجات فتُعلن من نظام نور بعد اعتمادها.',
    ),
    FaqItem(
      question: 'نسيت كلمة المرور، ماذا أفعل؟',
      answer:
          'اضغط «نسيت كلمة المرور؟» في شاشة الدخول وأدخل رقم جوالك المسجّل، ويصلك رابط لتحديثها صالح لمدة 30 دقيقة.',
    ),
  ];

  // ─── هـ8 الصفحات الثابتة ─────────────────────────────────────────────────
  static const StaticPage about = StaticPage(
    title: 'من نحن',
    updatedAt: '8 رمضان 1447',
    paragraphs: [
      'الجدول الذكي منصة سعودية لإدارة العملية التعليمية داخل المدرسة، تربط المعلم والإدارة وولي الأمر في نظام واحد.',
      'تطبيق ولي الأمر هو الواجهة المخصصة لك: يمنحك صورة يومية واضحة عن جدول ابنك ومواظبته وسلوكه وحالته الصحية، ويتيح لك التفاعل مع الإدارة دون الحاجة لزيارة المدرسة.',
      'نعمل مع مدارس التعليم العام والتعليم الأهلي، ونطوّر خدماتنا بناءً على ملاحظات أولياء الأمور والمعلمين.',
    ],
  );

  static const StaticPage privacy = StaticPage(
    title: 'سياسة الخصوصية',
    updatedAt: '8 رمضان 1447',
    paragraphs: [
      'نجمع من بياناتك ما يلزم لربطك بأبنائك وتقديم خدمات التطبيق: الاسم ورقم الجوال والبريد الإلكتروني ورقم الهوية، إضافة إلى ما تدخله من أعذار وبيانات صحية.',
      'بيانات الحالة الصحية تظهر لمرشد الصحة المدرسية فقط وتُستخدم عند الطوارئ، ولا يطّلع عليها المعلمون.',
      'لا تُشارك بياناتك مع أي جهة خارج المدرسة ومنصة الجدول الذكي، ولا تُستخدم في الإعلانات.',
      'يمكنك طلب حذف حسابك في أي وقت من شاشة «حذف الحساب»، وتبقى السجلات المدرسية الرسمية محفوظة لدى المدرسة.',
    ],
  );

  static const StaticPage terms = StaticPage(
    title: 'الشروط والأحكام',
    updatedAt: '8 رمضان 1447',
    paragraphs: [
      'استخدام التطبيق مقصور على ولي أمر الطالب المسجَّل رقم جواله لدى المدرسة، ولا يجوز مشاركة بيانات الدخول مع غيره.',
      'المعلومات المعروضة في التطبيق تعكس ما تسجّله المدرسة في نظامها، وأي اعتراض عليها يُوجَّه إلى إدارة المدرسة.',
      'تقديم عذر غياب غير صحيح أو مرفق غير سليم يعرّض العذر للرفض ويُبلَّغ به ولي الأمر.',
      'قد تُحدَّث هذه الشروط، ويُعلَن التحديث داخل التطبيق قبل سريانه.',
    ],
  );

  /// منصات المشاركة في شاشة هـ٩ — أيقوناتها مواضع مؤقتة كما ينصّ التصميم.
  static const List<String> sharePlatforms = [
    'واتساب',
    'تيليجرام',
    'X',
    'سناب شات',
    'انستقرام',
    'الرسائل',
  ];

  /// الشرائح التعريفية الثلاث (شاشة A2). نصّ الأولى من التصميم، والتاليتان
  /// مكتوبتان على منواله لأن الحزمة تعرض شريحة واحدة فقط.
  static const List<List<String>> onboarding = [
    [
      'كل ما يخص أبنائك في مكان واحد',
      'الجدول المدرسي، المواظبة، السلوك، ومواعيد الاختبارات — لكل طالب مرتبط برقم جوالك.',
    ],
    [
      'قدّم عذر الغياب من جوالك',
      'أيام الغياب المتصلة تُجمع في فترة واحدة، وعذر واحد يغطيها كلها مع إمكانية إرفاق تقرير طبي.',
    ],
    [
      'يصلك التنبيه فور تسجيله',
      'غياب أو ملاحظة سلوك أو استدعاء — يصلك إشعار فوري، وتتحكم في نوع ما تستلمه من الإعدادات.',
    ],
  ];
}
