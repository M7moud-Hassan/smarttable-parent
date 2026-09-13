import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/share/widgets/app_bottom_nav.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../bloc/notifications/notifications_bloc.dart';
import '../bloc/students/students_bloc.dart';
import 'account_page.dart';
import 'home_page.dart';
import 'notifications_page.dart';

/// حاضنة التبويبات الثلاثة (B1 / B2 / B3).
///
/// التبويبات تعيش في `IndexedStack` لا في `Navigator`: التنقّل بينها لا يُعيد
/// تحميل الشاشة ولا يفقد موضع التمرير، وهو ما يجعل شريط الأبناء يبدو ثابتاً
/// كما في التصميم.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = ParentTab.home});

  final ParentTab initialTab;

  /// يفتح تبويباً من شاشة داخلية: الشاشات الداخلية تعرض الشريط السفلي نفسه،
  /// وضغط تبويب منه يعود إلى الحاضنة عليه لا يفتح نسخة ثانية فوقها.
  static void openTab(ParentTab tab) => AppUtils.goAndReplace(MainShell(initialTab: tab));

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late ParentTab _tab = widget.initialTab;

  /// ينقل إلى تبويب من خارج الشريط — إشعار يفتح شاشته مثلاً.
  void select(ParentTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // البلوكان يعيشان فوق التبويبات لأن كليهما يخدم أكثر من تبويب:
        // الأبناء يظهرون في الرئيسية والشريط الجانبي، وعدّاد الإشعارات
        // يظهر على الشريط السفلي في كل تبويب.
        BlocProvider(create: (_) => bloc<StudentsBloc>()..add(GetStudentsEvent())),
        BlocProvider(
            create: (_) => bloc<NotificationsBloc>()..add(GetNotificationsEvent())),
      ],
      child: IndexedStack(
        index: _tab.index,
        children: [
          NotificationsPage(tab: _tab, onTab: select),
          HomePage(tab: _tab, onTab: select),
          AccountPage(tab: _tab, onTab: select),
        ],
      ),
    );
  }
}
