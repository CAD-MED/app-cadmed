import 'package:Cad_Med/models/user.model.dart';
import 'package:Cad_Med/repository/user_repository.dart';

Future<int> addUser({
  required UserRepository repository,
  required nome,
  required posto,
  required senha,
  required servidor,
}) async {
  UserModel user = UserModel(
    nome: nome,
    posto: posto,
    senha: senha,
    servidor: servidor,
  );
  int res = await repository.addUser(user);
  return res;
}

Future<void> updateUser({
  required UserRepository repository,
  required id,
  required nome,
  required posto,
  required senha,
  String servidor = 'https://api-cadmed.nextlab.cloud/',
}) async {
  UserModel user = UserModel(
    nome: nome,
    posto: posto,
    senha: senha,
    servidor: servidor,
  );
  await repository.updateUser(id, user);
}

Future<List> getAllLogin({required UserRepository repository}) async {
  List data = await repository.getAllUsers();
  return data;
}

Future<Map<String, dynamic>?> getFirstUser({required UserRepository repository}) async {
  final user = await repository.getFirstUserWithKey();
  return user;
}
