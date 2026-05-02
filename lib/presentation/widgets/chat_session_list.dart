import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/chat_session.dart';
import '../providers/chat_provider.dart';

/// Chat session list widget
class ChatSessionList extends StatelessWidget {
  const ChatSessionList({
    super.key,
    required this.sessions,
    this.currentSession,
    this.onSessionSelected,
    this.onSessionDeleted,
  });

  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final Function(ChatSession session)? onSessionSelected;
  final Function(ChatSession session)? onSessionDeleted;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new conversation to start chatting',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isSelected = currentSession?.id == session.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.chat,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            title: Text(
              session.title ?? _generateFallbackTitle(session.time),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.summary != null && session.summary!.isNotEmpty)
                  Text(
                    session.summary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(session.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (session.shared) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.share,
                        size: 12,
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    _showRenameDialog(context, session);
                    break;
                  case 'share':
                    _shareSession(context, session);
                    break;
                  case 'delete':
                    _showDeleteDialog(context, session);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(session.shared ? Icons.link_off : Icons.link),
                      const SizedBox(width: 8),
                      Text(session.shared ? 'Unshare' : 'Share'),
                    ],
                  ),
                ),
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
            ),
            onTap: () => onSessionSelected?.call(session),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  /// Generate fallback session title
  String _generateFallbackTitle(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(time.year, time.month, time.day);

    if (sessionDate == today) {
      // Show time for today's conversations
      return 'Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final difference = today.difference(sessionDate).inDays;
      if (difference == 1) {
        // Yesterday's conversations
        return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (difference < 7) {
        // Show weekday for conversations within a week
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final weekday = weekdays[time.weekday - 1];
        return '$weekday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        // Show date for older conversations
        return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  void _showRenameDialog(BuildContext context, ChatSession session) {
    final controller = TextEditingController(text: session.title);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new conversation name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                context.read<ChatProvider>().updateSession(
                      session.id,
                      title: newTitle,
                    );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareSession(BuildContext context, ChatSession session) {
    final chatProvider = context.read<ChatProvider>();
    if (session.shared) {
      chatProvider.unshareCurrentSession(session.id);
    } else {
      chatProvider.shareCurrentSession(session.id).then((_) {
        // After sharing, find the updated session and copy its URL
        final updatedSession = chatProvider.sessions
            .where((s) => s.id == session.id)
            .firstOrNull;
        if (updatedSession != null && updatedSession.shared) {
          // Show share URL in a dialog
          _showShareUrlDialog(context, updatedSession);
        }
      });
    }
  }

  void _showShareUrlDialog(BuildContext context, ChatSession session) {
    final shareUrl = session.path?.root ?? '';
    if (shareUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session shared successfully')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Shared'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share URL:'),
            const SizedBox(height: 8),
            SelectableText(
              shareUrl,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareUrl));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied to clipboard')),
              );
            },
            child: const Text('Copy URL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatSession session) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text(
          'Are you sure you want to delete the conversation "${session.title ?? _generateFallbackTitle(session.time)}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSessionDeleted?.call(session);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
