import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'kanban_repository.dart';

class KanbanBoardState {
  final List<KanbanColumn> columns;
  final bool isInitialLoading;
  final String searchQuery;
  final bool isDragging;
  final String? draggingTaskId;
  final String? draggingColumnId;
  final String? hoverColumnId;
  final int? hoverIndex;

  // Multi-board support
  final List<KanbanBoardData> availableBoards;
  final String? currentBoardId;
  final bool isBoardSwitching;

  KanbanBoardState({
    this.columns = const [],
    this.isInitialLoading = false,
    this.searchQuery = '',
    this.isDragging = false,
    this.draggingTaskId,
    this.draggingColumnId,
    this.hoverColumnId,
    this.hoverIndex,
    this.availableBoards = const [],
    this.currentBoardId,
    this.isBoardSwitching = false,
  });

  KanbanBoardState copyWith({
    List<KanbanColumn>? columns,
    bool? isInitialLoading,
    String? searchQuery,
    bool? isDragging,
    String? draggingTaskId,
    String? draggingColumnId,
    String? hoverColumnId,
    int? hoverIndex,
    List<KanbanBoardData>? availableBoards,
    String? currentBoardId,
    bool? isBoardSwitching,
    bool resetDragging = false,
    bool resetHover = false,
  }) {
    return KanbanBoardState(
      columns: columns ?? this.columns,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      isDragging: isDragging ?? this.isDragging,
      draggingTaskId: resetDragging
          ? null
          : (draggingTaskId ?? this.draggingTaskId),
      draggingColumnId: resetDragging
          ? null
          : (draggingColumnId ?? this.draggingColumnId),
      hoverColumnId: resetHover ? null : (hoverColumnId ?? this.hoverColumnId),
      hoverIndex: resetHover ? null : (hoverIndex ?? this.hoverIndex),
      availableBoards: availableBoards ?? this.availableBoards,
      currentBoardId: currentBoardId ?? this.currentBoardId,
      isBoardSwitching: isBoardSwitching ?? this.isBoardSwitching,
    );
  }
}

class KanbanBoardNotifier extends StateNotifier<KanbanBoardState> {
  final KanbanRepository _repository;

