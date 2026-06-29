import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:not_insta/features/home/presentation/components/my_drawer.dart';
import 'package:not_insta/features/post/presentation/components/post_tile.dart';
import 'package:not_insta/features/post/presentation/cubits/post_cubit.dart';
import 'package:not_insta/features/post/presentation/cubits/post_states.dart';

import '../../../post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  // on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload new image
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadPostPage(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      drawer: const MyDrawer(),

      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading
          if (state is PostsLoading || state is PostUploading) {
            return Center(child: const CircularProgressIndicator());
          }
          // loaded
          else if (state is PostsLoaded) {
            final allPosts = state.posts;
            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No Posts Available..."),
              );
            }
            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                // get individual posts
                final post = allPosts[index];
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }
          // error
          else if (state is PostsError) {
            return Center(
              child: Text(
                state.message,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
