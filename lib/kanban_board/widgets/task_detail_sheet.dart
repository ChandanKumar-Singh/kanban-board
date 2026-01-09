import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/kanban_provider.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final KanbanTask task;
  final String columnId;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.columnId,
  });

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _assigneeController;
  late TaskPriority _priority;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _assigneeController = TextEditingController(text: widget.task.assignee);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descController.text,
      assignee: _assigneeController.text,
      priority: _priority,
      dueDate: _dueDate,
    );

    ref
        .read(kanbanBoardProvider.notifier)
        .updateTask(widget.columnId, updatedTask);

    // Close sidebar immediately if persistent, or let parent handle
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Task Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Start by clearing selection in provider
                    ref
                        .read(kanbanBoardProvider.notifier)
                        .selectTask(null, null);
                    // Also pop if it's a dialog/bottom sheet context
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) => _save(),
                  ),
                  const SizedBox(height: 24),

                  // Priority & Date Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPrioritySelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() => _dueDate = date);
                                  _save();
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Add a more detailed description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (_) => _save(),
                  ),

                  const SizedBox(height: 24),

                  // Assignee
                  TextField(
                    controller: _assigneeController,
                    decoration: const InputDecoration(
                      labelText: 'Assignee',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _save(),
                  ),
                ],
              ),
            ),
          ),

          // Footer actions (Delete?)
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              onPressed: () {
                // Implement delete?
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete Task',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskPriority>(
          value: _priority,
          isExpanded: true,
          items: TaskPriority.values.map((p) {
            Color color;
            switch (p) {
              case TaskPriority.high:
                color = Colors.red.shade100;
                break;
              case TaskPriority.medium:
                color = Colors.orange.shade100;
                break;
              case TaskPriority.low:
                color = Colors.green.shade100;
                break;
            }

            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _priority = val);
              _save();
            }
          },
        ),
      ),
    );
  }
}
