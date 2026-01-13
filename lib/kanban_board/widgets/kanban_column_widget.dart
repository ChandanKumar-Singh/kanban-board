part of '../index.dart';

class KanbanColumnWidget<T extends KanbanTask> extends ConsumerStatefulWidget {
  final KanbanColumn<T> column;
  final KanbanConfig<T> config;
  final StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>>?
  provider;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    this.config = const KanbanConfig(),
    this.provider,
  });

  @override
  ConsumerState<KanbanColumnWidget<T>> createState() =>
      _KanbanColumnWidgetState<T>();
}

class _KanbanColumnWidgetState<T extends KanbanTask>
    extends ConsumerState<KanbanColumnWidget<T>> {
  bool _isHighlighted = false;
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _currentPointerY = 0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            widget.config.autoLoadThreshold) {
      if (widget.column.hasMore && !widget.column.isLoading) {
        final effectiveProvider =
            widget.provider ??
            (kanbanBoardProvider
                as StateNotifierProvider<
                  KanbanBoardNotifier<T>,
                  KanbanBoardState<T>
                >);
        ref.read(effectiveProvider.notifier).loadMore(widget.column.id);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final height = renderBox.size.height;
      const threshold = 60.0;
      const scrollSpeed = 8.0;

      if (_currentPointerY < threshold) {
        final newOffset = _scrollController.offset - scrollSpeed;
        _scrollController.jumpTo(
          newOffset.clamp(0, _scrollController.position.maxScrollExtent),
        );
      } else if (_currentPointerY > height - threshold) {
        final newOffset = _scrollController.offset + scrollSpeed;
        _scrollController.jumpTo(
          newOffset.clamp(0, _scrollController.position.maxScrollExtent),
        );
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  Widget _buildPlaceholder() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F80ED).withOpacity(0.2),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
          );
        },
        child: const Center(
          child: Icon(
            Icons.add_circle_outline,
            color: Color(0xFF2F80ED),
            size: 28,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method that was already corrected or is mostly fine)
    final effectiveProvider =
        widget.provider ??
        (kanbanBoardProvider
            as StateNotifierProvider<
              KanbanBoardNotifier<T>,
              KanbanBoardState<T>
            >);
    final boardState = ref.watch(effectiveProvider);
    final searchQuery = boardState.searchQuery.toLowerCase();
    final isCurrentColumnHovered = boardState.hoverColumnId == widget.column.id;

    final List<T> filteredTasks;
    if (widget.config.onFilter != null) {
      filteredTasks = widget.config.onFilter!(
        widget.column.tasks,
        boardState.searchQuery,
      );
    } else {
      filteredTasks = widget.column.tasks.where((task) {
        if (searchQuery.isEmpty) return true;
        if (task is DefaultKanbanTask) {
          final t = task as DefaultKanbanTask;
          return t.title.toLowerCase().contains(searchQuery) ||
              t.description.toLowerCase().contains(searchQuery) ||
              t.assignee.toLowerCase().contains(searchQuery) ||
              t.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
        }
        // Fallback for custom tasks if no onFilter is provided
        return task.id.toLowerCase().contains(searchQuery);
      }).toList();
    }

    return Container(
      width: widget.config.columnWidth,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isHighlighted
            ? Colors.blue.withOpacity(0.05)
            : Colors.grey[100],
        borderRadius: widget.config.borderRadius,
        border: _isHighlighted
            ? Border.all(color: Colors.blue, width: 1)
            : null,
      ),
      child: Column(
        children: [
          _buildHeader(context, filteredTasks.length, ref, effectiveProvider),
          Expanded(
            child: Listener(
              onPointerMove: (event) {
                // Convert global pointer position to local for this column
                final RenderBox? renderBox =
                    context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPos = renderBox.globalToLocal(event.position);
                  _currentPointerY = localPos.dy;
                }

                if (boardState.isDragging) {
                  if (_scrollTimer == null) _startAutoScroll();
                } else {
                  _stopAutoScroll();
                }
              },
              onPointerUp: (_) => _stopAutoScroll(),
              onPointerCancel: (_) => _stopAutoScroll(),
              child: DragTarget<Map<String, dynamic>>(
                onWillAcceptWithDetails: (data) {
                  setState(() => _isHighlighted = true);
                  return true;
                },
                onLeave: (data) {
                  setState(() => _isHighlighted = false);
                  ref
                      .read(effectiveProvider.notifier)
                      .updateHoverPosition(null, null);
                },
                onMove: (details) {
                  // If the list is empty, index is 0
                  if (filteredTasks.isEmpty) {
                    ref
                        .read(effectiveProvider.notifier)
                        .updateHoverPosition(widget.column.id, 0);
                  } else {
                    // Default to last index if we're moving over the column container
                    // and not specifically over a task target.
                    // This makes it easier to drop at the end of the list.
                    if (boardState.hoverColumnId != widget.column.id ||
                        boardState.hoverIndex == null) {
                      ref
                          .read(effectiveProvider.notifier)
                          .updateHoverPosition(
                            widget.column.id,
                            filteredTasks.length,
                          );
                    }
                  }
                },
                onAcceptWithDetails: (data) {
                  setState(() => _isHighlighted = false);
                  final taskId = data.data['taskId'] as String;
                  final fromColumnId = data.data['columnId'] as String;

                  // Read the latest state from provider to get the most accurate hover index
                  final latestState = ref.read(effectiveProvider);
                  final dropIndex =
                      latestState.hoverIndex ?? filteredTasks.length;

                  ref
                      .read(effectiveProvider.notifier)
                      .moveTask(
                        taskId,
                        fromColumnId,
                        widget.column.id,
                        dropIndex,
                      );
                  widget.config.onTaskMoved?.call(
                    widget.column.tasks.firstWhere((t) => t.id == taskId),
                    fromColumnId,
                    widget.column.id,
                  );
                  ref
                      .read(effectiveProvider.notifier)
                      .updateHoverPosition(null, null);
                },
                builder: (context, candidateData, rejectedData) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        filteredTasks.length +
                        (widget.column.hasMore ? 1 : 0) +
                        (isCurrentColumnHovered ? 1 : 0) +
                        1, // Extra target at bottom
                    itemBuilder: (context, index) {
                      // 1. Extra transparent target at the bottom for easy dropping at end
                      if (index ==
                          filteredTasks.length +
                              (widget.column.hasMore ? 1 : 0) +
                              (isCurrentColumnHovered ? 1 : 0)) {
                        return DragTarget<Map<String, dynamic>>(
                          onWillAcceptWithDetails: (data) {
                            ref
                                .read(effectiveProvider.notifier)
                                .updateHoverPosition(
                                  widget.column.id,
                                  filteredTasks.length,
                                );
                            return true;
                          },
                          builder: (context, _, __) =>
                              const SizedBox(height: 10),
                        );
                      }

                      // Check for placeholder
                      if (isCurrentColumnHovered &&
                          index == boardState.hoverIndex) {
                        return _buildPlaceholder();
                      }

                      // Adjust index for placeholder
                      int taskIndex = index;
                      if (isCurrentColumnHovered &&
                          boardState.hoverIndex != null &&
                          index > boardState.hoverIndex!) {
                        taskIndex--;
                      }

                      if (taskIndex == filteredTasks.length) {
                        return DragTarget<Map<String, dynamic>>(
                          onWillAcceptWithDetails: (data) {
                            ref
                                .read(effectiveProvider.notifier)
                                .updateHoverPosition(
                                  widget.column.id,
                                  filteredTasks.length,
                                );
                            return true;
                          },
                          builder: (context, _, __) =>
                              _buildLoadMore(ref, effectiveProvider),
                        );
                      }

                      final task = filteredTasks[taskIndex];
                      return _buildDraggableTask(
                        task,
                        taskIndex,
                        ref,
                        effectiveProvider,
                        isCurrentColumnHovered,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (keeping _buildPlaceholder as is)

  Widget _buildLoadMore(
    WidgetRef ref,
    StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>> provider,
  ) {
    if (widget.config.loadMoreBuilder != null) {
      return widget.config.loadMoreBuilder!(
        context,
        widget.column,
        ref.watch(provider),
      );
    }

    if (widget.column.isLoading) {
      return KanbanCardSkeleton();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () => ref.read(provider.notifier).loadMore(widget.column.id),
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int displayCount,
    WidgetRef ref,
    StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>> provider,
  ) {
    if (widget.config.columnHeaderBuilder != null) {
      return widget.config.columnHeaderBuilder!(
        context,
        widget.column,
        displayCount,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(widget.column.colorValue),
        borderRadius: widget.config.borderRadius.copyWith(
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.column.title,
              style:
                  widget.config.titleStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$displayCount',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAddTaskDialog(context, ref, provider),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref,
    StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>> provider,
  ) {
    if (T != DefaultKanbanTask) {
      // For custom models, the user should handle task creation or we need a builder.
      // For now, let's just show a simple "not supported" message if not DefaultKanbanTask.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom task creation not yet supported')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final assigneeController = TextEditingController();
    final tagsController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Task to ${widget.column.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<TaskPriority>(
                            value: selectedPriority,
                            isExpanded: true,
                            items: TaskPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedPriority = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              "${selectedDate.day}/${selectedDate.month}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: assigneeController,
                  decoration: const InputDecoration(
                    labelText: 'Assignee',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    prefixIcon: Icon(Icons.label_outline),
                    hintText: 'e.g. Design, Urgent',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final tags = tagsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final newTask = DefaultKanbanTask(
                    title: titleController.text,
                    description: descController.text,
                    dueDate: selectedDate,
                    priority: selectedPriority,
                    assignee: assigneeController.text.isNotEmpty
                        ? assigneeController.text
                        : 'Unassigned',
                    tags: tags,
                  );

                  ref
                      .read(provider.notifier)
                      .addTask(widget.column.id, newTask as T);
                  widget.config.onTaskCreated?.call(
                    widget.column.id,
                    newTask as T,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableTask(
    T task,
    int index,
    WidgetRef parentRef,
    StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>> provider,
    bool isCurrentColumnHovered,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) {
        parentRef
            .read(provider.notifier)
            .updateHoverPosition(widget.column.id, index);
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        return Consumer(
          builder: (context, watchRef, _) {
            // Watch ONLY the dragging task ID for this specific task
            final draggingTaskId = watchRef.watch(
              provider.select((s) => s.draggingTaskId),
            );
            final isThisTaskDragging = draggingTaskId == task.id;

            final dragKey = ValueKey('drag_${task.id}');
            final dragData = {'taskId': task.id, 'columnId': widget.column.id};

            onDragStarted() {
              HapticFeedback.lightImpact();
              watchRef
                  .read(provider.notifier)
                  .setDragging(
                    true,
                    taskId: task.id,
                    columnId: widget.column.id,
                  );
            }

            onDragEnd(details) =>
                parentRef.read(provider.notifier).setDragging(false);

            final feedback = Transform.rotate(
              angle: 0.1,
              child: Transform.scale(
                scale: 1 * 0.9,
                child: SizedBox(
                  width: widget.config.columnWidth - 20,
                  child: widget.config.cardBuilder != null
                      ? widget.config.cardBuilder!(context, task, true)
                      : KanbanTaskCard(task: task, isDragging: true),
                ),
              ),
            );

            final childWhenDragging = const SizedBox.shrink();

            final child = isThisTaskDragging
                ? const SizedBox.shrink()
                : (widget.config.cardBuilder != null
                      ? widget.config.cardBuilder!(context, task, false)
                      : KanbanTaskCard(
                          task: task,
                          onTap: () {
                            if (widget.config.onTaskTap != null) {
                              widget.config.onTaskTap!(task);
                              return;
                            }
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            if (screenWidth > 900) {
                              watchRef
                                  .read(provider.notifier)
                                  .selectTask(task, widget.column.id);
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.85,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: task is DefaultKanbanTask
                                      ? TaskDetailSheet(
                                          task: task as DefaultKanbanTask,
                                          columnId: widget.column.id,
                                        )
                                      : const Center(
                                          child: Text(
                                            "Custom detail sheet needed",
                                          ),
                                        ),
                                ),
                              );
                            }
                          },
                        ));

            if (kIsWeb) {
              return Draggable<Map<String, dynamic>>(
                key: dragKey,
                data: dragData,
                onDragStarted: onDragStarted,
                onDragEnd: onDragEnd,
                onDraggableCanceled: (_, __) => onDragEnd(null),
                onDragCompleted: () => onDragEnd(null),
                feedback: feedback,
                childWhenDragging: childWhenDragging,
                child: child,
              );
            } else {
              return LongPressDraggable<Map<String, dynamic>>(
                key: dragKey,
                data: dragData,
                onDragStarted: onDragStarted,
                onDragEnd: onDragEnd,
                onDraggableCanceled: (_, __) => onDragEnd(null),
                onDragCompleted: () => onDragEnd(null),
                feedback: feedback,
                childWhenDragging: childWhenDragging,
                delay: const Duration(milliseconds: 200),
                child: child,
              );
            }
          },
        );
      },
    );
  }
}
