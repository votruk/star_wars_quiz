// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      userId: json['user_id'] as String,
      questionId: json['question_id'] as String,
      correct: json['correct'] as bool,
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'user_id': instance.userId,
      'question_id': instance.questionId,
      'correct': instance.correct,
    };
