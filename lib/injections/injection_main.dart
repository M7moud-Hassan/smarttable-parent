import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/conts/api.dart';
import '../core/utils/app_utils.dart';
import '../core/utils/app_utils_imp.dart';
import '../core/utils/calling.dart';
import '../core/utils/check_internet.dart';
import '../core/utils/dio.dart';
import '../features/parent/data/datasources/db.dart';
import '../features/parent/data/datasources/db_remote.dart';
import '../features/parent/data/repositories/repo_imp.dart';
import '../features/parent/domain/repositories/repo.dart';
import '../features/parent/domain/usecases/change_password_use_case.dart';
import '../features/parent/domain/usecases/create_account_use_case.dart';
import '../features/parent/domain/usecases/delete_account_use_case.dart';
import '../features/parent/domain/usecases/forgot_password_use_case.dart';
import '../features/parent/domain/usecases/get_absence_period_use_case.dart';
import '../features/parent/domain/usecases/get_admin_actions_use_case.dart';
import '../features/parent/domain/usecases/get_attendance_use_case.dart';
import '../features/parent/domain/usecases/get_behavior_use_case.dart';
import '../features/parent/domain/usecases/get_circular_details_use_case.dart';
import '../features/parent/domain/usecases/get_circulars_use_case.dart';
import '../features/parent/domain/usecases/get_exam_details_use_case.dart';
import '../features/parent/domain/usecases/get_exams_use_case.dart';
import '../features/parent/domain/usecases/get_faq_use_case.dart';
import '../features/parent/domain/usecases/get_health_use_case.dart';
import '../features/parent/domain/usecases/get_home_use_case.dart';
import '../features/parent/domain/usecases/get_me_use_case.dart';
import '../features/parent/domain/usecases/get_notification_settings_use_case.dart';
import '../features/parent/domain/usecases/get_notifications_use_case.dart';
import '../features/parent/domain/usecases/get_schedule_use_case.dart';
import '../features/parent/domain/usecases/get_school_use_case.dart';
import '../features/parent/domain/usecases/get_static_page_use_case.dart';
import '../features/parent/domain/usecases/get_students_use_case.dart';
import '../features/parent/domain/usecases/get_support_use_case.dart';
import '../features/parent/domain/usecases/login_use_case.dart';
import '../features/parent/domain/usecases/mark_all_read_use_case.dart';
import '../features/parent/domain/usecases/request_otp_use_case.dart';
import '../features/parent/domain/usecases/reset_password_use_case.dart';
import '../features/parent/domain/usecases/respond_to_action_use_case.dart';
import '../features/parent/domain/usecases/save_health_use_case.dart';
import '../features/parent/domain/usecases/save_notification_settings_use_case.dart';
import '../features/parent/domain/usecases/submit_excuse_use_case.dart';
import '../features/parent/domain/usecases/update_profile_use_case.dart';
import '../features/parent/domain/usecases/verify_otp_use_case.dart';
import '../features/parent/presentation/bloc/actions/actions_bloc.dart';
import '../features/parent/presentation/bloc/attendance/attendance_bloc.dart';
import '../features/parent/presentation/bloc/auth/auth_bloc.dart';
import '../features/parent/presentation/bloc/behavior/behavior_bloc.dart';
import '../features/parent/presentation/bloc/circulars/circulars_bloc.dart';
import '../features/parent/presentation/bloc/content/content_bloc.dart';
import '../features/parent/presentation/bloc/exams/exams_bloc.dart';
import '../features/parent/presentation/bloc/excuse/excuse_bloc.dart';
import '../features/parent/presentation/bloc/health/health_bloc.dart';
import '../features/parent/presentation/bloc/home/home_bloc.dart';
import '../features/parent/presentation/bloc/notifications/notifications_bloc.dart';
import '../features/parent/presentation/bloc/profile/profile_bloc.dart';
import '../features/parent/presentation/bloc/schedule/schedule_bloc.dart';
import '../features/parent/presentation/bloc/settings/settings_bloc.dart';
import '../features/parent/presentation/bloc/students/students_bloc.dart';

final sl = AppUtils.sl;

