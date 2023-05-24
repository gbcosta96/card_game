import 'package:cloud_firestore/cloud_firestore.dart';

enum Games {
  fodinha,
  truco
}

class RoomModel {
  int currentPlayer;
  int dealerPlayer;
  int cards;
  Games game;
  String referenceId;
  
  RoomModel({
    this.currentPlayer = 0,
    this.dealerPlayer = 0,
    this.cards = 0,
    this.game = Games.fodinha,
    required this.referenceId
  });

  factory RoomModel.fromSnapshot(DocumentSnapshot roomSnapshot) {
    Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
    final newRoom = RoomModel(
      currentPlayer: roomData['current_player'],
      dealerPlayer: roomData['dealer_player'],
      cards: roomData['cards'],
      game: Games.values[roomData['game']],
      referenceId: roomSnapshot.reference.id,
    );
    return newRoom;
  }

  toJson() {
    return <String, dynamic> {
      'current_player': currentPlayer,
      'dealer_player': dealerPlayer,
      'cards': cards,
      'game' : game.index,
    };
  }
}
