part of '../index.dart';

class KanbanCardSkeleton extends StatelessWidget {
  final KanbanCardProps props;

  const KanbanCardSkeleton({super.key, this.props = const KanbanCardProps()});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: Colors.white,
      child: Container(
        margin: props.margin,
        padding: props.padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: props.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 150,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KanbanColumnSkeleton extends StatelessWidget {
  final KanbanConfig config;

  const KanbanColumnSkeleton({super.key, this.config = const KanbanConfig()});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: config.columnProps.width,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          config.columnProps.decoration ??
          BoxDecoration(
            color:
                config.columnProps.backgroundColor ?? const Color(0xFFF8FAFC),
            borderRadius: config.columnProps.borderRadius,
          ),
      child: Column(
        children: [
          Container(
            padding:
                config.columnProps.headerPadding ?? const EdgeInsets.all(20),
            decoration:
                config.columnProps.headerDecoration ??
                const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding:
                  config.columnProps.padding ??
                  const EdgeInsets.symmetric(vertical: 8),
              itemCount: 5,
              itemBuilder: (context, index) =>
                  KanbanCardSkeleton(props: config.cardProps),
            ),
          ),
        ],
      ),
    );
  }
}
