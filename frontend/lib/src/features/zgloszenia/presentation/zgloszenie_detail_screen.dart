import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/zgloszenia_repository.dart';
import '../data/zgloszenie_model.dart';
import '../../../common_widgets/loading_indicator.dart';
import '../../../common_widgets/error_view.dart';
import '../../../core/auth/auth_state.dart';
import '../../../app_router.dart';

// Provider for single zgloszenie
final zgloszenieDetailProvider = FutureProvider.family<Zgloszenie, int>((ref, id) async {
  final repository = ref.read(zgloszeniaRepositoryProvider);
  return repository.fetch(id);
});

class ZgloszenieDetailScreen extends ConsumerWidget {
  final int id;

  const ZgloszenieDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zgloszenieAsync = ref.watch(zgloszenieDetailProvider(id));
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
        actions: [
          zgloszenieAsync.when(
            data: (zgloszenie) => PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    context.go('${AppRoutes.zgloszenia}/$id/edit');
                    break;
                  case 'delete':
                    await _showDeleteDialog(context, ref, zgloszenie);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (authState.isAdmin || authState.username == zgloszenie.autorUsername) ...[
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (authState.isAdmin)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: zgloszenieAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading issue details...'),
        error: (error, stack) => ErrorView(
          message: _getErrorMessage(error),
          onRetry: () => ref.refresh(zgloszenieDetailProvider(id)),
        ),
        data: (zgloszenie) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, zgloszenie),
              const SizedBox(height: 24),
              _buildDetailsCard(context, zgloszenie),
              const SizedBox(height: 16),
              _buildDescriptionCard(context, zgloszenie),
              const SizedBox(height: 16),
              _buildMetadataCard(context, zgloszenie),
              if (zgloszenie.hasPhoto) ...[
                const SizedBox(height: 16),
                _buildAttachmentsCard(context, zgloszenie),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Zgloszenie zgloszenie) {
    return Card(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(context, zgloszenie.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reported by ${zgloszenie.fullName}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Zgloszenie zgloszenie) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Type', zgloszenie.typ),
            _buildDetailRow(context, 'Priority', zgloszenie.priorytet ?? 'Normal'),
            if (zgloszenie.dzialNazwa != null)
              _buildDetailRow(context, 'Department', zgloszenie.dzialNazwa!),
            if (zgloszenie.autorUsername != null)
              _buildDetailRow(context, 'Author', zgloszenie.autorUsername!),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, Zgloszenie zgloszenie) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              zgloszenie.opis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, Zgloszenie zgloszenie) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (zgloszenie.dataGodzina != null)
              _buildDetailRow(context, 'Issue Date', _formatDateTime(zgloszenie.dataGodzina!)),
            if (zgloszenie.createdAt != null)
              _buildDetailRow(context, 'Created', _formatDateTime(zgloszenie.createdAt!)),
            if (zgloszenie.updatedAt != null)
              _buildDetailRow(context, 'Last Updated', _formatDateTime(zgloszenie.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsCard(BuildContext context, Zgloszenie zgloszenie) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo),
                  const SizedBox(width: 8),
                  const Text('Photo attachment available'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement photo viewing
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo viewing - Coming Soon')),
                      );
                    },
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    switch (status.toUpperCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getErrorMessage(Object error) {
    if (error is NotFoundException) {
      return 'Issue not found. It may have been deleted.';
    } else if (error is UnauthorizedException) {
      return 'Authentication required. Please log in again.';
    } else if (error is ApiException) {
      return error.message;
    } else {
      return 'Failed to load issue details. Please check your connection.';
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, Zgloszenie zgloszenie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Issue'),
        content: Text('Are you sure you want to delete "${zgloszenie.displayTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(zgloszeniaRepositoryProvider).delete(zgloszenie.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue deleted successfully')),
          );
          context.go(AppRoutes.zgloszenia);
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete issue: ${_getErrorMessage(error)}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}