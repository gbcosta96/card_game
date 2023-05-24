
import 'package:card_game/data/data_repository.dart';
import 'package:card_game/model/player_model.dart';
import 'package:card_game/model/room_model.dart';
import 'package:card_game/screens/home_page.dart';
import 'package:card_game/screens/truco_page.dart';
import 'package:card_game/utils/app_colors.dart';
import 'package:card_game/utils/dimensions.dart';
import 'package:card_game/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:card_game/widget/app_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode myFocusNode = FocusNode();
  final DataRepository repository = DataRepository();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRoom= TextEditingController();
  List<RoomModel> rooms = [];
  

  
  Widget _inputField(Icon prefixIcon, String hintText, bool isPassword, TextEditingController controller) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      margin: EdgeInsets.only(bottom: Dimensions.height(Dimensions.loginSpacingHeight)),
      child: TextField(
        controller: controller,
        maxLength: 12,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.backColor,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.inputPaddingHeight),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.inputHint,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: Dimensions.width(Dimensions.inputPrefixWidth),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void putSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      )
    );
  }

  bool checkFields() {
    if(controllerName.text.isEmpty) {
      putSnack("Name is empty");
    } else if(controllerRoom.text.isEmpty) {
      putSnack("Room is empty");
    } else {
      return true;
    }
    return false;
  }

  void joinRoom() {
    if(checkFields() == false) {
      return;
    }
    repository.checkRoom(controllerRoom.text).then((doc) {
      if(doc) {
        repository.getPlayers(controllerRoom.text).then((players) {
          if(players.length < 4) {
            if(!players.any((player) => player.name == controllerName.text)) {
              PlayerModel player = PlayerModel(
                name: controllerName.text,
              );
              repository.addPlayer(controllerRoom.text, player);
              repository.getRoom(controllerRoom.text).then((room) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>
                    room.game == Games.fodinha ?
                    HomePage(
                      playerName: controllerName.text,
                      roomId: controllerRoom.text,
                    ) : 
                    TrucoPage(
                      playerName: controllerName.text,
                      roomId: controllerRoom.text,
                    ),
                  )
                );
              });
            }
            else {
              putSnack("Name taken!");
            }
          }
          else {
            putSnack("Room is full!");
          }
        });
      }
      else {
        putSnack("Room doesn't exists!");
      }
    });
  }

  void createRoom() {
    if(checkFields() == false) {
      return;
    }
    repository.checkRoom(controllerRoom.text).then((value) {
      if(!value) {
        RoomModel newRoom = RoomModel(
          referenceId: controllerRoom.text,
        );
        PlayerModel host = PlayerModel(
          name: controllerName.text,
        );
        repository.addRoom(newRoom, host);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
            HomePage(
              playerName: controllerName.text,
              roomId: controllerRoom.text,
            ),
          )
        );
      }
      else {
        putSnack("Room already exists!");
      }
    });
  }

  void createTrucoRoom() {
    if(checkFields() == false) {
      return;
    }
    repository.checkRoom(controllerRoom.text).then((value) {
      if(!value) {
        RoomModel newRoom = RoomModel(
          referenceId: controllerRoom.text,
          game: Games.truco,
        );
        PlayerModel host = PlayerModel(
          name: controllerName.text,
        );
        repository.addRoom(newRoom, host);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
            TrucoPage(
              playerName: controllerName.text,
              roomId: controllerRoom.text,
            ),
          )
        );
      }
      else {
        putSnack("Room already exists!");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    repository.getRoomsSnap().listen((snap) {
      setState(() {
        rooms = snap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backColor,
        body: Center(
          child: SizedBox(
            width: Dimensions.width(MediaQuery.of(context).orientation == Orientation.portrait ?
                Dimensions.loginWidth : Dimensions.loginLandscapingWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(text: "Fodinha", size: 40),
                SizedBox(height: Dimensions.height(Dimensions.loginSpacingHeight)),
                _inputField(const Icon(Icons.person), "Name", false, controllerName),
                _inputField(const Icon(Icons.person), "Room Name", false, controllerRoom),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      text: "Create room",
                      onTap: () {
                        createRoom();
                      },
                    ),
                    Button(
                      text: "Create truco room",
                      onTap: () {
                        createTrucoRoom();
                      },
                    ),
                    Button(
                      text: "Join room",
                      onTap: () {
                        joinRoom();
                      },
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const AppText(text: "Salas", size: 40),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.all(20),
                        height: 200,
                        child: GridView.count(
                          crossAxisCount: 8,
                          children: [
                            for(RoomModel room in rooms)
                            AppText(text: room.referenceId),
                        ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}