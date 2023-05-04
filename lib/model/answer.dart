import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'answer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Answer extends Equatable {
  const Answer({
    required this.userId,
    required this.questionId,
    required this.correct,
  });

  factory Answer.fromJson(final Map<String, dynamic> json) =>
      _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  final String userId;
  final String questionId;
  final bool correct;

  @override
  List<Object?> get props => [userId, questionId, correct];
}
