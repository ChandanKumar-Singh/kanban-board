part of '../index.dart';

abstract class KanbanRepository<T extends KanbanTask> {
  Future<List<KanbanBoardData<T>>> getAvailableBoards();
  Future<KanbanBoardData<T>> getBoard(String boardId);
  Future<T> createTask(String columnId, T task);
  Future<KanbanColumn<T>> createColumn(String boardId, KanbanColumn<T> column);
  Future<void> moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  );
}

class KanbanBoardData<T extends KanbanTask> {
  final String id;
  final String name;
  final List<KanbanColumn<T>> columns;

  KanbanBoardData({
    required this.id,
    required this.name,
    this.columns = const [],
  });
}

class DemoKanbanRepository implements KanbanRepository<DefaultKanbanTask> {
  @override
  Future<List<KanbanBoardData<DefaultKanbanTask>>> getAvailableBoards() async {
    return [
      KanbanBoardData(id: 'dev', name: 'Development'),
      KanbanBoardData(id: 'marketing', name: 'Marketing'),
    ];
  }

  @override
  Future<KanbanBoardData<DefaultKanbanTask>> getBoard(String boardId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (boardId == 'marketing') {
      return KanbanBoardData(
        id: 'marketing',
        name: 'Marketing',
        columns: [
          KanbanColumn(
            title: 'Campaign Ideas',
            colorValue: 0xFF9C27B0,
            tasks: [
              DefaultKanbanTask(
                title: 'Q3 Social Blast',
                description: 'Plan posts for Twitter, LinkedIn, and Instagram.',
                dueDate: DateTime.now().add(const Duration(days: 5)),
                priority: TaskPriority.medium,
                tags: ['Social', 'Q3'],
                assignee: 'Sarah',
              ),
              DefaultKanbanTask(
                title: 'Influencer Outreach',
                description: 'Contact top 50 tech influencers.',
                dueDate: DateTime.now().add(const Duration(days: 10)),
                priority: TaskPriority.high,
                tags: ['Outreach'],
                assignee: 'Mike',
              ),
            ],
          ),
          KanbanColumn(
            title: 'In Progress',
            colorValue: 0xFFFF9800,
            tasks: [
              DefaultKanbanTask(
                title: 'Blog Post: Kanban 101',
                description: 'Drafting the introductory post.',
                dueDate: DateTime.now().add(const Duration(days: 2)),
                priority: TaskPriority.medium,
                assignee: 'Elena',
              ),
            ],
          ),
          KanbanColumn(title: 'Review', colorValue: 0xFF2196F3, tasks: []),
          KanbanColumn(
            title: 'Published',
            colorValue: 0xFF4CAF50,
            tasks: [
              DefaultKanbanTask(
                title: 'Website Relaunch',
                description: 'New landing page is live.',
                dueDate: DateTime.now().subtract(const Duration(days: 1)),
                priority: TaskPriority.high,
                tags: ['Launch', 'Web'],
                statusIcon: '🚀',
              ),
            ],
          ),
        ],
      );
    }

    return KanbanBoardData(
      id: 'dev',
      name: 'Development',
      columns: [
        KanbanColumn(
          title: 'Backlog',
          colorValue: 0xFF607D8B,
          hasMore: true,
          tasks: [
            DefaultKanbanTask(
              title: 'Optimize Database',
              description: 'Add indexes to user_activity table.',
              dueDate: DateTime.now().add(const Duration(days: 14)),
              priority: TaskPriority.low,
              tags: ['Db', 'Perf'],
            ),
            DefaultKanbanTask(
              title: 'Update Flutter SDK',
              description: 'Migrate to version 3.29.',
              dueDate: DateTime.now().add(const Duration(days: 30)),
              tags: ['Infra'],
            ),
          ],
        ),
        KanbanColumn(
          title: 'To Do',
          colorValue: 0xFFF44336,
          tasks: [
            DefaultKanbanTask(
              title: 'Auth Integration',
              description: 'Implement OAuth2 flow.',
              dueDate: DateTime.now().add(const Duration(days: 2)),
              priority: TaskPriority.high,
              tags: ['Auth', 'Security'],
              assignee: 'Alice',
            ),
            DefaultKanbanTask(
              title: 'Unit Tests',
              description: 'Increase coverage to 80%.',
              dueDate: DateTime.now().add(const Duration(days: 1)),
              priority: TaskPriority.medium,
              tags: ['Testing'],
              assignee: 'Bob',
            ),
          ],
        ),
        KanbanColumn(
          title: 'In Progress',
          colorValue: 0xFF2196F3,
          tasks: [
            DefaultKanbanTask(
              title: 'Kanban Drag & Drop',
              description: 'Refining the drag interactions.',
              dueDate: DateTime.now(),
              priority: TaskPriority.high,
              tags: ['UI', 'Core'],
              assignee: 'Charlie',
            ),
          ],
        ),
        KanbanColumn(
          title: 'Code Review',
          colorValue: 0xFFFFC107,
          tasks: [
            DefaultKanbanTask(
              title: 'API Endpoints',
              description: 'Review the new REST endpoints.',
              dueDate: DateTime.now().subtract(const Duration(hours: 4)),
              priority: TaskPriority.high,
              assignee: 'Dave',
            ),
          ],
        ),
        KanbanColumn(
          title: 'Done',
          colorValue: 0xFF4CAF50,
          tasks: [
            DefaultKanbanTask(
              title: 'Project Setup',
              description: 'Initial repo creation.',
              dueDate: DateTime.now().subtract(const Duration(days: 5)),
              priority: TaskPriority.medium,
              tags: ['Setup'],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<DefaultKanbanTask> createTask(
    String columnId,
    DefaultKanbanTask task,
  ) async {
    return task; // Real implementation would hit API
  }

  @override
  Future<KanbanColumn<DefaultKanbanTask>> createColumn(
    String boardId,
    KanbanColumn<DefaultKanbanTask> column,
  ) async {
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
