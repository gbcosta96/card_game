import 'package:card_game/utils/app_colors.dart';
import 'package:card_game/utils/dimensions.dart';
import 'package:card_game/widget/app_text.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double width;
  
  const Button({ Key? key, required this.onTap, this.width = 150, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        margin: const EdgeInsets.all(Dimensions.buttonPaddingHeight),
        padding: const EdgeInsets.all(Dimensions.buttonPaddingHeight),
        width: width,
        color: AppColors.letterRight,
        child: Center(child:  AppText(text: text)),
      ),
    );
  }
}