import 'package:card_game/model/card_model.dart';

class DeckModel {
  List<CardModel> cards = [];

  DeckModel();

  void newDeck() {
    cards = [];
    cards.add(CardModel(value: 0, number: "4", suit: Suits.swords));
    cards.add(CardModel(value: 0, number: "4", suit: Suits.cups));
    cards.add(CardModel(value: 0, number: "4", suit: Suits.clubs));
    cards.add(CardModel(value: 0, number: "4", suit: Suits.coins));

    cards.add(CardModel(value: 1, number: "5", suit: Suits.swords));
    cards.add(CardModel(value: 1, number: "5", suit: Suits.cups));
    cards.add(CardModel(value: 1, number: "5", suit: Suits.clubs));
    cards.add(CardModel(value: 1, number: "5", suit: Suits.coins));

    cards.add(CardModel(value: 2, number: "6", suit: Suits.swords));
    cards.add(CardModel(value: 2, number: "6", suit: Suits.cups));
    cards.add(CardModel(value: 2, number: "6", suit: Suits.clubs));
    cards.add(CardModel(value: 2, number: "6", suit: Suits.coins));

    cards.add(CardModel(value: 3, number: "7", suit: Suits.cups));
    cards.add(CardModel(value: 3, number: "7", suit: Suits.clubs));

    cards.add(CardModel(value: 4, number: "10", suit: Suits.swords));
    cards.add(CardModel(value: 4, number: "10", suit: Suits.cups));
    cards.add(CardModel(value: 4, number: "10", suit: Suits.clubs));
    cards.add(CardModel(value: 4, number: "10", suit: Suits.coins));

    cards.add(CardModel(value: 5, number: "11", suit: Suits.swords));
    cards.add(CardModel(value: 5, number: "11", suit: Suits.cups));
    cards.add(CardModel(value: 5, number: "11", suit: Suits.clubs));
    cards.add(CardModel(value: 5, number: "11", suit: Suits.coins));

    cards.add(CardModel(value: 6, number: "12", suit: Suits.swords));
    cards.add(CardModel(value: 6, number: "12", suit: Suits.cups));
    cards.add(CardModel(value: 6, number: "12", suit: Suits.clubs));
    cards.add(CardModel(value: 6, number: "12", suit: Suits.coins));

    cards.add(CardModel(value: 7, number: "1", suit: Suits.cups));

    cards.add(CardModel(value: 7, number: "1", suit: Suits.coins));

    cards.add(CardModel(value: 8, number: "2", suit: Suits.swords));
    cards.add(CardModel(value: 8, number: "2", suit: Suits.cups));
    cards.add(CardModel(value: 8, number: "2", suit: Suits.clubs));
    cards.add(CardModel(value: 8, number: "2", suit: Suits.coins));

    cards.add(CardModel(value: 9, number: "3", suit: Suits.swords));
    cards.add(CardModel(value: 9, number: "3", suit: Suits.cups));
    cards.add(CardModel(value: 9, number: "3", suit: Suits.clubs));
    cards.add(CardModel(value: 9, number: "3", suit: Suits.coins));

    cards.add(CardModel(value: 10, number: "7", suit: Suits.coins));

    cards.add(CardModel(value: 11, number: "7", suit: Suits.swords));

    cards.add(CardModel(value: 12, number: "1", suit: Suits.clubs));

    cards.add(CardModel(value: 13, number: "1", suit: Suits.swords));

    cards.shuffle();
  }

  List<CardModel> drawCards(int quantity, String playerName) {
    List<CardModel> list = cards.take(quantity).toList();
    cards.removeRange(0, quantity);
    for (var element in list) {
      element.playerName = playerName;
    }
    return list;
  }


}