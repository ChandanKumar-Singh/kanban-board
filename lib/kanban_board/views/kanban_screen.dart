part of '../index.dart';

// 1. Custom Data Model
class CustomKanbanTask implements KanbanTask {
  @override
  final String id;
  final String title;
  final String subtitle;
  final int priority; // 1-3
  final List<String> labels;

  CustomKanbanTask({
    String? id,
    required this.title,
    this.subtitle = '',
    this.priority = 1,
    this.labels = const [],
  }) : id = id ?? const Uuid().v4();

  CustomKanbanTask copyWith({
    String? title,
    String? subtitle,
    int? priority,
    List<String>? labels,
  }) {
    return CustomKanbanTask(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
    );
  }
}

// 2. Custom Repository
class CustomKanbanRepository extends KanbanRepository<CustomKanbanTask> {
  final Map<String, List<CustomKanbanTask>> _data = {
    'col1': [
      CustomKanbanTask(
        title: 'Custom Task 1',
        subtitle: 'Priority 3',
        priority: 3,
        labels: ['Bug', 'Urgent'],
      ),
      CustomKanbanTask(
        title: 'Custom Task 2',
        subtitle: 'Priority 1',
        priority: 1,
        labels: ['Feature'],
      ),
    ],
    'col2': [
      CustomKanbanTask(
        title: 'Custom Task 3',
        subtitle: 'Priority 2',
        priority: 2,
        labels: ['Doc'],
      ),
    ],
    'col3': [],
  };

  @override
  Future<List<KanbanBoardData<CustomKanbanTask>>> getAvailableBoards() async {
    return [KanbanBoardData(id: 'board1', name: 'Custom Enterprise Board')];
  }

  @override
  Future<KanbanBoardData<CustomKanbanTask>> getBoard(String boardId) async {
    return KanbanBoardData(
      id: 'board1',
      name: 'Custom Enterprise Board',
      columns: [
        KanbanColumn(
          id: 'col1',
          title: 'BACKLOG',
          colorValue: 0xFF4F5D75,
          tasks: _data['col1']!,
        ),
        KanbanColumn(
          id: 'col2',
          title: 'IN PROGRESS',
          colorValue: 0xFF2F80ED,
          tasks: _data['col2']!,
        ),
        KanbanColumn(
          id: 'col3',
          title: 'DONE',
          colorValue: 0xFF27AE60,
          tasks: _data['col3']!,
        ),
      ],
    );
  }

  @override
  Future<CustomKanbanTask> createTask(
    String columnId,
    CustomKanbanTask task,
  ) async {
    _data[columnId]?.add(task);
    return task;
  }

  @override
  Future<KanbanColumn<CustomKanbanTask>> createColumn(
    String boardId,
    KanbanColumn<CustomKanbanTask> column,
  ) async {
    _data[column.id] = [];
    return column;
  }

  @override
  Future<void> moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  ) async {
    final task = _data[fromColumnId]!.firstWhere((t) => t.id == taskId);
    _data[fromColumnId]!.remove(task);
    if (!_data.containsKey(toColumnId)) {
      _data[toColumnId] = [];
    }
    _data[toColumnId]!.insert(toIndex, task);
    print(
      'Backend: Moved task $taskId from $fromColumnId to $toColumnId at index $toIndex',
    );
  }

  @override
  Future<void> deleteTask(String columnId, String taskId) async {
    _data[columnId]?.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<void> updateTask(String columnId, CustomKanbanTask task) async {
    final index = _data[columnId]!.indexWhere((t) => t.id == task.id);
    if (index != -1) _data[columnId]![index] = task;
  }
}

// 3. Custom Providers
final customRepositoryProvider = Provider<KanbanRepository<CustomKanbanTask>>((
  ref,
) {
  return CustomKanbanRepository();
});

final customKanbanBoardProvider =
    StateNotifierProvider<
      KanbanBoardNotifier<CustomKanbanTask>,
      KanbanBoardState<CustomKanbanTask>
    >((ref) {
      final repository = ref.watch(customRepositoryProvider);
      return KanbanBoardNotifier<CustomKanbanTask>(repository);
    });

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Kanban Board'),
      ),
      body: KanbanBoardView<CustomKanbanTask>(
        provider: customKanbanBoardProvider,
        config: KanbanConfig<CustomKanbanTask>(
          columnWidth: 280,
          borderRadius: BorderRadius.circular(16),
          onFilter: (tasks, query) {
            return tasks.where((task) {
              if (query.isEmpty) return true;
              return task.title.toLowerCase().contains(query) ||
                  task.subtitle.toLowerCase().contains(query)
                  // ||
                  // task.priority.any((tag) => tag.toLowerCase().contains(query))
                  ||
                  task.labels.any((tag) => tag.toLowerCase().contains(query));
            }).toList();
          },
          // Custom Card Builder
          cardBuilder: (context, task, isDragging) {
            return Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDragging
                      ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                  border: Border.all(
                    color: task.priority == 3
                        ? Colors.red.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (task.priority == 3)
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: task.labels
                          .map(
                            (label) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
          
          // Custom Column Header Builder
          columnHeaderBuilder: (context, column, count) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(column.colorValue).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(column.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    column.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(column.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Color(column.colorValue),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          // Callbacks
          onTaskMoved: (task, from, to) {
            debugPrint('Task ${task.title} moved from $from to $to');
          },
          onTaskTap: (task) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tapped on ${task.title}')));
          },
        ),
      ),
    );
  }
}
