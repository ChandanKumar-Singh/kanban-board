part of '../index.dart';

class TaskDetailDialog extends StatefulWidget {
  final KanbanTask task;
  final Function(KanbanTask) onSave;

  const TaskDetailDialog({super.key, required this.task, required this.onSave});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;
  late TaskPriority _priority;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }
  @override
  void initState() {
    super.initState();
    if (widget.task is DefaultKanbanTask) {
      final t = widget.task as DefaultKanbanTask;
      _titleController = TextEditingController(text: t.title);
      _descriptionController = TextEditingController(text: t.description);
      _assigneeController = TextEditingController(text: t.assignee);
      _priority = t.priority;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _assigneeController = TextEditingController();
      _priority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task is! DefaultKanbanTask) {
      return AlertDialog(
        title: const Text('Custom Task'),
        content: const Text('Default editor only supports DefaultKanbanTask.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _assigneeController,
              decoration: const InputDecoration(labelText: 'Assignee'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _priority = val);
              },
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
            final t = widget.task as DefaultKanbanTask;
            final updatedTask = t.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              assignee: _assigneeController.text,
              priority: _priority,
            );
            widget.onSave(updatedTask);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
