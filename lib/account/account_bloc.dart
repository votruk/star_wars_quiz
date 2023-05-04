import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:star_wars_quiz/disposable.dart';
import 'package:star_wars_quiz/firestore.dart';
import 'package:star_wars_quiz/model/user.dart';
import 'package:star_wars_quiz/shared_prefs.dart';

class AccountBloc implements Disposable {
  Future<bool> isLoggedIn() async {
    final user = await SharedPrefs.getCurrentUser();
    print('user: $user');
    return user != null;
  }

  Future<LoginResult> login({
    required String login,
    required String password,
  }) async {
    try {
      final usersWithIds = await Firestore.getUsersWithId();
      final userWithTheSameLoginAndPassword = usersWithIds.firstWhereOrNull(
        (usersWithId) =>
            usersWithId.user.username == login &&
            usersWithId.user.pass == password,
      );
      if (userWithTheSameLoginAndPassword != null) {
        await SharedPrefs.saveUser(userWithTheSameLoginAndPassword.user);
        return LoginResult.success;
      }
      final userWithTheSameLogin = usersWithIds.firstWhereOrNull(
        (usersWithId) => usersWithId.user.username == login,
      );
      if (userWithTheSameLogin != null) {
        return LoginResult.wrongPassword;
      }
      final newUser = User(username: login, pass: password);
      await Firestore.createUser(user: newUser);
      await SharedPrefs.saveUser(newUser);
      return LoginResult.success;
    } catch (e, s) {
      debugPrint('$e $s');
      return LoginResult.error;
    }
  }

  @override
  Future<void> dispose() async {}
}

enum LoginResult {
  success,
  wrongPassword,
  error,
}
