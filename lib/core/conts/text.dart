import 'package:easy_localization/easy_localization.dart';

/// نصوص الواجهة — مفاتيح تُقرأ من `assets/lang/<locale>.json`.
///
/// كانت ثوابتَ عربية، فكان تبديل اللغة من شاشة هـ4 يحفظ الاختيار ولا يغيّر
/// حرفًا واحدًا على الشاشة. وصارت مفاتيح: القيمة تُقرأ من الملفّ حسب اللغة
/// النشطة، فيتبدّل التطبيق كلّه — واتجاهه معه — بتبديل اللغة.
///
/// وهي خصائص لا ثوابت لأن `tr()` تقرأ اللغة وقت العرض، فلا تصحّ `const`.
class AppText {
  AppText._();

  static String get skip => 'skip'.tr();

  static String get next => 'next'.tr();

  static String get startNow => 'startNow'.tr();

  static String get loginTitle => 'loginTitle'.tr();

  static String get loginSubtitle => 'loginSubtitle'.tr();

  static String get usernameOrEmail => 'usernameOrEmail'.tr();

  static String get usernameHint => 'usernameHint'.tr();

  static String get password => 'password'.tr();

  static String get passwordHint => 'passwordHint'.tr();

  static String get forgotPassword => 'forgotPassword'.tr();

  static String get login => 'login'.tr();

  static String get or => 'or'.tr();

  static String get firstTimeHint => 'firstTimeHint'.tr();

  static String get firstTimeRegister => 'firstTimeRegister'.tr();

  static String get registerHint => 'registerHint'.tr();

  static String get enterLinkedPhone => 'enterLinkedPhone'.tr();

  static String get phoneHint => 'phoneHint'.tr();

  static String get sendOtp => 'sendOtp'.tr();

  static String get termsPrefix => 'termsPrefix'.tr();

  static String get termsLink => 'termsLink'.tr();

  static String get otpTitle => 'otpTitle'.tr();

  static String get otpSentTo => 'otpSentTo'.tr();

  static String get verify => 'verify'.tr();

  static String get otpNotReceived => 'otpNotReceived'.tr();

  static String get resend => 'resend'.tr();

  static String get createAccount => 'createAccount'.tr();

  static String get usernameRule => 'usernameRule'.tr();

  static String get email => 'email'.tr();

  static String get emailHint => 'emailHint'.tr();

  static String get passwordRule => 'passwordRule'.tr();

  static String get passwordMinHint => 'passwordMinHint'.tr();

  static String get confirmPassword => 'confirmPassword'.tr();

  static String get confirmPasswordHint => 'confirmPasswordHint'.tr();

  static String get confirmPasswordRule => 'confirmPasswordRule'.tr();

  static String get selectStudentTitle => 'selectStudentTitle'.tr();

  static String get yourChildren => 'yourChildren'.tr();

  static String get selectStudentSubtitle => 'selectStudentSubtitle'.tr();

  static String get missingChildHint => 'missingChildHint'.tr();

  static String get forgotTitle => 'forgotTitle'.tr();

  static String get forgotSubtitle => 'forgotSubtitle'.tr();

  static String get phoneNumber => 'phoneNumber'.tr();

  static String get sendResetLink => 'sendResetLink'.tr();

  static String get linkSent => 'linkSent'.tr();

  static String get linkSentTo => 'linkSentTo'.tr();

  static String get linkValidity => 'linkValidity'.tr();

  static String get openLink => 'openLink'.tr();

  static String get resendLink => 'resendLink'.tr();

  static String get updatePasswordTitle => 'updatePasswordTitle'.tr();

  static String get updatePasswordSubtitle => 'updatePasswordSubtitle'.tr();

  static String get newPassword => 'newPassword'.tr();

  static String get newPasswordHint => 'newPasswordHint'.tr();

  static String get passwordAdvice => 'passwordAdvice'.tr();

  static String get updatePassword => 'updatePassword'.tr();

  static String get home => 'home'.tr();

  static String get welcome => 'welcome'.tr();

  static String get swipeToSwitch => 'swipeToSwitch'.tr();

  static String get availableServices => 'availableServices'.tr();

  static String get submitExcuseCurrent => 'submitExcuseCurrent'.tr();

