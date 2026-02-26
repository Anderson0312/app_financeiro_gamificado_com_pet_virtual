import '../domain/models/user.dart';

/// Repositório de dados do usuário.
abstract class UserRepository {
  Future<User?> getUser();
  Future<void> saveUser(User user);
}
