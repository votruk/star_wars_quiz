import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:star_wars_quiz/disposable.dart';
import 'package:star_wars_quiz/firestore.dart';
import 'package:star_wars_quiz/model/answer_with_id.dart';
import 'package:star_wars_quiz/model/question.dart';
import 'package:star_wars_quiz/model/questions_with_id.dart';
import 'package:star_wars_quiz/model/user_with_id.dart';
import 'package:star_wars_quiz/quiz/user_with_score.dart';
import 'package:star_wars_quiz/shared_prefs.dart';

class QuizBloc implements Disposable {
  final _refetchSubject = PublishSubject<int>();
  final _currentQuestionSubject = BehaviorSubject<String>();
  final _questionsSubject = BehaviorSubject<List<QuestionWithId>>();
  final _answersSubject = BehaviorSubject<List<AnswerWithId>>();
  final _usersSubject = BehaviorSubject<List<UserWithId>>();

  StreamSubscription? _questionsSubscription;
  StreamSubscription? _answersSubscription;
  StreamSubscription? _usersSubscription;

  void init() {
    print('AAAAA. init');
    _questionsSubscription?.cancel();
    _questionsSubscription =
        Firestore.getQuestions().asStream().listen((questions) {
      print('AAAAA. questions: $questions');
      _currentQuestionSubject.add(
        questions[Random().nextInt(questions.length)].id,
      );
      _questionsSubject.add(questions);
    });

    _answersSubscription?.cancel();
    _answersSubscription = Rx.merge(
      [
        Stream.periodic(const Duration(seconds: 10)).startWith(0),
        _refetchSubject,
      ],
    ).switchMap((value) => Firestore.getAnswers().asStream()).listen((answers) {
      print('AAAAA. answers: $answers');
      _answersSubject.add(answers);
    });

    _usersSubscription?.cancel();
    _usersSubscription = Rx.merge(
      [
        Stream.periodic(const Duration(seconds: 10)).startWith(0),
        _refetchSubject,
      ],
    )
        .switchMap((value) => Firestore.getUsersWithId().asStream())
        .listen((users) {
      print('AAAAA. users: $users');
      _usersSubject.add(users);
    });
  }

  Stream<Question> observeQuestion() => Rx.combineLatest2(
        _currentQuestionSubject,
        _questionsSubject,
        (currentQuestionId, questions) {
          print(
              'AAAAA. currentQuestionId: $currentQuestionId, questions: $questions');
          return questions
              .firstWhere((element) => element.id == currentQuestionId)
              .question;
        },
      );

  Stream<List<UserWithScore>> observeUsersWithScore() => Rx.combineLatest2(
      _answersSubject,
      _usersSubject,
      (answers, users) => _convert(answers: answers, users: users)).distinct();

  List<UserWithScore> _convert({
    required List<AnswerWithId> answers,
    required List<UserWithId> users,
  }) =>
      users
          .map(
            (user) {
              final userAnswers = answers.where(
                (answerWithId) => answerWithId.answer.userId == user.id,
              );
              print('AAAAA. userAnswers: $userAnswers');
              if (userAnswers.isEmpty) {
                return null;
              }
              final correctAnswersCount = userAnswers
                  .where((answerWithId) => answerWithId.answer.correct)
                  .length;
              return UserWithScore(
                name: user.user.username,
                percentage: correctAnswersCount / userAnswers.length * 100,
                rightAnswers: correctAnswersCount,
              );
            },
          )
          .whereNotNull()
          .sorted((a, b) => b.rightAnswers.compareTo(a.rightAnswers))
          .toList();

  Future<void> logout() async {
    await SharedPrefs.logout();
  }

  Future<void> answerQuestion({
    required bool correct,
  }) async {
    final questionId = _currentQuestionSubject.value;
    final users = _usersSubject.value;
    final currentUser = await SharedPrefs.getCurrentUser();
    print('AAAAA. currentUser: $currentUser');
    if (currentUser == null) {
      return;
    }
    final user = users.firstWhereOrNull(
      (userWithId) => userWithId.user.username == currentUser.username,
    );
    print('AAAAA. user: $user');
    if (user == null) {
      return;
    }
    if (correct) {
      await Firestore.answerQuestion(
        questionId: questionId,
        userId: user.id,
        correct: correct,
      );
    }
    _refetchSubject.add(0);
  }

  Future<void> generateNewQuestion({
    required bool correct,
  }) async {
    final questions = await Firestore.getQuestions();
    final answers = _answersSubject.value;
    final notAnsweredQuestions = questions
        .where(
          (questionWithId) => !answers.any(
            (answerWithId) =>
                answerWithId.answer.questionId == questionWithId.id,
          ),
        )
        .toList();
    _currentQuestionSubject.add(
      notAnsweredQuestions[Random().nextInt(notAnsweredQuestions.length)].id,
    );
  }

  @override
  Future<void> dispose() async {
    _questionsSubscription?.cancel();
    _answersSubscription?.cancel();
    _usersSubscription?.cancel();
    await _refetchSubject.close();
    await _currentQuestionSubject.close();
    await _questionsSubject.close();
    await _answersSubject.close();
    await _usersSubject.close();
  }
}
