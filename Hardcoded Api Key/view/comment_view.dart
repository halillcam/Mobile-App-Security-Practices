import 'package:flutter/material.dart';
import 'package:service_test_new/Service/comment_model.dart';
import 'package:service_test_new/Service/comment_service.dart';

class CommentView extends StatefulWidget {
  const CommentView({super.key});

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  final CommentService _commentService = CommentService();
  late final Future<List<CommentModel>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _commentService.getDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yorumlar')),
      body: FutureBuilder<List<CommentModel>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Yorumlar yüklenemedi: ${snapshot.error}'));
          }

          final comments = snapshot.data ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text('Gösterilecek yorum yok.'));
          }

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${comment.id ?? ''}')),
                title: Text(comment.body ?? ''),
                subtitle: Text(comment.user?.fullName ?? 'Bilinmeyen kullanıcı'),
                trailing: Text('❤️ ${comment.likes ?? 0}'),
              );
            },
          );
        },
      ),
    );
  }
}
