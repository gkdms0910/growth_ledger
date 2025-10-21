import 'package:uuid/uuid.dart';

import '../models/social_comment.dart';
import '../models/social_post.dart';
import 'storage_service.dart';

class SocialService {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  Future<List<SocialPost>> loadFeed() async {
    var posts = await _storageService.readSocialFeed();
    if (posts.isEmpty) {
      posts = _seedPosts();
      await _storageService.writeSocialFeed(posts);
    }
    return _sorted(posts);
  }

  Future<List<SocialPost>> createPost({
    required String authorName,
    required String authorEmail,
    required String content,
    String? goalTitle,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw StateError('내용을 입력해주세요.');
    }
    final normalizedGoalTitle = goalTitle?.trim();
    final sanitizedGoalTitle = (normalizedGoalTitle?.isEmpty ?? true) ? null : normalizedGoalTitle;
    final posts = await _storageService.readSocialFeed();
    posts.add(
      SocialPost(
        id: _uuid.v4(),
        authorName: authorName,
        authorEmail: authorEmail,
        content: trimmedContent,
        goalTitle: sanitizedGoalTitle,
        createdAt: DateTime.now(),
      ),
    );
    return _persist(posts);
  }

  Future<List<SocialPost>> addComment({
    required String postId,
    required String authorName,
    required String authorEmail,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw StateError('댓글 내용을 입력해주세요.');
    }
    final posts = await _storageService.readSocialFeed();
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw StateError('게시글을 찾을 수 없습니다.');
    }
    final updatedPost = posts[index];
    updatedPost.comments = [
      ...updatedPost.comments,
      SocialComment(
        id: _uuid.v4(),
        authorName: authorName,
        authorEmail: authorEmail,
        content: trimmedContent,
        createdAt: DateTime.now(),
      ),
    ];
    posts[index] = updatedPost;
    return _persist(posts);
  }

  Future<List<SocialPost>> toggleLike({
    required String postId,
    required String userEmail,
  }) async {
    final posts = await _storageService.readSocialFeed();
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) {
      return posts;
    }
    final post = posts[postIndex];
    if (post.likedByEmails.contains(userEmail)) {
      post.likedByEmails.remove(userEmail);
    } else {
      post.likedByEmails.add(userEmail);
    }
    posts[postIndex] = post;
    return _persist(posts);
  }

  Future<List<SocialPost>> _persist(List<SocialPost> posts) async {
    await _storageService.writeSocialFeed(posts);
    return _sorted(posts);
  }

  List<SocialPost> _sorted(List<SocialPost> posts) {
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  List<SocialPost> _seedPosts() {
    final now = DateTime.now();
    return [
      SocialPost(
        id: _uuid.v4(),
        authorName: '김하린',
        authorEmail: 'harin@example.com',
        goalTitle: '3개월 안에 10km 마라톤 완주하기',
        content: '이번 주에는 8km까지 달렸어요! 다음 주엔 9km 도전 💪',
        createdAt: now.subtract(const Duration(hours: 3)),
        comments: [
          SocialComment(
            id: _uuid.v4(),
            authorName: '박서윤',
            authorEmail: 'seoyun@example.com',
            content: '와 대단해요! 꾸준함이 느껴집니다.',
            createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
          ),
          SocialComment(
            id: _uuid.v4(),
            authorName: '이도윤',
            authorEmail: 'doyun@example.com',
            content: '저도 따라가볼게요! 이번 주는 6km 달렸어요.',
            createdAt: now.subtract(const Duration(hours: 2, minutes: 5)),
          ),
        ],
      ),
      SocialPost(
        id: _uuid.v4(),
        authorName: '이도윤',
        authorEmail: 'doyun@example.com',
        goalTitle: '한 달 동안 독서 5권 읽기',
        content: '3권째 완독했습니다. 추천 도서는 《Atomic Habits》!',
        createdAt: now.subtract(const Duration(hours: 12)),
        comments: [
          SocialComment(
            id: _uuid.v4(),
            authorName: '김하린',
            authorEmail: 'harin@example.com',
            content: '추천 감사합니다! 바로 읽어볼게요.',
            createdAt: now.subtract(const Duration(hours: 10)),
          ),
        ],
      ),
      SocialPost(
        id: _uuid.v4(),
        authorName: '박서윤',
        authorEmail: 'seoyun@example.com',
        goalTitle: '매주 두 번 영어 스피킹 스터디 참여',
        content: '이번 주 스터디에서 발음 피드백을 많이 받아서 도움이 되었어요 😊',
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
    ];
  }
}
