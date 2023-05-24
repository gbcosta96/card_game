class PlayerModel {
  String name;
  int expectedPoints;
  int currentPoints;
  int points;

  String? refId;
  
  PlayerModel({
    required this.name,
    this.expectedPoints = -1,
    this.currentPoints = 0,
    this.points = 0,
    this.refId,
  });
  
  factory PlayerModel.fromJson(Map<String, dynamic> json, String refId) {
     return PlayerModel(
      name: json['name'],
      expectedPoints: json['expected_points'],
      currentPoints: json['current_points'],
      points: json['points'],
      refId: refId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'name': name,
      'expected_points': expectedPoints,
      'current_points': currentPoints,
      'points': points,
    };
  }
}
