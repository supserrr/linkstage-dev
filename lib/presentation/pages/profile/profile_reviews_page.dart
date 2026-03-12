import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../bloc/profile_reviews/profile_reviews_cubit.dart';
import '../../bloc/profile_reviews/profile_reviews_state.dart';

/// Dedicated screen showing all reviews for the creative's profile.
/// Supports reply, flag, and like.
class ProfileReviewsPage extends StatelessWidget {
  const ProfileReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => ProfileReviewsCubit(
        sl<ReviewRepository>(),
        user.id,
      ),
      child: const _ProfileReviewsView(),
    );
  }
}

class _ProfileReviewsView extends StatelessWidget {
  const _ProfileReviewsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: BlocConsumer<ProfileReviewsCubit, ProfileReviewsState>(
        listenWhen: (a, b) => a.error != b.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.reviews.isEmpty) {
            return Center(
              child: Text(
                'No reviews yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProfileReviewsCubit>().load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                return _ReviewCard(
                  review: state.reviews[index],
                  onReply: () => _showReplyDialog(context, state.reviews[index]),
                  onLike: () =>
                      context.read<ProfileReviewsCubit>().likeReview(
                            state.reviews[index].id,
                          ),
                  onFlag: () =>
                      context.read<ProfileReviewsCubit>().flagReview(
                            state.reviews[index].id,
                          ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static void _showReplyDialog(BuildContext context, ReviewEntity review) {
    final controller = TextEditingController(text: review.reply);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reply to review',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write your reply...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        Navigator.pop(ctx);
                        context
                            .read<ProfileReviewsCubit>()
                            .addReply(review.id, text);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onReply,
    required this.onLike,
    required this.onFlag,
  });

  final ReviewEntity review;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback onFlag;

  @override
  Widget build(BuildContext context) {
    final hasLiked = review.likedBy.contains(sl<AuthRedirectNotifier>().user?.id);
    final hasFlagged =
        review.flaggedBy.contains(sl<AuthRedirectNotifier>().user?.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${review.rating}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (review.createdAt != null)
                  Text(
                    _formatDate(review.createdAt!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment),
            ],
            if (review.reply.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your reply',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(review.reply),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                ),
                TextButton.icon(
                  onPressed: onLike,
                  icon: Icon(
                    hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                    color: hasLiked
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  label: Text('${review.likeCount}'),
                ),
                TextButton.icon(
                  onPressed: onFlag,
                  icon: Icon(
                    hasFlagged ? Icons.flag : Icons.outlined_flag,
                    size: 18,
                    color: hasFlagged
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  label: const Text('Flag'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
