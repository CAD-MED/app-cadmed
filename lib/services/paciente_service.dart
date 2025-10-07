import 'package:Cad_Med/models/paciente.model.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';

Future<PacienteModel?> getPacienteByUuid({
  required PacienteRepository repository,
  required String uuid,
}) async {
  final res = await repository.getPacienteByUuid(uuid);
  if (res != null) {
    return PacienteModel.fromMap(res);
  }
  return null;
}

// Adicionar Paciente
Future<int> addPaciente({
  required PacienteRepository repository,
  required PacienteModel paciente,
}) async {
  return await repository.addPaciente(paciente);
}

// Deletar Paciente por uuid
Future<void> deletePaciente({
  required PacienteRepository repository,
  required String uuid,
}) async {
  await repository.deletePacienteByUuid(uuid);
}

// Atualizar Paciente por uuid
Future<void> updatePaciente({
  required PacienteRepository repository,
  required String uuid,
  required PacienteModel Paciente,
}) async {
  // Sempre marca como atualizado ao editar
  final PacienteAtualizado = PacienteModel(
    uuid: Paciente.uuid,
    nome: Paciente.nome,
    idade: Paciente.idade,
    sexo: Paciente.sexo,
    patologia: Paciente.patologia,
    atualizado: true,
    createdAt: Paciente.createdAt,
    updatedAt: Paciente.updatedAt,
  );
  await repository.updatePacienteByUuid(uuid, PacienteAtualizado);
}

// Buscar todos os Pacientes
Future<List<PacienteModel>> getAllPacientes({required PacienteRepository repository}) async {
  final data = await repository.getAllPacientes();
  return data.map<PacienteModel>((e) => PacienteModel.fromMap(e)).toList();
}

// Buscar Paciente por ID
Future<PacienteModel?> getPacienteById({
  required PacienteRepository repository,
  required int userId,
}) async {
  final res = await repository.getPacienteById(userId);
  if (res != null) {
    return PacienteModel.fromMap(res);
  }
  return null;
}
