import 'package:flutter/material.dart';

class DefaultTextButton extends StatelessWidget {

  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const DefaultTextButton({
    Key? key,
    required this.onPressed,
    this.padding,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
      ),
      child: child,
    );
  }
}
