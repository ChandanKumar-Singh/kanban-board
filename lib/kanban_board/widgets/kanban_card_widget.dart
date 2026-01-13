part of '../index.dart';

class KanbanTaskCard<T extends KanbanTask> extends StatelessWidget {
  final T task;
  final VoidCallback? onTap;
  final bool isDragging;
  final KanbanCardProps<T> props;

  const KanbanTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.isDragging = false,
    this.props = const KanbanCardProps(),
  });

  @override
  Widget build(BuildContext context) {
    if (task is! DefaultKanbanTask) {
      return Material(
        color: Colors.transparent,

        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: props.margin,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: props.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isDragging
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Text('Custom Task: ${task.id}'),
          ),
        ),
      );
    }

    final t = task as DefaultKanbanTask;

    return Container(
      margin: props.margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: props.borderRadius,
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: const Color(0xFF2F80ED).withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF2F80ED).withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: props.borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF2D3142),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      _buildPriorityIndicator(t.priority),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (t.description.isNotEmpty)
                    Text(
                      t.description,
                      style: TextStyle(
                        color: const Color(0xFF9094A6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (t.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: t.tags.map((tag) => _buildTag(tag)).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildAvatar(t.assignee),
                          const SizedBox(width: 8),
                          Text(
                            t.assignee,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4F5D75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatDate(t.dueDate),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9094A6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF2F80ED),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildAvatar(String assignee) {
    final initials = assignee.isNotEmpty ? assignee[0].toUpperCase() : '?';
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.low:
        color = const Color(0xFF27AE60);
        label = 'Low';
        break;
      case TaskPriority.medium:
        color = const Color(0xFFF2994A);
        label = 'Medium';
        break;
      case TaskPriority.high:
        color = const Color(0xFFEB5757);
        label = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
