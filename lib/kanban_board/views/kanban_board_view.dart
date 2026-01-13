part of '../index.dart';

class KanbanBoardView<T extends KanbanTask> extends ConsumerStatefulWidget {
  final KanbanConfig<T> config;
  final StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>>?
  provider;

  const KanbanBoardView({
    super.key,
    this.config = const KanbanConfig(),
    this.provider,
  });

  @override
  ConsumerState<KanbanBoardView<T>> createState() => _KanbanBoardViewState<T>();
}

class _KanbanBoardViewState<T extends KanbanTask>
    extends ConsumerState<KanbanBoardView<T>> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _currentPointerX = 0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

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
    // Fallback to default provider if none provided
    final effectiveProvider =
        widget.provider ??
        (kanbanBoardProvider
            as StateNotifierProvider<
              KanbanBoardNotifier<T>,
              KanbanBoardState<T>
            >);
    final boardState = ref.watch(effectiveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: widget.config.showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  if (boardState.availableBoards.length > 1)
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
                            ref
                                .read(effectiveProvider.notifier)
                                .switchBoard(val);
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 16),
                  if (widget.config.showSearchBar)
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
                              .read(effectiveProvider.notifier)
                              .updateSearchQuery(val),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                if (widget.config.showAddColumnButton)
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4F5D75),
                    ),
                    onPressed: () {
                      _showAddColumnDialog(context, ref, effectiveProvider);
                    },
                    tooltip: 'Add Column',
                  ),
              ],
            )
          : null,
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
                            return KanbanColumnWidget<T>(
                              key: ValueKey(column.id),
                              column: column,
                              config: widget.config,
                              provider: effectiveProvider,
                            );
                          }),
                          SizedBox(width: widget.config.columnProps.width),
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
                child: boardState.selectedTask is DefaultKanbanTask
                    ? TaskDetailSheet(
                        task: boardState.selectedTask as DefaultKanbanTask,
                        columnId: boardState.selectedTaskColumnId!,
                      )
                    : const Center(child: Text("Custom detail sheet needed")),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddColumnDialog(
    BuildContext context,
    WidgetRef ref,
    StateNotifierProvider<KanbanBoardNotifier<T>, KanbanBoardState<T>> provider,
  ) {
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
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await ref
                      .read(provider.notifier)
                      .addColumn(controller.text, selectedColor);

                  // Notify config after adding
                  final newState = ref.read(provider);
                  if (newState.columns.isNotEmpty) {
                    widget.config.onColumnCreated?.call(newState.columns.last);
                  }

                  if (context.mounted) Navigator.pop(context);
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
