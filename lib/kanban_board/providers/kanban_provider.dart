part of '../index.dart';

class KanbanBoardState<T extends KanbanTask> {
  final List<KanbanColumn<T>> columns;
  final bool isInitialLoading;
  final String searchQuery;
  final bool isDragging;
  final String? draggingTaskId;
  final String? draggingColumnId;
  final String? hoverColumnId;
  final int? hoverIndex;

  // Multi-board support
  final List<KanbanBoardData<T>> availableBoards;
  final String? currentBoardId;
  final bool isBoardSwitching;

  final KanbanBoardData<T>? selectedTaskBoard;
  final T? selectedTask;
  final String? selectedTaskColumnId;
  final int totalFilteredCount;

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
    this.selectedTask,
    this.selectedTaskColumnId,
    this.selectedTaskBoard,
    this.totalFilteredCount = 0,
  });

  /// Get all tasks across all columns
  List<T> get allTasks => columns.expand((c) => c.tasks).toList();

  /// Get the total count of tasks
  int get totalTaskCount =>
      columns.fold(0, (sum, col) => sum + col.tasks.length);

  KanbanBoardState<T> copyWith({
    List<KanbanColumn<T>>? columns,
    bool? isInitialLoading,
    String? searchQuery,
    bool? isDragging,
    String? draggingTaskId,
    String? draggingColumnId,
    String? hoverColumnId,
    int? hoverIndex,
    List<KanbanBoardData<T>>? availableBoards,
    String? currentBoardId,
    bool? isBoardSwitching,
    bool resetDragging = false,
    bool resetHover = false,
    T? selectedTask,
    String? selectedTaskColumnId,
    bool resetSelection = false,
    int? totalFilteredCount,
  }) {
    return KanbanBoardState<T>(
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
      selectedTask: resetSelection ? null : (selectedTask ?? this.selectedTask),
      selectedTaskColumnId: resetSelection
          ? null
          : (selectedTaskColumnId ?? this.selectedTaskColumnId),
      totalFilteredCount: totalFilteredCount ?? this.totalFilteredCount,
    );
  }
}

