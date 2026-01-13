part of '../index.dart';

// --- Repository ---
class CRMRepository extends KanbanRepository<CRMTask> {
  final Map<String, List<CRMTask>> _data = {
    'new_lead': [
      CRMTask(
        title: 'Abhay Singh',
        serviceType: 'Long Term Care at Home',
        address:
            'Flat No. 23, Apex Building, Sector 7, Panchkula, Haryana, 134107, India',
        timeAgo: '2 min',
        statusMessage: 'New service enquiry from customer..',
        source: 'Website',
        crmTags: ['Today', '0-5 min', 'Website'],
        phone: '1234567890',
      ),
      CRMTask(
        title: 'Naman Tyagi',
        serviceType: 'IV Drips',
        address:
            'Bansal tower, Phase 7, Industrial Area, Sector 23, Sahibzada Ajit Nagar, Punjab, 160055, In...',
        timeAgo: '2 min',
        statusMessage: 'Appointment',
        source: 'CRM',
        crmTags: ['Today', '0-5 min', 'CRM'],
        phone: '0987654321',
      ),
    ],
    'lead': [
      CRMTask(
        title: 'Raja...',
        serviceType: 'General Visit',
        address: 'Sector 15, Chandigarh',
        timeAgo: '10 min',
        statusMessage: 'Follow up required',
        crmTags: ['Today', 'CRM'],
      ),
    ],
  };

  @override
  Future<List<KanbanBoardData<CRMTask>>> getAvailableBoards() async {
    return [KanbanBoardData(id: 'crm_board', name: 'Ezupp CRM')];
  }

  @override
  Future<KanbanBoardData<CRMTask>> getBoard(String boardId) async {
    return KanbanBoardData(
      id: 'crm_board',
      name: 'Ezupp CRM',
      columns: [
        KanbanColumn(
          id: 'new_lead',
          title: 'New Lead',
          colorValue: 0xFF1E293B,
          tasks: _data['new_lead'] ?? [],
        ),
        KanbanColumn(
          id: 'lead',
          title: 'Lead',
          colorValue: 0xFF1E293B,
          tasks: _data['lead'] ?? [],
        ),
      ],
    );
  }

  @override
  Future<CRMTask> createTask(String columnId, CRMTask task) async {
    _data[columnId]?.add(task);
    return task;
  }

  @override
  Future<KanbanColumn<CRMTask>> createColumn(
    String boardId,
    KanbanColumn<CRMTask> column,
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
    final fromCol = _data[fromColumnId];
    if (fromCol == null) return;
    final taskIdx = fromCol.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;
    final task = fromCol.removeAt(taskIdx);
    _data.putIfAbsent(toColumnId, () => []).insert(toIndex, task);
  }

  @override
  Future<void> deleteTask(String columnId, String taskId) async {}

  @override
  Future<void> updateTask(String columnId, CRMTask task) async {}

  @override
  Future<List<CRMTask>> loadMore(String columnId, int currentLength) async =>
      [];
}

// --- Provider ---
final crmRepositoryProvider = Provider<CRMRepository>((ref) => CRMRepository());

final crmBoardProvider =
    StateNotifierProvider<
      KanbanBoardNotifier<CRMTask>,
      KanbanBoardState<CRMTask>
    >((ref) {
      final repository = ref.watch(crmRepositoryProvider);
      return KanbanBoardNotifier<CRMTask>(
        repository,
        onFilter: (tasks, query) {
          if (query.isEmpty) return tasks;
          final q = query.toLowerCase();
          return tasks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(q) ||
                    (t.serviceType?.toLowerCase().contains(q) ?? false) ||
                    (t.address?.toLowerCase().contains(q) ?? false),
              )
              .toList();
        },
      );
    });
