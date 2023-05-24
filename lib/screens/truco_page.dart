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
import 'package:flutter/material.dart';

class TrucoPage extends StatefulWidget {
  final String roomId;
  final String playerName;
  const TrucoPage({
    Key? key,
    required this.roomId,
    required this.playerName,
  }) : super(key: key);

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.white];

class _TrucoPageState extends State<TrucoPage> {
  final DataRepository repository = DataRepository();

  DeckModel deck = DeckModel();

  RoomModel? room;
  List<PlayerModel> players = [];
  List<CardModel> cards = [];
  List<MessageModel> messages = [];

  bool highOp = false;
  late Timer timer;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _asyncInit();
  }
  
  void _asyncInit() async {
    repository.getRoomSnap(widget.roomId).listen((event) { 
      setState(() {
        room = event;
      });
    });

    repository.getPlayersSnap(widget.roomId).listen((event) {
      if(event.length < players.length) {
        players = event;
        _newRound();
      } else {
        setState(() {
          players = event;
        });
      }
    });

    repository.getCardsSnap(widget.roomId).listen((event) {
      setState(() {
        cards = event;
      });
    });

    repository.getMessagesSnap(widget.roomId).listen((event) {
      setState(() {
        messages = event;
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

  void _newRound() async {
    await repository.removeCards(widget.roomId);
    room!.cards = 3;
    room!.dealerPlayer = room!.dealerPlayer >= players.length - 1 ? 0 : room!.dealerPlayer + 1;
    room!.currentPlayer = room!.dealerPlayer;
    await repository.updateRoom(widget.roomId, room!);
    deck.newDeck();
    List<CardModel> newCards = [];
    for(var player in players) {
      player.currentPoints = 0;
      await repository.updatePlayer(widget.roomId, player);
      newCards.addAll(deck.drawCards(room!.cards, player.name));
    }
     await repository.addCards(widget.roomId, newCards);
  }

  List<CardModel> _sortedRoundCards(int index) {
    List<CardModel> sorted = cards.where((element) =>
        element.playerName == _getPlayerBasedOnMe(index).name && element.round != 0).toList();
    sorted.sort((a, b) => a.round.compareTo(b.round));
    return sorted;
  }

  void _playCard(CardModel card) async {
    card.round = cards.where((element) => element.playerName == widget.playerName).reduce((value, element) => value.round > element.round ? value : element).round + 1;
    await repository.updateCard(widget.roomId, card);

    List<CardModel> cardsInRound = cards.where((element) => element.round == card.round).toList();
    if(cardsInRound.length == players.length) {
      cardsInRound.sort((a, b) => b.value.compareTo(a.value));
      if(cardsInRound.where((element) => element.value == cardsInRound.first.value).length == 1) {
        CardModel winner = cardsInRound.first;
        winner.win = true;
        await repository.updateCard(widget.roomId, winner);
        PlayerModel winPlayer = _getPlayer(name: winner.playerName);
        winPlayer.currentPoints += 1;
        await repository.updatePlayer(widget.roomId, winPlayer);
        room!.currentPlayer = _getIndexOfPlayer(name: winPlayer.name);
        await repository.updateRoom(widget.roomId, room!);
      }
      else {
        _changePlayer();
      }
      

      if(card.round == room!.cards) {
        List<PlayerModel> playersSorted = players;
        playersSorted.sort((a, b) => b.currentPoints.compareTo(a.currentPoints));
        playersSorted.first.points += 1;
        await repository.updatePlayer(widget.roomId, playersSorted.first);
      }
    }
    else {
      _changePlayer();
    }
  }

  Future<void> _changePlayer() async {
    room!.currentPlayer += 1;
    if(room!.currentPlayer >= players.length) room!.currentPlayer = 0;
    await repository.updateRoom(widget.roomId, room!);
  }

  Color _getColorOfPlayer({String? name}) {
    int index = _getIndexOfPlayer(name: name);
    if(index == -1) {
      index = 4;
    }
    return colors[index];
  }

  int _getIndexOfPlayer({String? name}) {
    return players.indexWhere((element) => element.name == (name ?? widget.playerName));
  }

  PlayerModel _getPlayer({String? name}) {
    return players.firstWhere((element) => element.name == (name ?? widget.playerName));
  }

  PlayerModel _getPlayerBasedOnMe(int pos) {
    return players[(pos + _getIndexOfPlayer()) % players.length];
  }

  Widget _widgetCards(List<CardModel> cards, CardPlace place, bool vertical) {
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
              if(place == CardPlace.myHand && room!.currentPlayer == _getIndexOfPlayer()) {
                _playCard(card);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _playerUI(int player) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIcon(name: _getPlayerBasedOnMe(player).name, points: _getPlayerBasedOnMe(player).points),
        ],
      ),
    );
  }

  Widget _board(int player, bool vertical, bool hiddenFirst, bool isMe) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _getColorOfPlayer(name: _getPlayerBasedOnMe(player).name).
      withOpacity((room!.currentPlayer == _getIndexOfPlayer(name: _getPlayerBasedOnMe(player).name)) ? highOp ? 0.8 : 0.5 : 0.2),
      child: Flex(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            child: Flex(
              direction: vertical ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(!hiddenFirst)
                  _widgetCards(_sortedRoundCards(player), CardPlace.table, vertical),
                _widgetCards(cards.where((element) => (element.playerName == _getPlayerBasedOnMe(player).name && element.round == 0)).toList(), isMe ? CardPlace.myHand : CardPlace.otherHand, vertical),
                if(hiddenFirst)
                  _widgetCards(_sortedRoundCards(player), CardPlace.table, vertical),
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
        await repository.removePlayer(widget.roomId, _getPlayer(name: widget.playerName));
        await repository.removeRoom(widget.roomId);
      }
      else {
        await repository.removePlayer(widget.roomId, _getPlayer(name: widget.playerName));
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
                              MessageWidget(msg: msg, player: widget.playerName, color: _getColorOfPlayer(name: msg.playerName)),
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
                    if (_getIndexOfPlayer() == 0)
                    Button(
                      text:"Nova rodada",
                      width: 170,
                      onTap: () {
                        _newRound();
                      },
                    ),
                    if(players.length > 1) ... [
                      Button(
                        text:"Truco",
                        width: 170,
                        onTap: () {
                          //_newRound();
                        },
                      ),
                      Button(
                        text:"Envido",
                        width: 170,
                        onTap: () {
                          //_newRound();
                        },
                      ),
                      Button(
                        text:"Flor",
                        width: 170,
                        onTap: () {
                          //_newRound();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(players.length > 3)
                    _board(3, true, true, false), // left
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(players.length > 1) ... [
                            _board(players.length == 2 ? 1 : 2, false, true, false), // up
                            _playerUI(players.length == 2 ? 1 : 2),
                          ],
                          if(players.length > 2) ... [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  players.length > 3 ? _playerUI(3) : const SizedBox(),
                                  _playerUI(1),
                                ],
                              )
                            ),
                          ] else ... [
                            const Expanded(child: SizedBox(),)
                          ],
                          if(players.isNotEmpty) ... [
                            _playerUI(0),
                            _board(0, false, false, true), // down
                          ],              
                        ],
                      ),
                    ),
                    if(players.length > 2)
                    _board(1, true, false, false), // right
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