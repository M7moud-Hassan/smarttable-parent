import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/dimensions.dart';
import '../../utils/responsive.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'sidebar.dart';

/// الهيكل المشترك لكل شاشات التطبيق.
///
/// يجمع ما يتكرّر في كل ملفات التصميم: ترويسة بارتفاع ثابت، جسم يُمرَّر بهامش
/// أفقي 24، وشريط سفلي بثلاثة تبويبات. وفي التابلت (شاشة B4) يحلّ الشريط
/// الجانبي محلّ السفلي وتبقى بقية المكوّنات كما هي.
class ParentScaffold extends StatelessWidget {
  const ParentScaffold({
    super.key,
    required this.body,
    this.title,
    this.onBack,
    this.showAvatarInHeader = true,
    this.headerTrailing,
    this.customHeader,
    this.showBottomNav = false,
    this.currentTab,
    this.onTabSelected,
    this.hasUnreadNotifications = false,
    this.backgroundColor = AppColors.surface,
    this.bodyPadding,
    this.scrollable = true,
    this.bottom,
  });

  /// جسم الشاشة. يُلفّ بـ `SingleChildScrollView` ما لم يُطلب خلاف ذلك.
  final Widget body;

  final String? title;
  final VoidCallback? onBack;
  final bool showAvatarInHeader;
  final Widget? headerTrailing;

  /// ترويسة كاملة بديلة — ترويسة الرئيسية الملوّنة مثلاً.
  final Widget? customHeader;

  /// يُظهر الشريط السفلي. شاشات مسار الدخول وحدها بلا شريط.
  final bool showBottomNav;

  /// التبويب النشط. `null` مع `showBottomNav` يعرض الشريط بلا تمييز أيّ
  /// تبويب — وهي حال الشاشات الداخلية في التصميم.
  final ParentTab? currentTab;
  final ValueChanged<ParentTab>? onTabSelected;
  final bool hasUnreadNotifications;

  final Color backgroundColor;
  final EdgeInsetsGeometry? bodyPadding;
  final bool scrollable;

  /// عنصر ثابت أسفل الجسم فوق الشريط السفلي.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    final content = Column(
      children: [
        if (customHeader != null)
          customHeader!
        else if (title != null)
          ScreenHeader(
            title: title!,
            onBack: onBack,
            showAvatar: showAvatarInHeader,
            trailing: headerTrailing,
          ),
        Expanded(child: _body()),
        if (bottom != null) bottom!,
        if (showBottomNav && !isTablet)
          AppBottomNav(
            current: currentTab,
            onSelect: onTabSelected ?? (_) {},
            hasUnreadNotifications: hasUnreadNotifications,
          ),
      ],
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: isTablet && showBottomNav
            ? Row(
                children: [
                  ParentSidebar(
                    current: currentTab,
                    onSelect: onTabSelected ?? (_) {},
                  ),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
    );
  }

  Widget _body() {
    final padded = Padding(
      padding: bodyPadding ??
          EdgeInsets.fromLTRB(
            Dimensions.screenPadding,
            6.h,
            Dimensions.screenPadding,
            28.h,
          ),
      child: body,
    );
    if (!scrollable) return padded;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: padded,
    );
  }
}
