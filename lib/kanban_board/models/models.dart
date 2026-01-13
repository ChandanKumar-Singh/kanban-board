part of '../index.dart';

const _uuid = Uuid();

enum TaskPriority { low, medium, high }

abstract class KanbanTask {
  String get id;
}

class DefaultKanbanTask implements KanbanTask {
  @override
  final String id;
  final String title;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final TaskPriority priority;
  final String? statusIcon;
  final List<String> tags;
  final String? assigneeAvatar;

  DefaultKanbanTask({
    String? id,
    required this.title,
    this.description = '',
    this.assignee = 'Unassigned',
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.statusIcon,
    this.tags = const [],
    this.assigneeAvatar,
  }) : id = id ?? _uuid.v4();

  DefaultKanbanTask copyWith({
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    String? statusIcon,
    List<String>? tags,
    String? assigneeAvatar,
  }) {
    return DefaultKanbanTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      statusIcon: statusIcon ?? this.statusIcon,
      tags: tags ?? this.tags,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
    );
  }
}

class KanbanColumn<T extends KanbanTask> {
  final String id;
  final String title;
  final List<T> tasks;
  final int colorValue; // ARGB hex value
  final bool isLoading;
  final bool hasMore;

  KanbanColumn({
    String? id,
    required this.title,
    this.tasks = const [],
    this.colorValue = 0xFF9E9E9E, // Default grey
    this.isLoading = false,
    this.hasMore = false,
  }) : id = id ?? _uuid.v4();

  KanbanColumn<T> copyWith({
    String? title,
    List<T>? tasks,
    int? colorValue,
    bool? isLoading,
    bool? hasMore,
  }) {
    return KanbanColumn<T>(
      id: id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
      colorValue: colorValue ?? this.colorValue,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

typedef KanbanFilterCallback<T extends KanbanTask> =
    List<T> Function(List<T> tasks, String query);
typedef KanbanCardBuilder<T extends KanbanTask> =
    Widget Function(BuildContext context, T task, bool isDragging);
typedef KanbanColumnHeaderBuilder<T extends KanbanTask> =
    Widget Function(
      BuildContext context,
      KanbanColumn<T> column,
      int taskCount,
    );

class KanbanConfig<T extends KanbanTask> {
  final double cardElevation;
  final double columnWidth;
  final EdgeInsets cardMargin;
  final BorderRadius borderRadius;
  final TextStyle? titleStyle;
  final Function(T, String, String)? onTaskMoved;

  // New generic builders and callbacks
  final KanbanCardBuilder<T>? cardBuilder;
  final KanbanColumnHeaderBuilder<T>? columnHeaderBuilder;
  final KanbanFilterCallback<T>? onFilter;

  // Interaction hooks
  final Function(T)? onTaskTap;
  final Function(String, T)? onTaskCreated;
  final Function(String, String)? onTaskDeleted;
  final Function(KanbanColumn<T>)? onColumnCreated;
  final Function(String)? onColumnDeleted;

  const KanbanConfig({
    this.cardElevation = 2,
    this.columnWidth = 300,
    this.cardMargin = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.titleStyle,
    this.onTaskMoved,
    this.cardBuilder,
    this.columnHeaderBuilder,
    this.onFilter,
    this.onTaskTap,
    this.onTaskCreated,
    this.onTaskDeleted,
    this.onColumnCreated,
    this.onColumnDeleted,
  });
}
