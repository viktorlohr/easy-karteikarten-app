import 'package:flutter/material.dart';
import 'grid_selection_screen.dart';
import 'category_overview_screen.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionScreen(
      title: 'Thema wählen',
      backgroundPath: 'assets/images/background_male.jpg',
      items: const [
        {'label': 'Analysis', 'icon': Icons.show_chart},
        {'label': 'Geometrie', 'icon': Icons.square_foot},
        {'label': 'Stochastik', 'icon': Icons.bar_chart},
      ],
      onItemSelected: (label) => CategoryOverviewScreen(category: label),
    );
  }
}
