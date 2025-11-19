import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
        required this.onPressed,
        required this.text,
        this.icon,
        this.iconAlignment = IconAlignment.start, this.backgroundColor = Colors.black});

  final VoidCallback onPressed;
  final String text;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: icon,
      iconAlignment: iconAlignment,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 55),
        backgroundColor: backgroundColor,
      ),
      label: Text(
        // lastSlide ? "Get Started" : "Next",
        text,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
