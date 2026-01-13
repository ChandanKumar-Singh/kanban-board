part of '../index.dart';

class KanbanCardSkeleton extends StatelessWidget {
  final KanbanCardProps props;

  const KanbanCardSkeleton({super.key, this.props = const KanbanCardProps()});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 0,
        margin: props.margin,
        shape: RoundedRectangleBorder(borderRadius: props.borderRadius),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(width: 180, height: 10, color: Colors.white),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60, height: 10, color: Colors.white),
                  Container(width: 40, height: 10, color: Colors.white),
                ],
              ),
            ],
          ),
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
      margin: const EdgeInsets.all(8),
      decoration:
          config.columnProps.decoration ??
          BoxDecoration(
            color: config.columnProps.backgroundColor ?? Colors.grey[100],
            borderRadius:
                config.columnProps.borderRadius ??
                config.cardProps.borderRadius,
          ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[200]!,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    (config.columnProps.borderRadius ??
                            config.cardProps.borderRadius)
                        .copyWith(
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero,
                        ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