  static String get currentPeriod => 'currentPeriod'.tr();

  static String get allPeriods => 'allPeriods'.tr();

  static String get notifications => 'notifications'.tr();

  static String get markAllRead => 'markAllRead'.tr();

  static String get unreadCount => 'unreadCount'.tr();

  static String get noNotifications => 'noNotifications'.tr();

  static String get account => 'account'.tr();

  static String get editPhoto => 'editPhoto'.tr();

  static String get logout => 'logout'.tr();

  static String get myChildren => 'myChildren'.tr();

  static String get scheduleTitle => 'scheduleTitle'.tr();

  static String get currentPeriodLabel => 'currentPeriodLabel'.tr();

  static String get remaining => 'remaining'.tr();

  static String get noClassesToday => 'noClassesToday'.tr();

  static String get attendanceTitle => 'attendanceTitle'.tr();

  static String get daysPresent => 'daysPresent'.tr();

  static String get daysLate => 'daysLate'.tr();

  static String get daysAbsent => 'daysAbsent'.tr();

  static String get attendanceLog => 'attendanceLog'.tr();

  static String get attendanceLogHint => 'attendanceLogHint'.tr();

  static String get submitExcuseForPeriod => 'submitExcuseForPeriod'.tr();

  static String get excuseTitle => 'excuseTitle'.tr();

  static String get absencePeriod => 'absencePeriod'.tr();

  static String get coveredDays => 'coveredDays'.tr();

  static String get coveredDaysHint => 'coveredDaysHint'.tr();

  static String get noDaySelected => 'noDaySelected'.tr();

  static String get gapWarning => 'gapWarning'.tr();

  static String get absenceReason => 'absenceReason'.tr();

  static String get parentNote => 'parentNote'.tr();

  static String get excuseNoteHint => 'excuseNoteHint'.tr();

  static String get attachment => 'attachment'.tr();

  static String get attachFile => 'attachFile'.tr();

  static String get sendExcuse => 'sendExcuse'.tr();

  static String get excuseReviewHint => 'excuseReviewHint'.tr();

  static String get excuseSent => 'excuseSent'.tr();

  static String get behaviorTitle => 'behaviorTitle'.tr();

  static String get tabNotes => 'tabNotes'.tr();

  static String get tabStatistics => 'tabStatistics'.tr();

  static String get period => 'period'.tr();

  static String get thisWeek => 'thisWeek'.tr();

  static String get thisMonth => 'thisMonth'.tr();

  static String get thisTerm => 'thisTerm'.tr();

  static String get noteType => 'noteType'.tr();

  static String get all => 'all'.tr();

  static String get subject => 'subject'.tr();

  static String get teacher => 'teacher'.tr();

  static String get clearFilters => 'clearFilters'.tr();

  static String get noMatchingNotes => 'noMatchingNotes'.tr();

  static String get total => 'total'.tr();

  static String get notesDistribution => 'notesDistribution'.tr();

  static String get bySubject => 'bySubject'.tr();

  static String get byTeacher => 'byTeacher'.tr();

  static String get fourWeekChange => 'fourWeekChange'.tr();

  static String get weekCurrent => 'weekCurrent'.tr();

  static String get healthTitle => 'healthTitle'.tr();

  static String get healthPrivacy => 'healthPrivacy'.tr();

  static String get chronicDiseases => 'chronicDiseases'.tr();

  static String get schoolInstructions => 'schoolInstructions'.tr();

  static String get healthInstructionsHint => 'healthInstructionsHint'.tr();

  static String get medicalReport => 'medicalReport'.tr();

  static String get saveHealth => 'saveHealth'.tr();

  static String get healthSaved => 'healthSaved'.tr();

  static String get attachedSuffix => 'attachedSuffix'.tr();

  static String get examsTitle => 'examsTitle'.tr();

  static String get examsHint => 'examsHint'.tr();

  static String get examDetailsTitle => 'examDetailsTitle'.tr();

  static String get time => 'time'.tr();

  static String get place => 'place'.tr();

  static String get subjectTeacher => 'subjectTeacher'.tr();

  static String get teacherWritten => 'teacherWritten'.tr();

  static String get examTopics => 'examTopics'.tr();