  KanbanBoardNotifier(this._repository)
    : super(KanbanBoardState(isInitialLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final boards = await _repository.getAvailableBoards();
    state = state.copyWith(availableBoards: boards);

    if (boards.isNotEmpty) {
      await switchBoard(boards.first.id);
    }
  }

  Future<void> switchBoard(String boardId) async {
    state = state.copyWith(isBoardSwitching: true, currentBoardId: boardId);

    final boardData = await _repository.getBoard(boardId);

    state = state.copyWith(
      columns: boardData.columns,
      isInitialLoading: false,
      isBoardSwitching: false,
    );
  }

  void setDragging(bool isDragging, {String? taskId, String? columnId}) {
    if (!isDragging) {
      state = state.copyWith(
        isDragging: false,
        resetDragging: true,
        resetHover: true,
      );
    } else {
      state = state.copyWith(
        isDragging: true,
        draggingTaskId: taskId,
        draggingColumnId: columnId,
      );
    }
  }

  void updateHoverPosition(String? columnId, int? index) {
    if (state.hoverColumnId == columnId && state.hoverIndex == index) return;
    state = state.copyWith(hoverColumnId: columnId, hoverIndex: index);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addTask(String columnId, KanbanTask task) async {
    final newTask = await _repository.createTask(columnId, task);

    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final newColumns = List<KanbanColumn>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(
      tasks: [...column.tasks, newTask],
    );

    state = state.copyWith(columns: newColumns);
  }

  Future<void> addColumn(String title, int colorValue) async {
    if (state.currentBoardId == null) return;

    final newCol = KanbanColumn(title: title, colorValue: colorValue);
    final createdCol = await _repository.createColumn(
      state.currentBoardId!,
      newCol,
    );

    state = state.copyWith(columns: [...state.columns, createdCol]);
  }

  void updateTask(String columnId, KanbanTask updatedTask) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final taskIndex = column.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (taskIndex == -1) return;

    final newTasks = List<KanbanTask>.from(column.tasks);
    newTasks[taskIndex] = updatedTask;

    final newColumns = List<KanbanColumn>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(tasks: newTasks);

    state = state.copyWith(columns: newColumns);
  }

  Future<void> loadMore(String columnId) async {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1 || state.columns[columnIndex].isLoading) return;

    final newColumns = List<KanbanColumn>.from(state.columns);
    newColumns[columnIndex] = newColumns[columnIndex].copyWith(isLoading: true);
    state = state.copyWith(columns: newColumns);

    await Future.delayed(const Duration(seconds: 1));

    final column = state.columns[columnIndex];
    final moreTasks = [
      KanbanTask(
        title: 'More Task ${column.tasks.length + 1}',
        description: 'Dynamically loaded',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
    ];

    final updatedColumns = List<KanbanColumn>.from(state.columns);
    updatedColumns[columnIndex] = column.copyWith(
      tasks: [...column.tasks, ...moreTasks],
      isLoading: false,
      hasMore: column.tasks.length < 10,
    );

    state = state.copyWith(columns: updatedColumns);
  }

  void moveTask(
    String taskId,
    String fromColumnId,
    String toColumnId,
    int toIndex,
  ) {
    if (fromColumnId == toColumnId) {
      _reorderTask(fromColumnId, taskId, toIndex);
      return;
    }

    final fromColumnIndex = state.columns.indexWhere(
      (c) => c.id == fromColumnId,
    );
    final toColumnIndex = state.columns.indexWhere((c) => c.id == toColumnId);

    if (fromColumnIndex == -1 || toColumnIndex == -1) return;

    final fromColumn = state.columns[fromColumnIndex];
    final toColumn = state.columns[toColumnIndex];

    final taskIndex = fromColumn.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = fromColumn.tasks[taskIndex];

    final newFromTasks = List<KanbanTask>.from(fromColumn.tasks)
      ..removeAt(taskIndex);
    final newToTasks = List<KanbanTask>.from(toColumn.tasks)
      ..insert(toIndex, task);

    final newColumns = List<KanbanColumn>.from(state.columns);
    newColumns[fromColumnIndex] = fromColumn.copyWith(tasks: newFromTasks);
    newColumns[toColumnIndex] = toColumn.copyWith(tasks: newToTasks);

    state = state.copyWith(
      columns: newColumns,
      isDragging: false,
      resetDragging: true,
      resetHover: true,
    );

    _repository.moveTask(taskId, fromColumnId, toColumnId, toIndex);
  }

  void _reorderTask(String columnId, String taskId, int toIndex) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final fromIndex = column.tasks.indexWhere((t) => t.id == taskId);
    if (fromIndex == -1) {
      state = state.copyWith(
        isDragging: false,
        resetDragging: true,
        resetHover: true,
      );
      return;
    }

    final newTasks = List<KanbanTask>.from(column.tasks);
    final task = newTasks.removeAt(fromIndex);

    int actualToIndex = toIndex;
    if (actualToIndex > fromIndex) actualToIndex--;
    actualToIndex = actualToIndex.clamp(0, newTasks.length);

    newTasks.insert(actualToIndex, task);

    final newColumns = List<KanbanColumn>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(tasks: newTasks);

    state = state.copyWith(
      columns: newColumns,
      isDragging: false,
      resetDragging: true,
      resetHover: true,
    );

    _repository.moveTask(taskId, columnId, columnId, actualToIndex);
  }
}

final kanbanRepositoryProvider = Provider<KanbanRepository>((ref) {
  return DemoKanbanRepository();
});

final kanbanBoardProvider =
    StateNotifierProvider<KanbanBoardNotifier, KanbanBoardState>((ref) {
      final repository = ref.watch(kanbanRepositoryProvider);
      return KanbanBoardNotifier(repository);
    });
