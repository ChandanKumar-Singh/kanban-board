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
      backgroundColor: const Color(0xFFF8FAFC),
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
                  borderRadius: BorderRadius.circular(20),
                  backgroundColor: Colors.white,
                  builder: (context, task, isDragging) =>
                      _buildCRMCard(context, task, isDragging),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B85BC), Color(0xFF00CBA9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B85BC).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: RawMaterialButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLeadScreen()),
          ),
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: _isSearchExpanded
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
                ref.read(crmBoardProvider.notifier).updateSearchQuery('');
              },
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: _isSearchExpanded
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search leads...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
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
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B85BC), Color(0xFF00CBA9)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        if (!_isSearchExpanded)
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF475569)),
            onPressed: () {
              setState(() => _isSearchExpanded = true);
              _searchFocusNode.requestFocus();
            },
          ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF475569),
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0, left: 4),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(
              Icons.person_rounded,
              size: 22,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Today',
              icon: Icons.today_rounded,
              isSelected: _selectedFilter == 'Today',
              onTap: () {
                setState(() => _selectedFilter = 'Today');
                ref.read(crmBoardProvider.notifier).updateDateFilter('Today');
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Yesterday',
              icon: Icons.history_rounded,
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
              icon: Icons.calendar_month_rounded,
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
                    final df = DateFormat('dd MMM');
                    return '${df.format(range.start)} - ${df.format(range.end)}';
                  }
                }
                return 'Select Range';
              })(),
              icon: Icons.date_range_rounded,
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
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0F172A),
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF0F172A),
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
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
      padding: const EdgeInsets.fromLTRB(4, 20, 12, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Color(column.colorValue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            column.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              onPressed: () =>
                  ref.read(crmBoardProvider.notifier).refreshColumn(column.id),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCRMCard(BuildContext context, CRMTask task, bool isDragging) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.timeAgo ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildIconRow(
                    Icons.layers_outlined,
                    task.serviceType ?? 'General Service',
                    const Color(0xFF475569),
                  ),
                  const SizedBox(height: 10),
                  _buildIconRow(
                    Icons.location_on_outlined,
                    task.address ?? 'No Address Provided',
                    const Color(0xFF475569),
                  ),
                  const SizedBox(height: 18),
                  if (task.statusMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF475569),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.statusMessage!,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.crmTags
                        .map((tag) => _buildTag(tag))
                        .toList(),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _buildCircleIconButton(
                    Icons.block_flipped,
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleIconButton(
                    Icons.chat_bubble_outline_rounded,
                    const Color(0xFF0F172A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF334155)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(14),
                          child: const Center(
                            child: Text(
                              'CALL NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
        Icon(icon, size: 16, color: color.withOpacity(0.4)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    final isPriority =
        label == 'Today' || label == '0-5 min' || label == 'High';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPriority ? const Color(0xFFF1F5F9) : Colors.white,
        border: Border.all(
          color: isPriority ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isPriority ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
    this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF475569),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
