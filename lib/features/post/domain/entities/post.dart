import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_insta/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;
  final List<String> likes; // store uid
  final List<Comment> comments;

  Post({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.timeStamp,
    required this.userId,
    required this.userName,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text,
      timeStamp: timeStamp,
      userId: userId,
      userName: userName,
      likes: likes,
      comments: comments,
    );
  }

  //convert post to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  //convert json to post
  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments
    final List<Comment> comments = (json['comments'] as List<dynamic>?)?.map(
            (commentJson) => Comment.fromJson(commentJson)).toList() ?? [];
    return Post(
        id: json['id'],
        imageUrl: json['imageUrl'],
        text: json['text'],
        timeStamp: (json['timeStamp'] as Timestamp).toDate(),
        userId: json['userId'],
        userName: json['name'],
        likes: List<String>.from(json['likes'] ?? []),
        comments: comments,
    );
  }
}
