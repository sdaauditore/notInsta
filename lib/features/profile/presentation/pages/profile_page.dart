import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/auth/domain/entities/app_user.dart';
import 'package:not_insta/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:not_insta/features/profile/presentation/cubits/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  //on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // load user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(currentUser!.email),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
