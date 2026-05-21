import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/profile/domain/repos/profile_repo.dart';
import 'package:not_insta/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  //fetch user profile using repo
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User Not Found!!!"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //update bio or profile picture
}
