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
        createdAt: DateTime.now(),
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
        createdAt: DateTime.now(),
      ),
      CRMTask(
        title: 'Vikram Mehta',
        serviceType: 'Physiotherapy',
        address: 'H.No 45, Sector 4, Mansa Devi Complex, Panchkula',
        timeAgo: '1 day',
        statusMessage: 'Completed initial assessment',
        crmTags: ['Yesterday', 'Finished'],
        phone: '9876543210',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
        createdAt: DateTime.now(),
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
          hasMore: true,
        ),
        KanbanColumn(
          id: 'lead',
          title: 'Lead',
          colorValue: 0xFF1E293B,
          tasks: _data['lead'] ?? [],
          hasMore: true,
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
  Future<List<CRMTask>> loadMore(String columnId, int currentLength) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return [
      CRMTask(
        title: 'New Lead ${currentLength + 1}',
        serviceType: 'Support',
        address: 'Remote',
        timeAgo: 'Just now',
        statusMessage: 'Auto-generated lead',
        crmTags: ['Today', 'New'],
      ),
    ];
  }
}

// --- Provider ---
// --- Provider ---
final crmRepositoryProvider = Provider<CRMRepository>((ref) => CRMRepository());

class CRMBoardNotifier extends KanbanBoardNotifier<CRMTask> {
  String _dateFilter = 'Today';
  DateTimeRange? _customRange;

  DateTimeRange? get customRange => _customRange;
  String get dateFilter => _dateFilter;

  CRMBoardNotifier(super.repository) {
    onFilter = (tasks, query) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final firstOfMonth = DateTime(now.year, now.month, 1);

      // 1. Filter by Date
      var filtered = tasks.where((t) {
        if (t.createdAt == null) return true;
        final taskDate = DateTime(
          t.createdAt!.year,
          t.createdAt!.month,
          t.createdAt!.day,
        );

        if (_dateFilter == 'Today') {
          return taskDate.isAtSameMomentAs(today);
        } else if (_dateFilter == 'Yesterday') {
          return taskDate.isAtSameMomentAs(yesterday);
        } else if (_dateFilter == 'This Month') {
          return taskDate.isAfter(
                firstOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              taskDate.isBefore(
                firstOfMonth.add(const Duration(days: 31)),
              ); // Precise month check would be better
        } else if (_dateFilter == 'Custom' && _customRange != null) {
          final start = DateTime(
            _customRange!.start.year,
            _customRange!.start.month,
            _customRange!.start.day,
          );
          final end = DateTime(
            _customRange!.end.year,
            _customRange!.end.month,
            _customRange!.end.day,
          );
          return taskDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
              taskDate.isBefore(end.add(const Duration(days: 1)));
        }
        return true;
      }).toList();

      // 2. Filter by Search Query
      if (query.isEmpty) return filtered;
      final q = query.toLowerCase();
      return filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.serviceType?.toLowerCase().contains(q) ?? false) ||
                (t.address?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    };
  }

  void updateDateFilter(String filter, {DateTimeRange? range}) {
    _dateFilter = filter;
    _customRange = range;
    // Trigger a state update to re-run filtering (calculated at state setter in base class)
    state = state.copyWith();
  }
}

final crmBoardProvider =
    StateNotifierProvider<CRMBoardNotifier, KanbanBoardState<CRMTask>>((ref) {
      final repository = ref.watch(crmRepositoryProvider);
      return CRMBoardNotifier(repository);
    });
