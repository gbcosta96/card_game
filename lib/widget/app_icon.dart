import 'package:card_game/utils/app_colors.dart';
import 'package:card_game/widget/app_text.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String name;
  final int points;
  const AppIcon({ Key? key, this.name = " ", this.points = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.letterRight,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          AppText(text: "$name - $points", color: Colors.white,),
        ],
      ),
    );
  }
}