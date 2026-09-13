import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/app_utils.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_me_use_case.dart';
import '../../../domain/usecases/update_profile_use_case.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// البيانات الشخصية لولي الأمر (شاشة هـ١) وما تعرضه شاشة «حسابي» منها.
class ProfileBloc extends BaseBloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.getMeUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) async {
      if (event is GetProfileEvent) {
        emit(ProfileLoading());
        result = await getMeUseCase();
        await result.fold(
          (failure) async => emit(ProfileFailureState(failure: failure)),
          (value) async {
            final user = value as ParentUser;
            await AppUtils.instance.setUser(user);
            emit(ProfileLoadedState(user: user, avatarPath: _avatarPath));
          },
        );
      } else if (event is PickAvatarEvent) {
        _avatarPath = event.path;
        final user = AppUtils.appUser;
        if (user != null) {
          emit(ProfileLoadedState(user: user, avatarPath: _avatarPath));
        }
      } else if (event is SaveProfileEvent) {
        result = await updateProfileUseCase(event.entity);
        await result.fold(
          (failure) async => emit(ProfileFailureState(failure: failure)),
          (value) async {
            final user = value as ParentUser;
            await AppUtils.instance.setUser(user);
            emit(ProfileSavedState(user: user));
            emit(ProfileLoadedState(user: user, avatarPath: _avatarPath));
          },
        );
      }
    });
  }

  final GetMeUseCase getMeUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  String? _avatarPath;
}
