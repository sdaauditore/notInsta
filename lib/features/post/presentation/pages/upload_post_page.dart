import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/auth/domain/entities/app_user.dart';
import 'package:not_insta/features/auth/presentation/components/my_text_field.dart';
import 'package:not_insta/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:not_insta/features/post/domain/entities/post.dart';
import 'package:not_insta/features/post/presentation/cubits/post_cubit.dart';
import 'package:not_insta/features/post/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // caption
  final textController = TextEditingController();

  // current user
  AppUser? currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // create and upload post
  void uploadPost() {
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Both Image and caption is required")),
      );
      return;
    }

    // create a new post
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: '',
      text: textController.text,
      timeStamp: DateTime.now(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      likes: [],
      comments: [],
    );

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }
    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  // dispose
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // UI by me
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      // 1. Listen for the dedicated event state or errors
      listener: (context, state) {
        if (state is PostCreated) {
          // Success! Go back to the previous screen (Feed)
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post uploaded successfully!")),
          );
        }

        if (state is PostsError) {
          // Show error feedback if something went wrong
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },

      // 2. Build the UI based on state
      builder: (context, state) {
        // Show loading spinner during upload or fetching process
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Return normal upload form layout
        return buildUploadPage();
      },
    );
  }

  // UI
  // @override
  // Widget build(BuildContext context) {
  //   return BlocConsumer<PostCubit, PostState>(
  //     builder: (context, state) {
  //
  //       // loading or uploading
  //       if (state is PostsLoading || state is PostUploading) {
  //         return const Scaffold(
  //           body: Center(
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       }
  //       // build upload page
  //       return buildUploadPage();
  //     },
  //
  //     // go to previous page when upload is done
  //     listener: (context, state) {
  //       if (state is PostsLoaded) {
  //         Navigator.pop(context);
  //       }
  //     },
  //   );
  // }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title: const Text("Create New Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload button
          IconButton(
            onPressed: uploadPost,
            icon: Icon(Icons.upload),
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: [
            //image preview for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),

            //image preview for mobile
            if (!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            // pick image button
            MaterialButton(
              color: Colors.blueAccent,
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            // caption text
            MyTextField(
              controller: textController,
              hintText: "Caption",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }
}
