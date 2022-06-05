import 'package:card_game/model/message_model.dart';
import 'package:card_game/utils/app_colors.dart';
import 'package:card_game/widget/app_text.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel msg;
  final String player;
  final Color color;
  const MessageWidget({ Key? key, required this.msg, required this.player, required this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: player == msg.playerName ? AppColors.letterRight : AppColors.disableKeyColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          player != msg.playerName ? AppText(text: msg.playerName, size: 16, color: color, bold: true) : const SizedBox(),
          const SizedBox(height: 5),
          AppText(text: msg.message, size: 14),
        ],
      ),
    );
  }
}