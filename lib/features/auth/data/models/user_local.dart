import 'package:isar/isar.dart';

part 'user_local.g.dart';

@collection
class UserLocal {
  int id = 0;

  @Index(unique: true)
  late String uid;

  late String name;
  late String email;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Index(unique: true)
  String? serverId;

  late bool isDirty;
  late bool isDeleted;
}
