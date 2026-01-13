library kanban_board;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shimmer/shimmer.dart';

part 'models/models.dart';

part 'views/kanban_board_view.dart';

part 'providers/kanban_provider.dart';
part 'repository/kanban_repository.dart';

part 'widgets/kanban_card_widget.dart';
part 'widgets/kanban_column_widget.dart';
part 'widgets/kanban_skeleton_widgets.dart';
part 'widgets/task_detail_sheet.dart';
part 'widgets/task_detail_dialog.dart';
