class PlayerModel {
  String name;
  int expectedPoints;
  int currentPoints;
  int fails;

  String? refId;
  
  PlayerModel({
    required this.name,
    this.expectedPoints = -1,
    this.currentPoints = 0,
    this.fails = 0,
    this.refId,
  });
  
  factory PlayerModel.fromJson(Map<String, dynamic> json, String refId) {
     return PlayerModel(
      name: json['name'],
      expectedPoints: json['expected_points'],
      currentPoints: json['current_points'],
      fails: json['fails'],
      refId: refId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'name': name,
      'expected_points': expectedPoints,
      'current_points': currentPoints,
      'fails': fails,
    };
  }
}
