class MessageModel {
  String playerName;
  String message;
  String? refId;
  
  MessageModel({
    required this.playerName,
    required this.message,
    this.refId,
  });
  
  factory MessageModel.fromJson(Map<String, dynamic> json, String refId) {
     return MessageModel(
      playerName: json['player_name'],
      message: json['message'],
      refId: refId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'player_name': playerName,
      'message': message,
    };
  }
}
