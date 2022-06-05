import 'dart:async';
import 'dart:html';

import 'package:card_game/data/data_repository.dart';
import 'package:card_game/model/card_model.dart';
import 'package:card_game/model/deck_model.dart';
import 'package:card_game/model/message_model.dart';
import 'package:card_game/model/player_model.dart';
import 'package:card_game/model/room_model.dart';
import 'package:card_game/utils/app_colors.dart';
import 'package:card_game/widget/app_icon.dart';
import 'package:card_game/widget/app_text.dart';
import 'package:card_game/widget/button.dart';
import 'package:card_game/widget/card_widget.dart';
import 'package:card_game/widget/message_widget.dart';
import 'package:card_game/widget/number_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String roomId;
  final String playerName;
  const HomePage({
    Key? key,
    required this.roomId,
    required this.playerName,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.white];

class _HomePageState extends State<HomePage> {
  final DataRepository repository = DataRepository();

  DeckModel deck = DeckModel();

  RoomModel? room;
  List<PlayerModel> players = [];
  List<CardModel> cards = [];
  List<MessageModel> messages = [];

  late StreamSubscription<DocumentSnapshot> subsRoom;
  late StreamSubscription<QuerySnapshot> subsPlayer;
  late StreamSubscription<QuerySnapshot> subsCards;
  late StreamSubscription<QuerySnapshot> subsMessages;

  bool highOp = false;
  late Timer timer;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    asyncInit();
  }
  
  void asyncInit() async {
    room = await repository.getRoom(widget.roomId);
    players = await repository.getPlayers(widget.roomId);
    cards = await repository.getCards(widget.roomId);
    messages = await repository.getMessages(widget.roomId);

    subsRoom = repository.getRoomSnap(widget.roomId).listen((event) { 
      setState(() {
        room = RoomModel.fromSnapshot(event);
      });
    });

    subsPlayer = repository.getPlayersSnap(widget.roomId).listen((event) {
      if(event.docs.length < players.length) {
        players = repository.playersFromSnap(event.docs);
        newRound();
      } else {
        setState(() {
          players = repository.playersFromSnap(event.docs);
        });
        
      }
      
    });

    subsCards = repository.getCardsSnap(widget.roomId).listen((event) {
      setState(() {
        cards = repository.cardsFromSnap(event.docs);
      });
    });

    subsMessages = repository.getMessagesSnap(widget.roomId).listen((event) {
      setState(() {
        messages = repository.messagesFromSnap(event.docs);
      });
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        highOp = !highOp;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void newRound() async {
    await repository.removeCards(widget.roomId);
    room!.cards = room!.cards >= 9 ? 1 : room!.cards + 1;
    room!.dealerPlayer = room!.dealerPlayer >= players.length - 1 ? 0 : room!.dealerPlayer + 1;
    room!.currentPlayer = room!.dealerPlayer;
    await repository.updateRoom(widget.roomId, room!);
    deck.newDeck();
    List<CardModel> newCards = [];
    for(var player in players) {
      player.expectedPoints = -1;
      player.currentPoints = 0;
      await repository.updatePlayer(widget.roomId, player);
      newCards.addAll(deck.drawCards(room!.cards, player.name));
    }
     await repository.addCards(widget.roomId, newCards);
  }

  List<CardModel> sortedCards(int index) {
    List<CardModel> sorted = cards.where((element) =>
        element.playerName == getPlayerBasedOnMe(index).name && element.round != 0).toList();
    sorted.sort((a, b) => a.round.compareTo(b.round));
    return sorted;
  }

  void playCard(CardModel card) async {
    card.round = cards.where((element) => element.playerName == widget.playerName).reduce((value, element) => value.round > element.round ? value : element).round + 1;
    await repository.updateCard(widget.roomId, card);

    List<CardModel> cardsInRound = cards.where((element) => element.round == card.round).toList();
    if(cardsInRound.length == players.length) {
      cardsInRound.sort((a, b) => b.value.compareTo(a.value));
      while(cardsInRound.where((element) => element.value == cardsInRound.first.value).length > 1) {
        cardsInRound.removeWhere((element) => element.value == cardsInRound.first.value);
      }
      if(cardsInRound.isNotEmpty) {
        CardModel winner = cardsInRound.first;
        winner.win = true;
        await repository.updateCard(widget.roomId, winner);
        PlayerModel winPlayer = getPlayer(name: winner.playerName);
        winPlayer.currentPoints += 1;
        await repository.updatePlayer(widget.roomId, winPlayer);
        room!.currentPlayer = getIndexOfPlayer(name: winPlayer.name);
        await repository.updateRoom(widget.roomId, room!);
      }
      else {
        changePlayer();
      }
      

      if(card.round == room!.cards) {
        for(var player in players) {
          player.fails += (player.currentPoints - player.expectedPoints).abs();
          await repository.updatePlayer(widget.roomId, player);
        }
      }
    }
    else {
      changePlayer();
    }
  }

  Future<void> changePlayer() async {
    room!.currentPlayer += 1;
    if(room!.currentPlayer >= players.length) room!.currentPlayer = 0;
    await repository.updateRoom(widget.roomId, room!);
  }

  Color getColorOfPlayer({String? name}) {
    int index = getIndexOfPlayer(name: name);
    if(index == -1) {
      index = 4;
    }
    return colors[index];
  }

  int getIndexOfPlayer({String? name}) {
    return players.indexWhere((element) => element.name == (name ?? widget.playerName));
  }

  PlayerModel getPlayer({String? name}) {
    return players.firstWhere((element) => element.name == (name ?? widget.playerName));
  }

  PlayerModel getPlayerBasedOnMe(int pos) {
    return players[(pos + getIndexOfPlayer()) % players.length];
  }

  Widget widgetCards(List<CardModel> cards, CardPlace place, bool vertical) {
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        vertical ? const SizedBox(width: 133.75) : const SizedBox(height: 133.75),
        for(CardModel card in cards)
        RotatedBox(
          quarterTurns: vertical ? 1 : 0,
          child: CardWidget(
            cardModel: card,
            cardPlace: place,
            testa: room!.cards == 1,
            onTap: () {
              if(place == CardPlace.myHand && room!.currentPlayer == getIndexOfPlayer() && getPlayer().expectedPoints != -1) {
                playCard(card);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget playerUI(int player) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(text: getPlayerBasedOnMe(player).expectedPoints != -1 ? "Faço ${getPlayerBasedOnMe(player).expectedPoints.toString()}" : room!.currentPlayer == getIndexOfPlayer(name: getPlayerBasedOnMe(player).name) ? "Jogando..." : "Aguardando ..." ),
          AppIcon(name: getPlayerBasedOnMe(player).name, points: getPlayerBasedOnMe(player).fails),
        ],
      ),
    );
  }

  Widget board(int player, bool vertical, bool hiddenFirst, bool isMe) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: getColorOfPlayer(name: getPlayerBasedOnMe(player).name).
      withOpacity((room!.currentPlayer == getIndexOfPlayer(name: getPlayerBasedOnMe(player).name) && getPlayerBasedOnMe(player).expectedPoints != -1) ? highOp ? 0.8 : 0.5 : 0.2),
      child: Flex(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            child: Flex(
              direction: vertical ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(!hiddenFirst)
                  widgetCards(sortedCards(player), CardPlace.table, vertical),
                widgetCards(cards.where((element) => (element.playerName == getPlayerBasedOnMe(player).name && element.round == 0)).toList(), isMe ? CardPlace.myHand : CardPlace.otherHand, vertical),
                if(hiddenFirst)
                  widgetCards(sortedCards(player), CardPlace.table, vertical),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    window.onBeforeUnload.listen((event) async{
      if(players.length == 1) {
        await repository.removePlayer(widget.roomId, getPlayer(name: widget.playerName));
        await repository.removeRoom(widget.roomId);
      }
      else {
        await repository.removePlayer(widget.roomId, getPlayer(name: widget.playerName));
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => scrollController.jumpTo(scrollController.position.maxScrollExtent)
    );
    return Scaffold(
      body: Container(
        color: AppColors.backColor,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [    
                    Container(
                      width: 200,
                      height: 50,
                      padding: const EdgeInsets.all(5),
                      child: const Center(
                        child: AppText(
                          text: "Chat",
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(MessageModel msg in messages)
                              MessageWidget(msg: msg, player: widget.playerName, color: getColorOfPlayer(name: msg.playerName)),
                            ],
                          ),
                        ),
                      ),
                    ),  
                    SizedBox(
                      width: 200,
                      child: TextField(
                        autofocus: true,
                        focusNode: focusNode,
                        controller: controller,
                        onSubmitted: (value) async {
                          if(value.trim() != "") {
                            controller.text = "";
                            MessageModel msg = MessageModel(playerName: widget.playerName, message: value);
                            await repository.addMessage(widget.roomId, msg);
                          }
                          focusNode.requestFocus();
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          suffixIcon: InkWell(
                            child: const Icon(Icons.send),
                            onTap: () async {
                              if(controller.text.trim() != "") {
                                MessageModel msg = MessageModel(playerName: widget.playerName, message: controller.text);
                                controller.text = "";
                                await repository.addMessage(widget.roomId, msg);
                              }
                              focusNode.requestFocus();
                            },
                          ),
                          
                        ),
                      ),  
                    ),   
                    if (getIndexOfPlayer() == 0)
                    Button(
                      text:"Nova rodada",
                      width: 170,
                      onTap: () {
                        newRound();
                      },
                    ),
                    if(players.length > 1)
                    NumberGrid(
                      cards: room?.cards ?? 0,
                      prohibited: (getPlayerBasedOnMe(1) == players[room!.dealerPlayer] && room!.cards != 1) ? (room!.cards - (players.fold(0, (int sum, item) => sum + item.expectedPoints) + 1)) : -1,
                      color: getColorOfPlayer().withOpacity((room!.currentPlayer == getIndexOfPlayer() && getPlayer().expectedPoints == -1) ? highOp ? 0.8 : 0.5 : 0.0),
                      onTap: ((p0) async {
                        PlayerModel player = getPlayer();
                        if(player.expectedPoints == -1 && room!.currentPlayer == getIndexOfPlayer()) {
                          player.expectedPoints = p0;
                          await changePlayer();
                          await repository.updatePlayer(widget.roomId, player);
                          
                        }
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(players.length > 3)
                    board(3, true, true, false), // left
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(players.length > 1) ... [
                            board(players.length == 2 ? 1 : 2, false, true, false), // up
                            playerUI(players.length == 2 ? 1 : 2),
                          ],
                          if(players.length > 2) ... [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  players.length > 3 ? playerUI(3) : const SizedBox(),
                                  playerUI(1),
                                ],
                              )
                            ),
                          ] else ... [
                            const Expanded(child: SizedBox(),)
                          ],
                          if(players.isNotEmpty) ... [
                            playerUI(0),
                            board(0, false, false, true), // down
                          ],              
                        ],
                      ),
                    ),
                    if(players.length > 2)
                    board(1, true, false, false), // right
                  ],
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}