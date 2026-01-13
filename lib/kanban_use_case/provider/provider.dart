part of '../index.dart';

// 3. Custom Notifier & Provider
class CustomKanbanBoardNotifier extends KanbanBoardNotifier<CustomKanbanTask> {
  CustomKanbanBoardNotifier(super.repository) : super(onFilter: filterTasks);

  static List<CustomKanbanTask> filterTasks(
    List<CustomKanbanTask> tasks,
    String query,
  ) {
    if (query.isEmpty) return tasks;
    final q = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(q) ||
          task.subtitle.toLowerCase().contains(q) ||
          task.labels.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  ) {
    debugPrint('CustomNotifier: Intercepted moveTask for $taskId');
    // Add custom logic here, e.g., analytics or validation
    super.moveTask(taskId, fromColumnId, toColumnId, toIndex);
  }

  @override
  Future<void> addColumn(String title, int colorValue) async {
    debugPrint('CustomNotifier: Adding new column: $title');
    await super.addColumn(title, colorValue);
    debugPrint('CustomNotifier: Column added successfully');
  }
}

final customRepositoryProvider = Provider<KanbanRepository<CustomKanbanTask>>((
  ref,
) {
  return CustomKanbanRepository();
});

final customKanbanBoardProvider =
    StateNotifierProvider<
      CustomKanbanBoardNotifier,
      KanbanBoardState<CustomKanbanTask>
    >((ref) {
      final repository = ref.watch(customRepositoryProvider);
      return CustomKanbanBoardNotifier(repository);
    });

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
          hasMore: true,
        ),
        KanbanColumn(
          id: 'col2',
          title: 'IN PROGRESS',
          colorValue: 0xFF2F80ED,
          tasks: _data['col2']!,
          hasMore: true,
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
    final columnData = _data[fromColumnId];
    if (columnData == null) return;

    final taskIndex = columnData.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = columnData[taskIndex];
    columnData.removeAt(taskIndex);

    if (!_data.containsKey(toColumnId)) {
      _data[toColumnId] = [];
    }

    final targetList = _data[toColumnId]!;
    // Clamp index to valid range
    final actualIndex = toIndex.clamp(0, targetList.length);
    targetList.insert(actualIndex, task);

    debugPrint(
      'Backend: Moved task $taskId from $fromColumnId to $toColumnId at index $actualIndex (requested $toIndex)',
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

  @override
  Future<List<CustomKanbanTask>> getTasks(
    String columnId,
    int currentLength,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      4,
      (index) => CustomKanbanTask(
        title: 'Loaded Task ${currentLength + 1 + index}',
        subtitle: 'Auto-loaded from repository',
        priority: 1,
        labels: ['Async'],
      ),
    );
  }

  @override
  Future<List<CustomKanbanTask>> refreshColumn(String columnId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _data[columnId] ?? [];
  }
}
