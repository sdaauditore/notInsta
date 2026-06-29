import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/post/presentation/cubits/post_states.dart';
import 'package:not_insta/features/post/repos/post_repo.dart';
import 'package:not_insta/features/storage/domain/storage_repo.dart';

import '../../domain/entities/post.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // create a new post
  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;

    try {
      // handle image upload from mobile
      if (imagePath != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadProfileImageMobile(
          imagePath,
          post.id,
        );
      }
      // handle image upload from web
      else if (imageBytes != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadProfileImageWeb(imageBytes, post.id);
      }

      // give image url to post
      final newPost = post.copyWith(imageUrl: imageUrl);

      // create post in backend
      postRepo.createPost(newPost);

      // refetch all posts
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to create post : $e"));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch all posts : $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError("Failed to delete post : $e"));
    }
  }
}
