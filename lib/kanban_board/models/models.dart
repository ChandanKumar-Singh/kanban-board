part of '../index.dart';

const _uuid = Uuid();

enum TaskPriority { low, medium, high }

class KanbanTask {
  final String id;
  KanbanTask({required this.id});
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
typedef KanbanLoadMoreBuilder<T extends KanbanTask> =
    Widget Function(
      BuildContext context,
      KanbanColumn<T> column,
      KanbanBoardState<T> state,
    );

class KanbanColumnProps<T extends KanbanTask> {
  final double width;
  final KanbanColumnHeaderBuilder<T>? headerBuilder;
  final KanbanLoadMoreBuilder<T>? loadMoreBuilder;
  final double autoLoadThreshold;
  final Decoration? decoration;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextStyle? titleStyle;

  const KanbanColumnProps({
    this.width = 300,
    this.headerBuilder,
    this.loadMoreBuilder,
    this.autoLoadThreshold = 100,
    this.decoration,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.titleStyle,
  });
}

class KanbanCardProps<T extends KanbanTask> {
  final KanbanCardBuilder<T>? builder;
  final double elevation;
  final EdgeInsets margin;
  final BorderRadius borderRadius;

  const KanbanCardProps({
    this.builder,
    this.elevation = 2,
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });
}

class KanbanConfig<T extends KanbanTask> {
  final KanbanColumnProps<T> columnProps;
  final KanbanCardProps<T> cardProps;

  // Global hooks & callbacks
  final KanbanFilterCallback<T>? onFilter;
  final Function(T, String, String)? onTaskMoved;
  final Function(T)? onTaskTap;
  final Function(String, T)? onTaskCreated;
  final Function(String, String)? onTaskDeleted;
  final Function(KanbanColumn<T>)? onColumnCreated;
  final Function(String)? onColumnDeleted;

  const KanbanConfig({
    this.columnProps = const KanbanColumnProps(),
    this.cardProps = const KanbanCardProps(),
    this.onFilter,
    this.onTaskMoved,
    this.onTaskTap,
    this.onTaskCreated,
    this.onTaskDeleted,
    this.onColumnCreated,
    this.onColumnDeleted,
  });
}
