import 'package:flutter/material.dart';

class ResizableLayout extends StatelessWidget {
  const ResizableLayout({
    super.key,
    required this.small,
    required this.big,
  });

  final Widget small;
  final Widget big;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) =>
            MediaQuery.of(context).size.width <= 600 ? small : big,
      );
}
