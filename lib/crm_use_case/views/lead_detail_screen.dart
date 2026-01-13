part of '../index.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final CRMTask task;
  const LeadDetailScreen({super.key, required this.task});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lead Detail',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildLeadInfoCard(),
                  const SizedBox(height: 16),
                  _buildAppointmentCard(),
                  const SizedBox(height: 16),
                  _buildDoctorCard(),
                  const SizedBox(height: 16),
                  _buildTagsCard(),
                  const SizedBox(height: 16),
                  _buildPaymentCard(),
                  const SizedBox(height: 16),
                  _buildFeedbackCard(),
                  const SizedBox(height: 16),
                  _buildTabSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildActionFab(),
    );
  }

  Widget _buildStepIndicator() {
    final stages = [
      'New Lead',
      'Qualified',
      'Pending Assignment',
      'Searching Partner',
      'Done',
    ];
    const currentStage = 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          final isActive = index <= currentStage;
          final isCurrent = index == currentStage;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (isActive
                                  ? const Color(0xFF00CBA9)
                                  : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00CBA9)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF00CBA9)
                              : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCurrent
                            ? Icons.chat_bubble_rounded
                            : Icons.check_rounded,
                        size: 16,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == stages.length - 1
                            ? Colors.transparent
                            : (isActive && index < currentStage
                                  ? const Color(0xFF00CBA9)
                                  : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stages[index].replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                    color: isCurrent
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLeadInfoCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _buildBadge(
                'CQ/1081',
                const Color(0xFFF1F5F9),
                const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone_rounded, '+91 987745325682'),
          _buildInfoRow(
            Icons.add_circle_outline_rounded,
            widget.task.serviceType ?? 'General Care',
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            widget.task.address ?? 'Not specified',
          ),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          const Text(
            'Note',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Need urgent care at home',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
            ),
            _buildBadge(
              'COMPLETED',
              const Color(0xFFDCFCE7),
              const Color(0xFF166534),
              small: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildIconText(
                      Icons.calendar_today_rounded,
                      '24 Nov at 12:30 PM - 1:00 PM',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    'APPT-0958',
                    const Color(0xFFF1F5F9),
                    const Color(0xFF64748B),
                    small: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildIconText(
                Icons.add_circle_outline_rounded,
                'Long Term Care at Home (30min)',
              ),
              const SizedBox(height: 12),
              _buildIconText(
                Icons.person_outline_rounded,
                'Naman Tyagi (33yr)',
              ),
              const SizedBox(height: 12),
              _buildIconText(Icons.currency_rupee_rounded, '599'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dr. Naman Gupta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone_rounded, '+91 987745325682'),
                  _buildInfoRow(
                    Icons.add_circle_outline_rounded,
                    'Long Term Care at Home',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildSpanRow('Start/ End Date:', '12:30 PM - 12:45 PM'),
                  _buildSpanRow('Distance:', '81 m'),
                  _buildSpanRow('Travel Time:', '12 mins'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag('Payment Completed'),
                  _buildTag('>60min'),
                  _buildTag('CRM'),
                ],
              ),
              const SizedBox(height: 16),
              _buildGhostButton('ADD'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Amount:', '₹4997'),
              _buildSummaryRow('Method:', 'Cash'),
              _buildSummaryRow('Status:', 'COLLECTED', isStatus: true),
              const SizedBox(height: 16),
              _buildGhostButton('RECORD TRANSACTION'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Doctor's Feedback",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Doctor was very professional',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1B85BC),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF1B85BC),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Notes'),
            Tab(text: 'Timelines'),
            Tab(text: 'Attachment'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Comments',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    String text,
    Color bg,
    Color textCol, {
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(small ? 12 : 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }

  Widget _buildSpanRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isStatus
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildGhostButton(String label) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: Color(0xFF0F172A),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildActionFab() {
    return Container(
      width: 48,
      height: 48,
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
    );
  }
}
