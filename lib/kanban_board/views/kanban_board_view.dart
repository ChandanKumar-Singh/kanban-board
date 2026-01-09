import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kanban_provider.dart';
import '../models/models.dart';
import '../widgets/kanban_column_widget.dart';
import '../widgets/task_detail_sheet.dart';

class KanbanBoardView extends ConsumerStatefulWidget {
  final KanbanConfig config;

  const KanbanBoardView({super.key, this.config = const KanbanConfig()});

  @override
  ConsumerState<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends ConsumerState<KanbanBoardView> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _currentPointerX = 0;

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
      final screenWidth = MediaQuery.of(context).size.width;
      const threshold = 80.0;
      const scrollSpeed = 8.0;

      if (_currentPointerX < threshold) {
        // Scroll left
        final newOffset = _scrollController.offset - scrollSpeed;
        _scrollController.jumpTo(
          newOffset.clamp(0, _scrollController.position.maxScrollExtent),
        );
      } else if (_currentPointerX > screenWidth - threshold) {
        // Scroll right
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
    final boardState = ref.watch(kanbanBoardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            if (boardState.availableBoards.isNotEmpty)
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: boardState.currentBoardId,
                  items: boardState.availableBoards.map((board) {
                    return DropdownMenuItem<String>(
                      value: board.id,
                      child: Text(
                        board.name,
                        style: const TextStyle(
                          color: Color(0xFF2D3142),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(kanbanBoardProvider.notifier).switchBoard(val);
                    }
                  },
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9094A6),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF9094A6),
                      size: 16,
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: 13,
                  ),
                  onChanged: (val) => ref
                      .read(kanbanBoardProvider.notifier)
                      .updateSearchQuery(val),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF4F5D75),
            ),
            onPressed: () {
              _showAddColumnDialog(context, ref);
            },
            tooltip: 'Add Column',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9FAFC), Color(0xFFE8F1FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: boardState.isBoardSwitching || boardState.isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : Listener(
                    onPointerMove: (event) {
                      if (boardState.isDragging) {
                        _currentPointerX = event.position.dx;
                        if (_scrollTimer == null) _startAutoScroll();
                      } else {
                        _stopAutoScroll();
                      }
                    },
                    onPointerUp: (_) => _stopAutoScroll(),
                    onPointerCancel: (_) => _stopAutoScroll(),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...boardState.columns.map((column) {
                            return KanbanColumnWidget(
                              key: ValueKey(column.id),
                              column: column,
                              config: widget.config,
                            );
                          }),
                          const SizedBox(width: 300),
                        ],
                      ),
                    ),
                  ),
          ),

          // Responsive Sidebar for Desktop
          if (boardState.selectedTask != null &&
              MediaQuery.of(context).size.width > 900)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 400,
              child: Material(
                elevation: 16,
                shadowColor: Colors.black26,
                child: TaskDetailSheet(
                  task: boardState.selectedTask!,
                  columnId: boardState.selectedTaskColumnId!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddColumnDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    int selectedColor = 0xFF9E9E9E; // Default grey

    final List<int> presetColors = [
      0xFF9E9E9E, // Grey
      0xFFF44336, // Red
      0xFFE91E63, // Pink
      0xFF9C27B0, // Purple
      0xFF673AB7, // Deep Purple
      0xFF3F51B5, // Indigo
      0xFF2196F3, // Blue
      0xFF03A9F4, // Light Blue
      0xFF00BCD4, // Cyan
      0xFF009688, // Teal
      0xFF4CAF50, // Green
      0xFF8BC34A, // Light Green
      0xFFFFEB3B, // Yellow
      0xFFFFC107, // Amber
      0xFFFF9800, // Orange
      0xFFFF5722, // Deep Orange
      0xFF795548, // Brown
      0xFF607D8B, // Blue Grey
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Column Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Color Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : Border.all(color: Colors.grey.withOpacity(0.3)),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(kanbanBoardProvider.notifier)
                      .addColumn(controller.text, selectedColor);
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
}
