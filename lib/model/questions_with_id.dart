import 'package:equatable/equatable.dart';
import 'package:star_wars_quiz/model/question.dart';

class QuestionWithId extends Equatable {
  const QuestionWithId(this.id, this.question);

  final String id;
  final Question question;

  @override
  List<Object?> get props => [id, question];
}
