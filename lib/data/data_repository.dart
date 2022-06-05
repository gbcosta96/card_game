import 'package:card_game/model/card_model.dart';
import 'package:card_game/model/message_model.dart';
import 'package:card_game/model/player_model.dart';
import 'package:card_game/model/room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepository {
  final CollectionReference collection = 
    FirebaseFirestore.instance.collection('room');
  
  Stream<QuerySnapshot> getRoomsSnap() {
    return collection.snapshots();
  }

  Stream<DocumentSnapshot> getRoomSnap(String id) {
    return collection.doc(id).snapshots();
  }

  Stream<QuerySnapshot> getPlayersSnap(String id) {
    return collection.doc(id).collection('players').snapshots();
  }

  Stream<QuerySnapshot> getCardsSnap(String id) {
    return collection.doc(id).collection('cards').snapshots();
  }

  Stream<QuerySnapshot> getMessagesSnap(String id) {
    return collection.doc(id).collection('messages').snapshots();
  }

  Future<bool> checkRoom(String id) {
    return collection.doc(id).get().then((value) => value.exists);
  }

  Future<List<RoomModel>> getRooms() async {
    List<QueryDocumentSnapshot> roomsSnapshot = await collection.get().then((value) => value.docs);
    return roomsFromSnap(roomsSnapshot);
  }

  List<RoomModel> roomsFromSnap(List<QueryDocumentSnapshot> snap) {
    List<RoomModel> rooms = [];
    for(final room in snap) {
      rooms.add(RoomModel.fromSnapshot(room));
    }
    return rooms;
  }

  Future<RoomModel> getRoom(id) async {
    DocumentSnapshot roomSnapshot = await collection.doc(id).get();
    return RoomModel.fromSnapshot(roomSnapshot);
  }

  Future<List<PlayerModel>> getPlayers(id) async {
    List<QueryDocumentSnapshot> playersSnapshot = 
      await collection.doc(id).collection('players').get()
      .then((value) => value.docs);
    
    return playersFromSnap(playersSnapshot);
  }

  List<PlayerModel> playersFromSnap(List<QueryDocumentSnapshot> snap) {
    final players = <PlayerModel>[];
    for(final player in snap) {
      players.add(PlayerModel.fromJson(player.data() as Map<String, dynamic>, player.reference.id));
    }
    return players;
  }

  Future<List<CardModel>> getCards(id) async {
    List<QueryDocumentSnapshot> cardsSnapshot = 
      await collection.doc(id).collection('cards').get()
      .then((value) => value.docs);
    
    return cardsFromSnap(cardsSnapshot);
  }

  List<CardModel> cardsFromSnap(List<QueryDocumentSnapshot> snap) {
    final cards = <CardModel>[];
    for(final card in snap) {
      cards.add(CardModel.fromJson(card.data() as Map<String, dynamic>, card.reference.id));
    }
    return cards;
  }

  Future<void> addRoom(RoomModel room, PlayerModel host) async {
    await collection.doc(room.referenceId).set(room.toJson());
    await addPlayer(room.referenceId, host);
  }

  Future<void> removeRoom(String roomId) async {
    await collection.doc(roomId).delete();
  }

  Future<void> addPlayer(String roomId, PlayerModel player) async {
    await collection.doc(roomId).collection('players')
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(player.toJson());
  }

  Future<void> removePlayer(String roomId, PlayerModel player) async {
    await collection.doc(roomId).collection('players')
      .doc(player.refId).delete();
  }

  Future<void> addCards(String roomId, List<CardModel> cards) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    int i = 0;
    for(final card in cards) {
      var ref = collection.doc(roomId).collection('cards').doc("${i++}");
      writeBatch.set(ref, card.toJson());
    }
    await writeBatch.commit();
  }

  Future<void> removeCards(String roomId) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    var snapshots = await collection.doc(roomId).collection('cards').get();
    for (var doc in snapshots.docs) {
      writeBatch.delete(doc.reference);
    }
    await writeBatch.commit();
  }

  Future<void> updateRoom(String roomId, RoomModel room) async {
    await collection.doc(roomId).update(room.toJson());
  }

  Future<void> updatePlayer(String roomId, PlayerModel player) async {
    await collection.doc(roomId).collection('players').doc(player.refId).update(player.toJson());
  }

  Future<void> updateCard(String roomId, CardModel card) async {
    await collection.doc(roomId).collection('cards').doc(card.refId).update(card.toJson());
  }


  Future<void> addMessage(String roomId, MessageModel message) async {
    await collection.doc(roomId).collection('messages')
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(message.toJson());
  }

  Future<List<MessageModel>> getMessages(id) async {
    List<QueryDocumentSnapshot> messagesSnapshot = 
      await collection.doc(id).collection('messages').get()
      .then((value) => value.docs);
    
    return messagesFromSnap(messagesSnapshot);
  }

  List<MessageModel> messagesFromSnap(List<QueryDocumentSnapshot> snap) {
    final messages = <MessageModel>[];
    for(final message in snap) {
      messages.add(MessageModel.fromJson(message.data() as Map<String, dynamic>, message.reference.id));
    }
    return messages;
  }


}