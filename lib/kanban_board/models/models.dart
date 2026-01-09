import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum TaskPriority { low, medium, high }

class KanbanTask {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final TaskPriority priority;
  final String? statusIcon;
  final List<String> tags;
  final String? assigneeAvatar;

  KanbanTask({
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

  KanbanTask copyWith({
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    String? statusIcon,
    List<String>? tags,
    String? assigneeAvatar,
  }) {
    return KanbanTask(
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

class KanbanColumn {
  final String id;
  final String title;
  final List<KanbanTask> tasks;
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

  KanbanColumn copyWith({
    String? title,
    List<KanbanTask>? tasks,
    int? colorValue,
    bool? isLoading,
    bool? hasMore,
  }) {
    return KanbanColumn(
      id: id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
      colorValue: colorValue ?? this.colorValue,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class KanbanConfig {
  final double cardElevation;
  final double columnWidth;
  final EdgeInsets cardMargin;
  final BorderRadius borderRadius;
  final TextStyle? titleStyle;
  final Function(KanbanTask, String, String)? onTaskMoved;

  const KanbanConfig({
    this.cardElevation = 2,
    this.columnWidth = 300,
    this.cardMargin = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.titleStyle,
    this.onTaskMoved,
  });
}
