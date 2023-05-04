import 'package:equatable/equatable.dart';
import 'package:star_wars_quiz/model/answer.dart';

class AnswerWithId extends Equatable {
  const AnswerWithId(this.id, this.answer);

  final String id;
  final Answer answer;

  @override
  List<Object?> get props => [id, answer];
}
