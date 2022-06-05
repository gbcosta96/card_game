

enum Suits {
  swords,
  coins,
  clubs,
  cups,
}

class CardModel {
  int value;
  String number;
  Suits suit;
  int round;
  bool win;
  String? playerName;
  String? refId;
  
  
  CardModel({
    required this.value,
    required this.number,
    required this.suit,
    this.win = false,
    this.round = 0,
    this.playerName,
    this.refId,
  });

  factory CardModel.fromJson(Map<String, dynamic> json, String refId) {
     return CardModel(
      value: json['value'],
      number: json['number'],
      suit: Suits.values[json['suit']],
      round: json['round'],
      playerName: json['player_name'],
      win: json['win'],
      refId: refId
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'value': value,
      'number': number,
      'suit': suit.index,
      'round': round,
      'player_name': playerName,
      'win': win,
    };
  }

}