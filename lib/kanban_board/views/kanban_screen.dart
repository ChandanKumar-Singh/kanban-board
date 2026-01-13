part of '../index.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: KanbanBoardView(config: KanbanConfig()));
  }
}
