class MatchRounds {
  final int? id;
  final int? round;
  final int? team1;
  final int? team2;
  final int? team1Pts;
  final int? team2Pts;

  const MatchRounds({
    this.id,
    this.round,
    this.team1,
    this.team2,
    this.team1Pts,
    this.team2Pts,
  });

  factory MatchRounds.fromJson(Map<String, dynamic> json) {
    return MatchRounds(
      id: json['id'] as int?,
      round: json['round'] as int?,
      team1: json['team1'] as int?,
      team2: json['team2'] as int?,
      team1Pts: json['team1Pts'] as int?,
      team2Pts: json['team2Pts'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round': round,
      'team1': team1,
      'team2': team2,
      'team1Pts': team1Pts,
      'team2Pts': team2Pts,
    };
  }
}
