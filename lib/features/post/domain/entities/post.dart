import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;

  Post({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.timeStamp,
    required this.userId,
    required this.userName,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text,
      timeStamp: timeStamp,
      userId: userId,
      userName: userName,
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
    };
  }

  //convert json to post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      text: json['text'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
      userId: json['userId'],
      userName: json['userName'],
    );
  }
}
