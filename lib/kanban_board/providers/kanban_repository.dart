import '../models/models.dart';

abstract class KanbanRepository {
  Future<List<KanbanBoardData>> getAvailableBoards();
  Future<KanbanBoardData> getBoard(String boardId);
  Future<KanbanTask> createTask(String columnId, KanbanTask task);
  Future<KanbanColumn> createColumn(String boardId, KanbanColumn column);
  Future<void> moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  );
}

class KanbanBoardData {
  final String id;
  final String name;
  final List<KanbanColumn> columns;

  KanbanBoardData({
    required this.id,
    required this.name,
    this.columns = const [],
  });
}

class DemoKanbanRepository implements KanbanRepository {
  @override
  Future<List<KanbanBoardData>> getAvailableBoards() async {
    return [
      KanbanBoardData(id: 'dev', name: 'Development'),
      KanbanBoardData(id: 'marketing', name: 'Marketing'),
    ];
  }

  @override
  Future<KanbanBoardData> getBoard(String boardId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (boardId == 'marketing') {
      return KanbanBoardData(
        id: 'marketing',
        name: 'Marketing',
        columns: [
          KanbanColumn(
            title: 'Campaigns',
            colorValue: 0xFF9C27B0,
            tasks: [
              KanbanTask(
                title: 'Social Media Blast',
                description: 'Post to all platforms',
                dueDate: DateTime.now().add(const Duration(days: 1)),
              ),
            ],
          ),
          KanbanColumn(title: 'Events', colorValue: 0xFFFF5722),
        ],
      );
    }

    return KanbanBoardData(
      id: 'dev',
      name: 'Development',
      columns: [
        KanbanColumn(
          title: 'To Do',
          colorValue: 0xFFF44336,
          hasMore: true,
          tasks: [
            KanbanTask(
              title: 'Initial Research',
              description: 'Research Kanban architectures',
              dueDate: DateTime.now().add(const Duration(days: 2)),
              tags: ['Research', 'Planning'],
              assignee: 'Alice',
            ),
            KanbanTask(
              title: 'Define Models',
              description: 'Create Task and Column models',
              dueDate: DateTime.now().add(const Duration(days: 1)),
              priority: TaskPriority.high,
              tags: ['Core'],
              assignee: 'Bob',
            ),
          ],
        ),
        KanbanColumn(
          title: 'In Progress',
          colorValue: 0xFF2196F3,
          tasks: [
            KanbanTask(
              title: 'UI Implementation',
              description: 'Build the board UI',
              dueDate: DateTime.now(),
              priority: TaskPriority.high,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<KanbanTask> createTask(String columnId, KanbanTask task) async {
    return task; // Real implementation would hit API
  }

  @override
  Future<KanbanColumn> createColumn(String boardId, KanbanColumn column) async {
    return column;
  }

  @override
  Future<void> moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  ) async {
    // Sync with remote
  }
}