class KanbanBoardNotifier<T extends KanbanTask>
    extends StateNotifier<KanbanBoardState<T>> {
  final KanbanRepository<T> repository;
  KanbanFilterCallback<T>? onFilter;

  KanbanBoardNotifier(this.repository, {this.onFilter})
    : super(KanbanBoardState<T>(isInitialLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final boards = await repository.getAvailableBoards();
    state = state.copyWith(availableBoards: boards);

    if (boards.isNotEmpty) {
      await switchBoard(boards.first.id);
    }
  }

  Future<void> switchBoard(String boardId) async {
    state = state.copyWith(isBoardSwitching: true, currentBoardId: boardId);

    final boardData = await repository.getBoard(boardId);

    state = state.copyWith(
      columns: boardData.columns,
      isInitialLoading: false,
      isBoardSwitching: false,
    );
  }

  void selectTask(T? task, String? columnId) {
    state = state.copyWith(
      selectedTask: task,
      selectedTaskColumnId: columnId,
      resetSelection: task == null,
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

  @override
  set state(KanbanBoardState<T> value) {
    final filteredCount = _calculateFilteredCount(value);
    super.state = value.copyWith(totalFilteredCount: filteredCount);
  }

  int _calculateFilteredCount(KanbanBoardState<T> state) {
    if (onFilter == null) return state.totalTaskCount;
    if (state.searchQuery.isEmpty) return state.totalTaskCount;

    int count = 0;
    for (var col in state.columns) {
      count += onFilter!(col.tasks, state.searchQuery).length;
    }
    return count;
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addTask(String columnId, T task) async {
    final newTask = await repository.createTask(columnId, task);

    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final newColumns = List<KanbanColumn<T>>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(
      tasks: [...column.tasks, newTask],
    );

    state = state.copyWith(columns: newColumns);
  }

  Future<void> addColumn(String title, int colorValue) async {
    if (state.currentBoardId == null) return;

    final newCol = KanbanColumn<T>(title: title, colorValue: colorValue);
    final createdCol = await repository.createColumn(
      state.currentBoardId!,
      newCol,
    );

    state = state.copyWith(columns: [...state.columns, createdCol]);
  }

  void updateTask(String columnId, T updatedTask) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final taskIndex = column.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (taskIndex == -1) return;

    final newTasks = List<T>.from(column.tasks);
    newTasks[taskIndex] = updatedTask;

    final newColumns = List<KanbanColumn<T>>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(tasks: newTasks);

    state = state.copyWith(columns: newColumns);
  }

  Future<void> loadMore(String columnId) async {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1 || state.columns[columnIndex].isLoading) return;

    final column = state.columns[columnIndex];
    if (!column.hasMore) return;

    final newColumns = List<KanbanColumn<T>>.from(state.columns);
    newColumns[columnIndex] = newColumns[columnIndex].copyWith(isLoading: true);
    state = state.copyWith(columns: newColumns);

    try {
      final moreTasks = await repository.loadMore(
        columnId,
        column.tasks.length,
      );

      final updatedColumns = List<KanbanColumn<T>>.from(state.columns);
      // Re-find in case state changed during await
      final idx = updatedColumns.indexWhere((c) => c.id == columnId);
      if (idx != -1) {
        final col = updatedColumns[idx];
        updatedColumns[idx] = col.copyWith(
          tasks: [...col.tasks, ...moreTasks],
          isLoading: false,
          hasMore:
              moreTasks.isNotEmpty &&
              col.tasks.length + moreTasks.length < 50, // Example limit
        );
        state = state.copyWith(columns: updatedColumns);
      }
    } catch (e) {
      final errorColumns = List<KanbanColumn<T>>.from(state.columns);
      final idx = errorColumns.indexWhere((c) => c.id == columnId);
      if (idx != -1) {
        errorColumns[idx] = errorColumns[idx].copyWith(isLoading: false);
        state = state.copyWith(columns: errorColumns);
      }
    }
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

    final newFromTasks = List<T>.from(fromColumn.tasks)..removeAt(taskIndex);
    final newToTasks = List<T>.from(toColumn.tasks)..insert(toIndex, task);

    final newColumns = List<KanbanColumn<T>>.from(state.columns);
    newColumns[fromColumnIndex] = fromColumn.copyWith(tasks: newFromTasks);
    newColumns[toColumnIndex] = toColumn.copyWith(tasks: newToTasks);

    state = state.copyWith(
      columns: newColumns,
      isDragging: false,
      resetDragging: true,
      resetHover: true,
    );

    repository.moveTask(taskId, fromColumnId, toColumnId, toIndex);
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

    final newTasks = List<T>.from(column.tasks);
    final task = newTasks.removeAt(fromIndex);

    int actualToIndex = toIndex;
    if (actualToIndex > fromIndex) actualToIndex--;
    actualToIndex = actualToIndex.clamp(0, newTasks.length);

    newTasks.insert(actualToIndex, task);

    final newColumns = List<KanbanColumn<T>>.from(state.columns);
    newColumns[columnIndex] = column.copyWith(tasks: newTasks);

    state = state.copyWith(
      columns: newColumns,
      isDragging: false,
      resetDragging: true,
      resetHover: true,
    );

    repository.moveTask(taskId, columnId, columnId, actualToIndex);
  }
}

final kanbanRepositoryProvider = Provider<KanbanRepository<DefaultKanbanTask>>((
  ref,
) {
  return DemoKanbanRepository();
});

final kanbanBoardProvider =
    StateNotifierProvider<
      KanbanBoardNotifier<DefaultKanbanTask>,
      KanbanBoardState<DefaultKanbanTask>
    >((ref) {
      final repository = ref.watch(kanbanRepositoryProvider);
      return KanbanBoardNotifier<DefaultKanbanTask>(repository);
    });
