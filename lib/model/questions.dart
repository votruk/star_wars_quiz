import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:star_wars_quiz/model/question.dart';

part 'questions.g.dart';

@JsonSerializable()
class Questions extends Equatable {

  const Questions(this.questions);

  factory Questions.fromJson(final Map<String, dynamic> json) => _$QuestionsFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionsToJson(this);

  final List<Question> questions;

  @override
  List<Object?> get props => [questions];
}