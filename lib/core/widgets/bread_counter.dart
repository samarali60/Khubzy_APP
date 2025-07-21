import 'package:flutter/material.dart';

class BreadCounter extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const BreadCounter({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove_circle_outline)),
        Text('$count', style: Theme.of(context).textTheme.titleMedium),
        IconButton(onPressed: onIncrement, icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}
