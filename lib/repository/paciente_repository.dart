
import 'dart:io';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/models/paciente.model.dart';
import 'package:path_provider/path_provider.dart';

class PacienteRepository {

  Future<String> exportToCsvFile() async {
    final Pacientes = await getAllPacientes();
    if (Pacientes.isEmpty) {
      throw Exception('Nenhum Paciente encontrado para exportar.');
    }
    final headers = Pacientes.first.keys.toList();
    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));
    // Linhas
    for (final r in Pacientes) {
      buffer.writeln(headers.map((h) => '"${r[h]?.toString().replaceAll('"', '""') ?? ''}"').join(','));
    }
    // Salva arquivo temporário
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Pacientes_export.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
  Future<Map<String, dynamic>?> getPacienteByUuid(String uuid) async {
    final box = helper.getBox(boxName);
    final Paciente = box.values.firstWhere(
      (e) => e['uuid'] == uuid,
      orElse: () => null,
    );
    if (Paciente != null) {
      return Map<String, dynamic>.from(Paciente);
    }
    return null;
  }
  final HiveHelper helper;
  final String boxName = 'Pacientes';
  PacienteRepository(this.helper);

  Future<int> addPaciente(PacienteModel Paciente) async {
    final box = helper.getBox(boxName);
    return await box.add(Paciente.toMap());
  }

  Future<void> updatePacienteByUuid(String uuid, PacienteModel Paciente) async {
    final box = helper.getBox(boxName);
    final key = box.keys.firstWhere((k) => box.get(k)['uuid'] == uuid, orElse: () => null);
    if (key != null) {
      await box.put(key, Paciente.toMap());
    }
  }

  Future<void> deletePacienteByUuid(String uuid) async {
    final box = helper.getBox(boxName);
    final key = box.keys.firstWhere((k) => box.get(k)['uuid'] == uuid, orElse: () => null);
    if (key != null) {
      await box.delete(key);
    }
  }

  Future<List<Map<String, dynamic>>> getAllPacientes() async {
    final box = helper.getBox(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getPacienteById(int id) async {
    final box = helper.getBox(boxName);
    final Paciente = box.get(id);
    if (Paciente != null) {
      return Map<String, dynamic>.from(Paciente);
    }
    return null;
  }
}
