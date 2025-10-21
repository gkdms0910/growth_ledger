import 'package:flutter/material.dart';
import 'package:growth_ledger/models/social_post.dart';
import 'package:growth_ledger/models/user.dart';
import 'package:growth_ledger/services/social_service.dart';
import 'package:intl/intl.dart';

class SocialScreen extends StatefulWidget {
  final User currentUser;

  const SocialScreen({super.key, required this.currentUser});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final SocialService _socialService = SocialService();
  List<SocialPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final posts = await _socialService.loadFeed();
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _toggleLike(String postId) async {
    final posts = await _socialService.toggleLike(
      postId: postId,
      userEmail: widget.currentUser.email,
    );
    setState(() {
      _posts = posts;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openCreatePostSheet() async {
    final goalController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '목표 공유하기',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                if (!isSubmitting) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: goalController,
                          decoration: const InputDecoration(
                            labelText: '관련 목표 (선택 사항)',
                            hintText: '예: 3개월 안에 10km 마라톤 완주하기',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: contentController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: '공유할 내용',
                            hintText: '오늘의 진행 상황, 배운 점 등을 기록해보세요.',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '내용을 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setSheetState(() {
                                    isSubmitting = true;
                                  });
                                  try {
                                    final posts = await _socialService.createPost(
                                      authorName: widget.currentUser.name,
                                      authorEmail: widget.currentUser.email,
                                      content: contentController.text,
                                      goalTitle: goalController.text,
                                    );
                                    if (!mounted) return;
                                    setState(() {
                                      _posts = posts;
                                    });
                                    Navigator.of(context).pop();
                                    _showSnack('목표를 공유했어요!');
                                  } on StateError catch (error) {
                                    _showSnack(error.message);
                                  } catch (_) {
                                    _showSnack('게시글 작성에 실패했습니다. 다시 시도해주세요.');
                                  } finally {
                                    setSheetState(() {
                                      isSubmitting = false;
                                    });
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('공유하기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    goalController.dispose();
    contentController.dispose();
  }

  Future<void> _openComments(SocialPost initialPost) async {
    final commentController = TextEditingController();
    var sheetPost = initialPost;
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            final maxHeight = MediaQuery.of(sheetContext).size.height * 0.75;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SizedBox(
                  height: maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              '댓글',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              if (!isSubmitting) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: sheetPost.comments.isEmpty
                              ? const Center(child: Text('가장 먼저 댓글을 남겨보세요!'))
                              : ListView.separated(
                                  itemCount: sheetPost.comments.length,
                                  separatorBuilder: (_, __) => const Divider(height: 24),
                                  itemBuilder: (context, index) {
                                    final comment = sheetPost.comments[index];
                                    final timestamp = DateFormat('MM월 dd일 HH:mm').format(comment.createdAt);
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timestamp,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: commentController,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: '응원 메시지나 피드백을 남겨보세요.',
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final text = commentController.text.trim();
                                      if (text.isEmpty) {
                                        _showSnack('댓글을 입력해주세요.');
                                        return;
                                      }
                                      setSheetState(() {
                                        isSubmitting = true;
                                      });
                                      try {
                                        final updatedPosts = await _socialService.addComment(
                                          postId: sheetPost.id,
                                          authorName: widget.currentUser.name,
                                          authorEmail: widget.currentUser.email,
                                          content: text,
                                        );
                                        if (!mounted) return;
                                        SocialPost? refreshedPost;
                                        for (final post in updatedPosts) {
                                          if (post.id == sheetPost.id) {
                                            refreshedPost = post;
                                            break;
                                          }
                                        }
                                        setState(() {
                                          _posts = updatedPosts;
                                        });
                                        if (refreshedPost != null) {
                                          final nonNullPost = refreshedPost;
                                          setSheetState(() {
                                            sheetPost = nonNullPost;
                                            commentController.clear();
                                          });
                                          _showSnack('댓글을 남겼어요!');
                                        }
                                      } on StateError catch (error) {
                                        _showSnack(error.message);
                                      } catch (_) {
                                        _showSnack('댓글을 저장하지 못했습니다. 잠시 후 다시 시도해주세요.');
                                      } finally {
                                        setSheetState(() {
                                          isSubmitting = false;
                                        });
                                      }
                                    },
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('댓글 남기기'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소셜'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: _posts.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('아직 피드가 비어있어요. 첫 목표를 공유해보세요!')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return _SocialPostCard(
                          post: post,
                          isLiked: post.isLikedBy(widget.currentUser.email),
                          onLikePressed: () => _toggleLike(post.id),
                          onCommentPressed: () => _openComments(post),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePostSheet,
        icon: const Icon(Icons.add),
        label: const Text('공유하기'),
      ),
    );
  }
}

class _SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;

  const _SocialPostCard({
    required this.post,
    required this.isLiked,
    required this.onLikePressed,
    required this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM월 dd일 HH:mm').format(post.createdAt);
    final theme = Theme.of(context);
    final likeColor = isLiked ? theme.colorScheme.secondary : theme.disabledColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(post.authorName.characters.first),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: theme.textTheme.titleMedium),
                      Text(formattedDate, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (post.goalTitle != null) ...[
              Text(
                post.goalTitle!,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              post.content,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: likeColor,
                  ),
                  onPressed: onLikePressed,
                  tooltip: isLiked ? '좋아요 취소' : '좋아요',
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined),
                  onPressed: onCommentPressed,
                  tooltip: '댓글 보기',
                ),
                Text('${post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
