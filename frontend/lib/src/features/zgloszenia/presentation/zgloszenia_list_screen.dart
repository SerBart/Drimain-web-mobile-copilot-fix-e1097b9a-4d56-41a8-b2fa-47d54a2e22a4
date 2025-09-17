import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/zgloszenia_repository.dart';
import '../data/zgloszenie_model.dart';
import '../../../common_widgets/loading_indicator.dart';
import '../../../common_widgets/error_view.dart';
import '../../../app_router.dart';

// Provider for zgloszenia list
final zgloszeniaListProvider = FutureProvider<List<Zgloszenie>>((ref) async {
  final repository = ref.read(zgloszeniaRepositoryProvider);
  return repository.fetchAll();
});

class ZgloszeniaListScreen extends ConsumerWidget {
  const ZgloszeniaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zgloszeniaAsync = ref.watch(zgloszeniaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zgłoszenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('${AppRoutes.zgloszenia}/new'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(zgloszeniaListProvider),
          ),
        ],
      ),
      body: zgloszeniaAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading issues...'),
        error: (error, stack) => ErrorView(
          message: _getErrorMessage(error),
          onRetry: () => ref.refresh(zgloszeniaListProvider),
        ),
        data: (zgloszenia) {
          if (zgloszenia.isEmpty) {
            return EmptyView(
              message: 'No issues found',
              icon: Icons.report_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context.go('${AppRoutes.zgloszenia}/new'),
                icon: const Icon(Icons.add),
                label: const Text('Create First Issue'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(zgloszeniaListProvider);
              await ref.read(zgloszeniaListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: zgloszenia.length,
              itemBuilder: (context, index) {
                final zgloszenie = zgloszenia[index];
                return ZgloszenieCard(
                  zgloszenie: zgloszenie,
                  onTap: () => context.go('${AppRoutes.zgloszenia}/${zgloszenie.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is UnauthorizedException) {
      return 'Authentication required. Please log in again.';
    } else if (error is ApiException) {
      return error.message;
    } else {
      return 'Failed to load issues. Please check your connection.';
    }
  }
}

class ZgloszenieCard extends StatelessWidget {
  final Zgloszenie zgloszenie;
  final VoidCallback onTap;

  const ZgloszenieCard({
    super.key,
    required this.zgloszenie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      zgloszenie.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                zgloszenie.fullName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                zgloszenie.opis,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(zgloszenie.dataGodzina ?? zgloszenie.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      zgloszenie.typ,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (zgloszenie.hasPhoto) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.photo,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    switch (zgloszenie.status.toUpperCase()) {
      case 'OPEN':
        chipColor = Colors.red;
        break;
      case 'IN_PROGRESS':
        chipColor = Colors.orange;
        break;
      case 'CLOSED':
      case 'RESOLVED':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        zgloszenie.status,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}