import 'package:equatable/equatable.dart';

class UserWithScore extends Equatable {
  const UserWithScore({
    required this.name,
    required this.percentage,
    required this.rightAnswers,
  });

  final String name;
  final double percentage;
  final int rightAnswers;

  @override
  List<Object?> get props => [name, percentage, rightAnswers];
}
