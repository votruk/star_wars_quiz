import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  const User({
    required this.username,
    required this.pass,
  });

  factory User.fromJson(final Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  final String username;
  final String pass;

  @override
  List<Object?> get props => [username, pass];
}
