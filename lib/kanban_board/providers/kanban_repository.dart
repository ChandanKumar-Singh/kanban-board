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
            title: 'Campaign Ideas',
            colorValue: 0xFF9C27B0,
            tasks: [
              KanbanTask(
                title: 'Q3 Social Blast',
                description: 'Plan posts for Twitter, LinkedIn, and Instagram.',
                dueDate: DateTime.now().add(const Duration(days: 5)),
                priority: TaskPriority.medium,
                tags: ['Social', 'Q3'],
                assignee: 'Sarah',
              ),
              KanbanTask(
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
              KanbanTask(
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
              KanbanTask(
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
            KanbanTask(
              title: 'Optimize Database',
              description: 'Add indexes to user_activity table.',
              dueDate: DateTime.now().add(const Duration(days: 14)),
              priority: TaskPriority.low,
              tags: ['Db', 'Perf'],
            ),
            KanbanTask(
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
            KanbanTask(
              title: 'Auth Integration',
              description: 'Implement OAuth2 flow.',
              dueDate: DateTime.now().add(const Duration(days: 2)),
              priority: TaskPriority.high,
              tags: ['Auth', 'Security'],
              assignee: 'Alice',
            ),
            KanbanTask(
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
            KanbanTask(
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
            KanbanTask(
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
            KanbanTask(
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
