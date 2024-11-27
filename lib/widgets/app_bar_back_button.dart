import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key, required  this.onPressed,});

  final VoidCallback onPressed;



  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back)
    );
}}
