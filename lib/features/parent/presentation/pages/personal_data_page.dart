import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/app_text_field.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_avatar.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/parent_model.dart';
import '../../domain/entities/service_entities.dart';
import '../bloc/profile/profile_bloc.dart';
import 'otp_page.dart';
import 'main_shell.dart';

/// هـ1 البيانات الشخصية — ورقم الجوال قابل للتعديل ويطلب رمز تحقق.
class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  final _email = TextEditingController();
  final _workplace = TextEditingController();
  final _phone = TextEditingController();

  /// الحقول تُملأ مرة واحدة من الخادم؛ ملؤها في كل بناء يقفز بالمؤشّر إلى
  /// أول الحقل مع كل حرف.
  bool _filled = false;

  /// رقم الجوال معرّف الحساب لدى المدرسة، فتغييره يمرّ برمز تحقق لا بحفظ
  /// مباشر — وهو ما تنصّ عليه الشاشة.
  String _originalPhone = '';

  @override
  void dispose() {
    _name.dispose();
    _nationalId.dispose();
    _email.dispose();
    _workplace.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _fill(ParentUser user) {
    _filled = true;
    _name.text = user.name;
    _nationalId.text = user.nationalId;
    _email.text = user.email;
    _workplace.text = user.workplace;
    _phone.text = user.phone;
    _originalPhone = user.phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<ProfileBloc>()..add(GetProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadedState && !_filled) {
            _fill(state.user);
            setState(() {});
          } else if (state is ProfileSavedState) {
            AppUtils.showCustomSnackbar(AppText.changesSaved, SnackType.SUCESS);
          } else if (state is ProfileFailureState) {
            AppUtils.showCustomSnackbar(
                state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.personalDataTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const ParentAvatar(size: 75),
                    SizedBox(height: 14.h),
                    _editPhoto(context),
                  ],
                ),
                SizedBox(height: 26.h),
                _field(AppText.fullName, _name),
                _field(AppText.nationalId, _nationalId,
                    keyboardType: TextInputType.number),
                _field(AppText.email, _email,
                    keyboardType: TextInputType.emailAddress),
                _field(AppText.workplace, _workplace),
                _field(
                  AppText.phoneNumber,
                  _phone,
                  icon: AppIcons.phone,
                  keyboardType: TextInputType.phone,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: 12.h),
                FieldHint(AppText.phoneIsIdentifier),
                SizedBox(height: 26.h),
                PrimaryButton(
                  label: AppText.saveChanges,
                  onTap: () => _save(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _editPhoto(BuildContext context) => GestureDetector(
        onTap: () async {
          final picked =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (picked != null && context.mounted) {
            context.read<ProfileBloc>().add(PickAvatarEvent(path: picked.path));
          }
        },
        child: Container(
          height: 27.h,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              AppText.editPhoto,
              style: AppTextStyles.smallButton.copyWith(color: Colors.white),
            ),
          ),
        ),
      );

  Widget _field(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    TextAlign textAlign = TextAlign.right,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(label),
          SizedBox(height: 10.h),
          AppTextField(
            controller: controller,
            icon: icon,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            textAlign: textAlign,
          ),
          SizedBox(height: 18.h),
        ],
      );

  void _save(BuildContext context) {
    // الرقم الجديد لا يُحفظ قبل التحقق منه، وإلا فقد ولي الأمر معرّفه لدى
    // المدرسة بخطأ مطبعي.
    if (_phone.text.trim() != _originalPhone) {
      AppUtils.go(OtpPage(phone: _phone.text.trim()));
      return;
    }
    context.read<ProfileBloc>().add(SaveProfileEvent(
          entity: ProfileEntity(
            name: _name.text.trim(),
            nationalId: _nationalId.text.trim(),
            email: _email.text.trim(),
            workplace: _workplace.text.trim(),
            phone: _phone.text.trim(),
          ),
        ));
  }
}
