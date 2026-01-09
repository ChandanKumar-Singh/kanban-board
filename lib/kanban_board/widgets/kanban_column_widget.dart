import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/kanban_provider.dart';
import 'kanban_card_widget.dart';
import 'skeleton_widgets.dart';
import 'task_detail_dialog.dart';

class KanbanColumnWidget extends ConsumerStatefulWidget {
  final KanbanColumn column;
  final KanbanConfig config;

  const KanbanColumnWidget({
    Key? key,
    required this.column,
    this.config = const KanbanConfig(),
  }) : super(key: key);

  @override
  ConsumerState<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends ConsumerState<KanbanColumnWidget> {
  bool _isHighlighted = false;
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _currentPointerY = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      // We need the render box to know the height of this specific column widget
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final height = renderBox.size.height;
      const threshold = 60.0;
      const scrollSpeed = 8.0;

      // Note: _currentPointerY is in local coordinates of this column
      if (_currentPointerY < threshold) {
        // Scroll Up
        final newOffset = _scrollController.offset - scrollSpeed;
        _scrollController.jumpTo(
          newOffset.clamp(0, _scrollController.position.maxScrollExtent),
        );
      } else if (_currentPointerY > height - threshold) {
        // Scroll Down
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

  @override
  Widget build(BuildContext context) {
    final ref = super.ref; // Access ref from ConsumerState
    final boardState = ref.watch(kanbanBoardProvider);
    final searchQuery = boardState.searchQuery.toLowerCase();
    final isCurrentColumnHovered = boardState.hoverColumnId == widget.column.id;

    final filteredTasks = widget.column.tasks.where((task) {
      if (searchQuery.isEmpty) return true;
      return task.title.toLowerCase().contains(searchQuery) ||
          task.description.toLowerCase().contains(searchQuery) ||
          task.assignee.toLowerCase().contains(searchQuery) ||
          task.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();

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
          _buildHeader(context, filteredTasks.length, ref),
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
                onWillAccept: (data) {
                  setState(() => _isHighlighted = true);
                  return true;
                },
                onLeave: (data) {
                  setState(() => _isHighlighted = false);
                  ref
                      .read(kanbanBoardProvider.notifier)
                      .updateHoverPosition(null, null);
                },
                onMove: (details) {
                  // If the list is empty, index is 0
                  if (filteredTasks.isEmpty) {
                    ref
                        .read(kanbanBoardProvider.notifier)
                        .updateHoverPosition(widget.column.id, 0);
                  } else {
                    // Default to last index if we're moving over the column container
                    // and not specifically over a task target.
                    // This makes it easier to drop at the end of the list.
                    if (boardState.hoverColumnId != widget.column.id ||
                        boardState.hoverIndex == null) {
                      ref
                          .read(kanbanBoardProvider.notifier)
                          .updateHoverPosition(
                            widget.column.id,
                            filteredTasks.length,
                          );
                    }
                  }
                },
                onAccept: (data) {
                  setState(() => _isHighlighted = false);
                  final taskId = data['taskId'] as String;
                  final fromColumnId = data['columnId'] as String;
      
                  // Read the latest state from provider to get the most accurate hover index
                  final latestState = ref.read(kanbanBoardProvider);
                  final dropIndex =
                      latestState.hoverIndex ?? filteredTasks.length;
      
                  ref
                      .read(kanbanBoardProvider.notifier)
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
                      .read(kanbanBoardProvider.notifier)
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
                          onWillAccept: (data) {
                            ref
                                .read(kanbanBoardProvider.notifier)
                                .updateHoverPosition(
                                  widget.column.id,
                                  filteredTasks.length,
                                );
                            return true;
                          },
                          builder: (context, _, __) =>
                              const SizedBox(height: 100),
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
                          onWillAccept: (data) {
                            ref
                                .read(kanbanBoardProvider.notifier)
                                .updateHoverPosition(
                                  widget.column.id,
                                  filteredTasks.length,
                                );
                            return true;
                          },
                          builder: (context, _, __) => _buildLoadMore(ref),
                        );
                      }
      
                      final task = filteredTasks[taskIndex];
                      return _buildDraggableTask(
                        task,
                        taskIndex,
                        ref,
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

  Widget _buildLoadMore(WidgetRef ref) {
    if (widget.column.isLoading) {
      return const KanbanCardSkeleton();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () =>
            ref.read(kanbanBoardProvider.notifier).loadMore(widget.column.id),
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int displayCount, WidgetRef ref) {
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
              onTap: () => _showAddTaskDialog(context, ref),
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
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
                              if (val != null)
                                setState(() => selectedPriority = val);
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

                  final newTask = KanbanTask(
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
                      .read(kanbanBoardProvider.notifier)
                      .addTask(widget.column.id, newTask);
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
    KanbanTask task,
    int index,
    WidgetRef parentRef,
    bool isCurrentColumnHovered,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) {
        parentRef
            .read(kanbanBoardProvider.notifier)
            .updateHoverPosition(widget.column.id, index);
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        return Consumer(
          builder: (context, watchRef, _) {
            // Watch ONLY the dragging task ID for this specific task
            final draggingTaskId = watchRef.watch(
              kanbanBoardProvider.select((s) => s.draggingTaskId),
            );
            final isThisTaskDragging = draggingTaskId == task.id;

            return LongPressDraggable<Map<String, dynamic>>(
              key: ValueKey('drag_${task.id}'),
              data: {'taskId': task.id, 'columnId': widget.column.id},
              onDragStarted: () {
                HapticFeedback.lightImpact();
                watchRef
                    .read(kanbanBoardProvider.notifier)
                    .setDragging(
                      true,
                      taskId: task.id,
                      columnId: widget.column.id,
                    );
              },
              onDragEnd: (_) => parentRef
                  .read(kanbanBoardProvider.notifier)
                  .setDragging(false),
              onDraggableCanceled: (_, __) => parentRef
                  .read(kanbanBoardProvider.notifier)
                  .setDragging(false),
              onDragCompleted: () => parentRef
                  .read(kanbanBoardProvider.notifier)
                  .setDragging(false),
              feedback: Transform.rotate(
                angle: 0.07,
                child: Transform.scale(
                  scale: 1.05,
                  child: SizedBox(
                    width: widget.config.columnWidth - 20,
                    child: KanbanTaskCard(task: task, isDragging: true),
                  ),
                ),
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: isThisTaskDragging
                  ? const SizedBox.shrink()
                  : KanbanTaskCard(
                      task: task,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => TaskDetailDialog(
                            task: task,
                            onSave: (updatedTask) {
                              watchRef
                                  .read(kanbanBoardProvider.notifier)
                                  .updateTask(widget.column.id, updatedTask);
                            },
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
