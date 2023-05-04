import 'package:equatable/equatable.dart';
import 'package:star_wars_quiz/model/user.dart';

class UserWithId extends Equatable {
  const UserWithId(this.id, this.user);

  final String id;
  final User user;

  @override
  List<Object?> get props => [id, user];
}
