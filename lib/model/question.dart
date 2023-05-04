import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Question extends Equatable {
  const Question({
    required this.question,
    required this.answers,
    required this.rightAnswer,
    required this.description,
    required this.category,
  });

  factory Question.fromJson(final Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  final String question;
  final List<String> answers;
  final int rightAnswer;
  final String description;
  final String category;

  @override
  List<Object?> get props => [
        question,
        answers,
        rightAnswer,
        description,
        category,
      ];
}
