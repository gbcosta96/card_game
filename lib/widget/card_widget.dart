import 'package:card_game/model/card_model.dart';
import 'package:card_game/on_hover.dart';
import 'package:card_game/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CardPlace {
  myHand,
  otherHand,
  table,
}

class CardWidget extends StatelessWidget {
  final CardModel cardModel;
  final CardPlace cardPlace;
  final VoidCallback? onTap;
  final bool testa;
  
  const CardWidget({ Key? key, required this.cardModel, required this.cardPlace, this.onTap, this.testa = false}) : super(key: key);


  Widget cardContainer() {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          fit: cardPlace == CardPlace.otherHand ? BoxFit.cover : BoxFit.contain,
          image: AssetImage( ((cardPlace == CardPlace.otherHand && !testa) || 
                              (cardPlace == CardPlace.myHand && testa)) ? 
            'assets/images/back.jpeg' :
            'assets/images/${describeEnum(cardModel.suit)}${cardModel.number}.jpeg'
          ),
        ),
      ),
      width: 90,
      height: 123.75,
      child: Stack(
        children: [
          if (cardModel.win)
          Container(
            width: 90,
            height: 123.75,
            color: AppColors.letterRight.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return cardPlace == CardPlace.myHand ?
      OnHover(builder: (isHovered) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
          },
          child: cardContainer(),
        );
      }) : cardContainer();
    
  }
}