/// تسجيل كل ما يحتاجه التطبيق، من الأدنى إلى الأعلى: خارجيات ← أدوات ←
/// مصدر بيانات ← مستودع ← حالات استخدام ← بلوكات.
Future<void> init() async {
  // ─── خارجيات ─────────────────────────────────────────────────────────────
  // `singletonAsync` لا `singleton`: قراءة التخزين المحلي قناة منصّة، وانتظارها
  // قبل `runApp` كان يجعل الإقلاع سباقاً من يخسره يرى شاشة بيضاء دائمة.
  sl.registerSingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());
  // `DioConfig.config()` يضبط بقية الخيارات عند الإقلاع.
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: Api.baseUrl)));
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // ─── أدوات ───────────────────────────────────────────────────────────────
  sl.registerSingletonWithDependencies<AppUtils>(
    () => AppUtilsImp(preferences: sl()),
    dependsOn: [SharedPreferences],
  );
  sl.registerLazySingleton<Calling>(() => Calling());
  sl.registerLazySingleton<DioConfig>(() => DioConfig(dio: sl()));
  sl.registerLazySingleton<CheckInternetConnection>(
      () => CheckInternetConnection(internetConnection: sl()));

  // ─── البيانات ────────────────────────────────────────────────────────────
  // مصدرٌ واحد لكل ما يُقرأ ويُكتب: واجهة `st_follower/parent_api` من الخادم.
  sl.registerLazySingleton<Db>(() => DbRemote(dio: sl()));
  sl.registerLazySingleton<Repo>(() => RepoImp(call: sl()));

  // ─── حالات الاستخدام ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => RequestOtpUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => CreateAccountUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetMeUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetStudentsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetHomeUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => MarkAllReadUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetNotificationSettingsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => SaveNotificationSettingsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetScheduleUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetAttendanceUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetAbsencePeriodUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => SubmitExcuseUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetBehaviorUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetHealthUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => SaveHealthUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetExamsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetExamDetailsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetCircularsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetCircularDetailsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetAdminActionsUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => RespondToActionUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetSchoolUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetSupportUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetFaqUseCase(repo: sl(), db: sl()));
  sl.registerLazySingleton(() => GetStaticPageUseCase(repo: sl(), db: sl()));

  // ─── البلوكات ────────────────────────────────────────────────────────────
  // `factory` لا `singleton`: كل فتح للشاشة يبدأ من حالة نظيفة، وإغلاقها
  // يغلق بلوكها.
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        requestOtpUseCase: sl(),
        verifyOtpUseCase: sl(),
        createAccountUseCase: sl(),
        forgotPasswordUseCase: sl(),
        resetPasswordUseCase: sl(),
        changePasswordUseCase: sl(),
        deleteAccountUseCase: sl(),
      ));
  sl.registerFactory(() => StudentsBloc(getStudentsUseCase: sl()));
  sl.registerFactory(() => HomeBloc(getHomeUseCase: sl()));
  sl.registerFactory(() => NotificationsBloc(
        getNotificationsUseCase: sl(),
        markAllReadUseCase: sl(),
      ));
  sl.registerFactory(() => ScheduleBloc(getScheduleUseCase: sl()));
  sl.registerFactory(() => AttendanceBloc(getAttendanceUseCase: sl()));
  sl.registerFactory(() => ExcuseBloc(
        getAbsencePeriodUseCase: sl(),
        submitExcuseUseCase: sl(),
      ));
  sl.registerFactory(() => BehaviorBloc(getBehaviorUseCase: sl()));
  sl.registerFactory(() => HealthBloc(
        getHealthUseCase: sl(),
        saveHealthUseCase: sl(),
      ));
  sl.registerFactory(() => ExamsBloc(
        getExamsUseCase: sl(),
        getExamDetailsUseCase: sl(),
      ));
  sl.registerFactory(() => CircularsBloc(
        getCircularsUseCase: sl(),
        getCircularDetailsUseCase: sl(),
      ));
  sl.registerFactory(() => ActionsBloc(
        getAdminActionsUseCase: sl(),
        respondToActionUseCase: sl(),
      ));
  sl.registerFactory(() => ProfileBloc(
        getMeUseCase: sl(),
        updateProfileUseCase: sl(),
      ));
  sl.registerFactory(() => SettingsBloc(
        getNotificationSettingsUseCase: sl(),
        saveNotificationSettingsUseCase: sl(),
      ));
  sl.registerFactory(() => ContentBloc(
        getSchoolUseCase: sl(),
        getSupportUseCase: sl(),
        getFaqUseCase: sl(),
        getStaticPageUseCase: sl(),
      ));
}

/// اختصار يقرأه كل من يفتح شاشة: بلوك جديد جاهز بحالاته.
T bloc<T extends Object>() => sl<T>();