  static String get teacherNotes => 'teacherNotes'.tr();

  static String get circularsTitle => 'circularsTitle'.tr();

  static String get circularTitle => 'circularTitle'.tr();

  static String get schoolAdministration => 'schoolAdministration'.tr();

  static String get downloadPdf => 'downloadPdf'.tr();

  static String get actionsTitle => 'actionsTitle'.tr();

  static String get actionsHint => 'actionsHint'.tr();

  static String get needsYourReview => 'needsYourReview'.tr();

  static String get linkedNote => 'linkedNote'.tr();

  static String get viewAttendanceLog => 'viewAttendanceLog'.tr();

  static String get viewBehaviorReport => 'viewBehaviorReport'.tr();

  static String get needsAttendanceConfirm => 'needsAttendanceConfirm'.tr();

  static String get confirmAttendance => 'confirmAttendance'.tr();

  static String get requestReschedule => 'requestReschedule'.tr();

  static String get acknowledged => 'acknowledged'.tr();

  static String get acknowledgeDone => 'acknowledgeDone'.tr();

  static String get attendanceConfirmed => 'attendanceConfirmed'.tr();

  static String get noActions => 'noActions'.tr();

  static String get personalDataTitle => 'personalDataTitle'.tr();

  static String get fullName => 'fullName'.tr();

  static String get nationalId => 'nationalId'.tr();

  static String get workplace => 'workplace'.tr();

  static String get phoneIsIdentifier => 'phoneIsIdentifier'.tr();

  static String get saveChanges => 'saveChanges'.tr();

  static String get changesSaved => 'changesSaved'.tr();

  static String get passwordTitle => 'passwordTitle'.tr();

  static String get currentPassword => 'currentPassword'.tr();

  static String get currentPasswordHint => 'currentPasswordHint'.tr();

  static String get passwordAdviceLong => 'passwordAdviceLong'.tr();

  static String get passwordUpdated => 'passwordUpdated'.tr();

  static String get alertsTitle => 'alertsTitle'.tr();

  static String get alertPreview => 'alertPreview'.tr();

  static String get whatToReceive => 'whatToReceive'.tr();

  static String get alertsKeptHint => 'alertsKeptHint'.tr();

  static String get languageTitle => 'languageTitle'.tr();

  static String get arabic => 'arabic'.tr();

  static String get arabicSubtitle => 'arabicSubtitle'.tr();

  static String get english => 'english'.tr();

  static String get englishSubtitle => 'englishSubtitle'.tr();

  static String get languageHint => 'languageHint'.tr();

  static String get contactSchoolTitle => 'contactSchoolTitle'.tr();

  static String get callSchool => 'callSchool'.tr();

  static String get supportTitle => 'supportTitle'.tr();

  static String get supportScope => 'supportScope'.tr();

  static String get openSupportChat => 'openSupportChat'.tr();

  static String get faqTitle => 'faqTitle'.tr();

  static String get aboutTitle => 'aboutTitle'.tr();

  static String get privacyTitle => 'privacyTitle'.tr();

  static String get termsTitle => 'termsTitle'.tr();

  static String get lastUpdated => 'lastUpdated'.tr();

  static String get shareTitle => 'shareTitle'.tr();

  static String get shareSubtitle => 'shareSubtitle'.tr();

  static String get copy => 'copy'.tr();

  static String get copied => 'copied'.tr();

  static String get shareVia => 'shareVia'.tr();

  static String get iconPlaceholder => 'iconPlaceholder'.tr();

  static String get shareIconsHint => 'shareIconsHint'.tr();

  static String get deleteAccountTitle => 'deleteAccountTitle'.tr();

  static String get deleteAccountHeading => 'deleteAccountHeading'.tr();

  static String get deleteAccountBody1 => 'deleteAccountBody1'.tr();

  static String get deleteAccountBody2 => 'deleteAccountBody2'.tr();

  static String get confirmDelete => 'confirmDelete'.tr();

  static String get cancel => 'cancel'.tr();

  static String get deleteRequested => 'deleteRequested'.tr();

  static String get retry => 'retry'.tr();

  static String get startupFailed => 'startupFailed'.tr();

  static String get selectStudentFirst => 'selectStudentFirst'.tr();
}
