part of '../index.dart';

// 1. Custom Data Model
class CustomKanbanTask extends KanbanTask {
  final String title;
  final String subtitle;
  final int priority;
  final List<String> labels;

  CustomKanbanTask({
    String? id,
    required this.title,
    this.subtitle = '',
    this.priority = 1,
    this.labels = const [],
  }) : super(id: id ?? const Uuid().v4());

  CustomKanbanTask copyWith({
    String? title,
    String? subtitle,
    int? priority,
    List<String>? labels,
  }) {
    return CustomKanbanTask(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      priority: priority ?? this.priority,
      labels: labels ?? this.labels,
    );
  }
}
