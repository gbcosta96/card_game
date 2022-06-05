import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  int currentPlayer;
  int dealerPlayer;
  int cards;
  String referenceId;
  
  RoomModel({this.currentPlayer = 0, this.dealerPlayer = 0, this.cards = 0, required this.referenceId});

  factory RoomModel.fromSnapshot(DocumentSnapshot roomSnapshot) {
    Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
    final newRoom = RoomModel(
      currentPlayer: roomData['current_player'],
      dealerPlayer: roomData['dealer_player'],
      cards: roomData['cards'],
      referenceId: roomSnapshot.reference.id,
    );
    return newRoom;
  }

  toJson() {
    return <String, dynamic> {
      'current_player': currentPlayer,
      'dealer_player': dealerPlayer,
      'cards': cards,
    };
  }
}
