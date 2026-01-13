part of '../index.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Roadmap'),
            Text(
              'Q1 2026 Strategy',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.notifications_none,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(context),
          Expanded(
            child: KanbanBoardView<CustomKanbanTask>(
              provider: customKanbanBoardProvider,
              config: KanbanConfig<CustomKanbanTask>(
                columnProps: KanbanColumnProps(
                  width: 320,
                  borderRadius: BorderRadius.circular(24),
                  backgroundColor: const Color(0xFFF1F5F9).withOpacity(0.5),
                  cardSpacing: 14.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 20,
                  ),
                  headerPadding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                  headerBuilder: (context, column, count) {
                    final color = Color(column.colorValue);
                    return Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              column.title.toUpperCase(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.5,
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                cardProps: KanbanCardProps(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(20),
                  backgroundColor: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  builder: (context, task, isDragging) {
                    final isUrgent = task.priority == 3;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUrgent
                              ? colorScheme.error.withOpacity(0.15)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: isDragging
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: colorScheme.secondary.withOpacity(
                                    0.06,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUrgent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 14,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CRITICAL',
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAvatars(),
                              _buildTags(task.labels),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onFilter: CustomKanbanBoardNotifier.filterTasks,
                onTaskMoved: (task, from, to) {
                  debugPrint('Task ${task.title} moved from $from to $to');
                },
                onTaskTap: (task) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1E293B),
                      content: Text('Focusing on: ${task.title}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(customKanbanBoardProvider);
        final totalTasks = state.totalTaskCount;
        final filteredTasks = state.totalFilteredCount;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.add,
                label: 'Task',
                onTap: () {},
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.filter_list,
                label: 'Filter',
                onTap: () {},
                color: theme.colorScheme.secondary.withOpacity(0.05),
                textColor: theme.colorScheme.onSurface,
              ),
              const Spacer(),
              Text(
                'Showing $filteredTasks of $totalTasks tasks',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: filteredTasks < totalTasks
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatars() {
    return SizedBox(
      width: 60,
      height: 28,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: index * 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFE2E8F0 + (index * 1000)),
                child: Text(
                  '${String.fromCharCode(65 + index)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 6,
      children: tags.take(1).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color? textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor ?? Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
