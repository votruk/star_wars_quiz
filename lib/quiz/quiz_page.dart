import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_wars_quiz/account/account_page.dart';
import 'package:star_wars_quiz/model/question.dart';
import 'package:star_wars_quiz/quiz/quiz_bloc.dart';
import 'package:star_wars_quiz/quiz/user_with_score.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      lazy: false,
      create: (_) => QuizBloc()..init(),
      dispose: (_, bloc) => bloc.dispose(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Star Wars Quiz'),
            actions: [
              IconButton(
                onPressed: () async {
                  await context.read<QuizBloc>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AccountPage()),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _QuizBody(),
            ),
          ),
        );
      }),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 660),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(
            flex: 2,
            child: _Questions(),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _Score(),
          ),
        ],
      ),
    );
  }
}

class _Questions extends StatefulWidget {
  const _Questions({super.key});

  @override
  State<_Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<_Questions> {
  String? selectedAnswer;
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Question>(
      stream: context.read<QuizBloc>().observeQuestion(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final question = snapshot.requireData;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final answer in question.answers)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Radio<String>(
                        groupValue: selectedAnswer,
                        value: answer,
                        onChanged: confirmed
                            ? null
                            : (value) {
                                setState(() => selectedAnswer = value);
                              },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        answer,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null
                      ? null
                      : () async => await _onPressed(_correctAnswer(question)),
                  child: Text(confirmed ? 'Next question' : 'Answer'),
                ),
              ),
              if (confirmed)
                _AnswerDescription(
                  answeredCorrectly: _correctAnswer(question),
                  description: question.description,
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  bool _correctAnswer(Question question) =>
      question.answers[question.rightAnswer] == selectedAnswer;

  Future<void> _onPressed(bool correct) async {
    if (confirmed) {
      await context.read<QuizBloc>().generateNewQuestion(correct: correct);
      setState(() {
        selectedAnswer = null;
        confirmed = false;
      });
    } else {
      setState(() => confirmed = true);
      await context.read<QuizBloc>().answerQuestion(correct: correct);
    }
  }
}

class _AnswerDescription extends StatelessWidget {
  const _AnswerDescription({
    super.key,
    required this.answeredCorrectly,
    required this.description,
  });

  final bool answeredCorrectly;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                answeredCorrectly ? 'Correct!' : 'Wrong!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: answeredCorrectly ? Colors.green : Colors.red,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserWithScore>>(
        stream: context.read<QuizBloc>().observeUsersWithScore(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final usersWithScores = snapshot.requireData;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Score',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (UserWithScore userWithScore in usersWithScores)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            userWithScore.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${userWithScore.rightAnswers}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
  }
}
