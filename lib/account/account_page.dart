import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:star_wars_quiz/account/account_bloc.dart';
import 'package:star_wars_quiz/quiz/quiz_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AccountBloc(),
      dispose: (_, bloc) => bloc.dispose(),
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 600),
            child: const _AccountBody(),
          ),
        ),
      ),
    );
  }
}

class _AccountBody extends StatefulWidget {
  const _AccountBody({super.key});

  @override
  State<_AccountBody> createState() => _AccountBodyState();
}

class _AccountBodyState extends State<_AccountBody> {
  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      final loggedIn = await context.read<AccountBloc>().isLoggedIn();
      if (mounted) {
        setState(() => this.loggedIn = loggedIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!loggedIn!) {
      return const _EnterYourNameAndPass();
    }
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const QuizPage(),
          ),
        );
      }
    });
    return const SizedBox();
  }
}

class _EnterYourNameAndPass extends StatefulWidget {
  const _EnterYourNameAndPass({Key? key}) : super(key: key);

  @override
  State<_EnterYourNameAndPass> createState() => _EnterYourNameAndPassState();
}

class _EnterYourNameAndPassState extends State<_EnterYourNameAndPass> {
  late final TextEditingController _nameController;
  late final TextEditingController _passController;

  bool buttonEnabled = false;

  String? error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passController = TextEditingController();

    _nameController.addListener(_updateButtonState);
    _passController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      buttonEnabled =
          _nameController.text.isNotEmpty && _passController.text.isNotEmpty;
      error = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Name yourself, padawan',
            style: textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
            maxLength: 20,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              helperText: 'Do not use your real password, this is just a demo',
              errorText: error,
            ),
            maxLength: 20,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: buttonEnabled
                  ? () async {
                      final bloc = context.read<AccountBloc>();
                      final loginResult = await bloc.login(
                        login: _nameController.text,
                        password: _passController.text,
                      );
                      if (context.mounted) {
                        switch (loginResult) {
                          case LoginResult.success:
                            await Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const QuizPage()),
                            );
                            break;
                          case LoginResult.wrongPassword:
                            setState(() => error = 'Incorrect password');
                            break;
                          case LoginResult.error:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Something went wrong',
                                ),
                              ),
                            );
                            break;
                        }
                      }
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
