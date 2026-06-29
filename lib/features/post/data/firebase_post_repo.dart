import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_insta/features/post/repos/post_repo.dart';

import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //store posts in a collection
  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error Creating Post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot = await postsCollection
          .orderBy('timeStamp', descending: true)
          .get();

      //convert to json
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception("Error fetching Posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      //fetch posts with this uid
      final postsSnapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .get();

      //convert firestore docs to json to list of posts
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetching posts by user $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // get post document from firestore
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // check if user has already liked it
        final hasLiked = post.likes.contains(userId);

        // update like list
        if (hasLiked) {
          post.likes.remove(userId); // unlike
        } else {
          post.likes.add(userId);
        }

        // update post document with the new liked list
        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception("Post Not Found!!!");
      }
    } catch (e) {
      throw Exception("Error in like : $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        // convert json to post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add new comment
        post.comments.add(comment);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        // convert json to post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add new comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}
