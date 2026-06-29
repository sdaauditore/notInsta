import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/post/domain/entities/comment.dart';
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
  // create a new post
  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;

    try {
      // Cleaned up: Just emit uploading once at the beginning
      emit(PostUploading());

      // handle image upload from mobile
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(
          imagePath,
          post.id,
        );
      }
      // handle image upload from web
      else if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // give image url to post
      final newPost = post.copyWith(imageUrl: imageUrl);

      // Save to backend (awaited safely)
      await postRepo.createPost(newPost);

      // Tell the UI right away that creation succeeded so it can pop the screen
      emit(PostCreated());

      // REMOVED: The duplicate postRepo.createPost(newPost); call that was causing the error is gone.

      // refetch all posts safely
      await fetchAllPosts();
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

  // toggle like on a post
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError("Fail to Like $e"));
    }
  }

  // add comment to post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  // delete comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }
}
