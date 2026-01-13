part of '../index.dart';

class CRMScreen extends ConsumerStatefulWidget {
  const CRMScreen({super.key});

  @override
  ConsumerState<CRMScreen> createState() => _CRMScreenState();
}

class _CRMScreenState extends ConsumerState<CRMScreen> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'Today';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (!_isSearchExpanded) _buildTopFilters(context),
          Expanded(
            child: KanbanBoardView<CRMTask>(
              provider: crmBoardProvider,
              config: KanbanConfig<CRMTask>(
                showSearchBar: false,
                showAddColumnButton: false,
                showAppBar: false,
                columnProps: KanbanColumnProps(
                  width: MediaQuery.of(context).size.width * 0.85,
                  borderRadius: BorderRadius.circular(16),
                  backgroundColor: Colors.transparent,
                  cardSpacing: 16.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  headerBuilder: (context, column, count) =>
                      _buildColumnHeader(context, column, count),
                ),
                cardProps: KanbanCardProps(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  backgroundColor: Colors.white,
                  builder: (context, task, isDragging) =>
                      _buildCRMCard(context, task, isDragging),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B85BC),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _isSearchExpanded
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
                ref.read(crmBoardProvider.notifier).updateSearchQuery('');
              },
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: _isSearchExpanded
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search leads...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(crmBoardProvider.notifier)
                              .updateSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(crmBoardProvider.notifier).updateSearchQuery(val);
                setState(() {});
              },
            )
          : Row(
              children: [
                const Text(
                  'ezupp',
                  style: TextStyle(
                    color: Color(0xFF1B85BC),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '| CRM',
                  style: TextStyle(
                    color: Color(0xFF00CBA9),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
      actions: [
        if (!_isSearchExpanded)
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF475569)),
            onPressed: () {
              setState(() => _isSearchExpanded = true);
              _searchFocusNode.requestFocus();
            },
          ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF475569)),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0F2FE),
            child: Icon(Icons.person, size: 20, color: Color(0xFF1B85BC)),
          ),
        ),
      ],
    );
  }

  Widget _buildTopFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Today',
              isSelected: _selectedFilter == 'Today',
              onTap: () {
                setState(() => _selectedFilter = 'Today');
                ref.read(crmBoardProvider.notifier).updateDateFilter('Today');
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Yesterday',
              isSelected: _selectedFilter == 'Yesterday',
              onTap: () {
                setState(() => _selectedFilter = 'Yesterday');
                ref
                    .read(crmBoardProvider.notifier)
                    .updateDateFilter('Yesterday');
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'This Month',
              isSelected: _selectedFilter == 'This Month',
              onTap: () {
                setState(() => _selectedFilter = 'This Month');
                ref
                    .read(crmBoardProvider.notifier)
                    .updateDateFilter('This Month');
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: (() {
                if (_selectedFilter == 'Custom') {
                  final range = ref.read(crmBoardProvider.notifier).customRange;
                  if (range != null) {
                    final df = DateFormat('dd MMM yyyy');
                    return '${df.format(range.start)} - ${df.format(range.end)}';
                  }
                }
                return 'Select Date Range';
              })(),
              isSelected: _selectedFilter == 'Custom',
              onTap: () async {
                final currentRange = ref
                    .read(crmBoardProvider.notifier)
                    .customRange;
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: currentRange,
                );
                if (range != null) {
                  setState(() => _selectedFilter = 'Custom');
                  ref
                      .read(crmBoardProvider.notifier)
                      .updateDateFilter('Custom', range: range);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader(
    BuildContext context,
    KanbanColumn column,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
      child: Row(
        children: [
          Text(
            column.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Text(
            '($count)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCRMCard(BuildContext context, CRMTask task, bool isDragging) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task.timeAgo ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildIconRow(
              Icons.add_circle,
              task.serviceType ?? '',
              const Color(0xFF64748B),
            ),
            const SizedBox(height: 8),
            _buildIconRow(
              Icons.location_on,
              task.address ?? '',
              const Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            if (task.statusMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_note,
                      color: Color(0xFFC2410C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.statusMessage!,
                        style: const TextStyle(
                          color: Color(0xFF9A3412),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFC2410C),
                      size: 18,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: task.crmTags.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCircleIconButton(Icons.block, Colors.red),
                const SizedBox(width: 12),
                _buildCircleIconButton(
                  Icons.chat_bubble_outline,
                  const Color(0xFF1E293B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'CALL',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    final isWhite = label == 'Today' || label == '0-5 min';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : const Color(0xFFF1F5F9),
        border: isWhite ? Border.all(color: const Color(0xFF1E293B)) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isWhite ? const Color(0xFF1E293B) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF1B85BC).withOpacity(0.2))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF1B85BC)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
