import 'dart:convert';
import 'package:Cad_Med/models/export_paciente.model.dart';
import 'package:Cad_Med/models/paciente.model.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';
import 'package:Cad_Med/services/http_method_service.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class ExportService {
  static Future<Map<String, dynamic>> exportarSincronizandoComApiComRetorno({
    required List<PacienteModel> Pacientes,
    required String operadorNome,
    required String operadorEmail,
    required String apiPassword,
    required PacienteRepository repository,
    String? servidor,
  }) async {
    if (Pacientes.isEmpty) {
      print('[EXPORT] Nenhum Paciente para exportar.');
      return {'sucesso': false, 'sincronizados': 0};
    }
    String baseUrl = servidor ?? '';
    if (baseUrl.isEmpty) {
      try {
        final box = Hive.box('logins');
        if (box.isNotEmpty) {
          final loginMap = box.getAt(0);
          if (loginMap != null && loginMap is Map && loginMap.containsKey('servidor')) {
            baseUrl = loginMap['servidor'] ?? 'https://api-cadmed.nextlab.cloud/';
          } else {
            baseUrl = 'https://api-cadmed.nextlab.cloud/';
          }
        } else {
          baseUrl = 'https://api-cadmed.nextlab.cloud/';
        }
      } catch (e) {
        baseUrl = 'https://api-cadmed.nextlab.cloud/';
      }
    }
    final uuids = Pacientes.map((r) => r.uuid).toList();
    print('[EXPORT] UUIDs locais: $uuids');
    final String syncUrl = baseUrl + 'api/pessoa/sync';
    print('[EXPORT] Usando servidor: $baseUrl');
    print('[EXPORT] Enviando para $syncUrl com senha: "$apiPassword"');
    final syncResponse = await HttpMethodService.post(
      syncUrl,
      headers: {
        'accept': 'application/json',
        'x-api-password': apiPassword,
        'Content-Type': 'application/json',
      },
      body: {'uuids': uuids},
    );
    print('[EXPORT] Status sync: ${syncResponse.statusCode}');
    print('[EXPORT] Body sync: ${syncResponse.body}');
    if (syncResponse.statusCode != 201) return {'sucesso': false, 'sincronizados': 0};
    final syncData = syncResponse.body;
    final missingUuids = <String>[];
    try {
      final decoded = jsonDecode(syncData);
      if (decoded is Map && decoded['missing'] is List) {
        missingUuids.addAll(List<String>.from(decoded['missing']));
      }
    } catch (e) {
      print('[EXPORT] Erro ao decodificar syncData: $e');
      return {'sucesso': false, 'sincronizados': 0};
    }
    print('[EXPORT] UUIDs faltando na base remota: $missingUuids');
    final temAtualizados = Pacientes.any((r) => r.atualizado == true);
    if (missingUuids.isEmpty && !temAtualizados) {
      print('[EXPORT] Nada a exportar.');
      return {'sucesso': true, 'sincronizados': 0};
    }
    final pessoasParaExportar = Pacientes
      .where((r) => missingUuids.contains(r.uuid) || r.atualizado == true)
      .map((r) => ExportPessoaModel.fromPacienteModel(r).copyWith(
          operador_nome: operadorNome,
          operador_email: operadorEmail,
        ).toJson())
      .toList();
    print('[EXPORT] Pessoas para exportar: $pessoasParaExportar');
    if (pessoasParaExportar.isEmpty) {
      print('[EXPORT] Nenhuma pessoa para exportar após filtro.');
      return {'sucesso': true, 'sincronizados': 0};
    }
    final String upsertUrl = baseUrl + 'api/pessoa/upsert-batch';
    final jsonBody = jsonEncode({'pessoas': pessoasParaExportar});
    print('[EXPORT] JSON serializado enviado para upsert: $jsonBody');
    try {
      final upsertResponse = await HttpMethodService.post(
        upsertUrl,
        headers: {
          'accept': '*/*',
          'x-api-password': apiPassword,
          'Content-Type': 'application/json',
        },
        body: {'pessoas': pessoasParaExportar},
      );
      print('[EXPORT] Status upsert: \\${upsertResponse.statusCode}');
      print('[EXPORT] Body upsert: \\${upsertResponse.body}');
      if (upsertResponse.statusCode != 200 && upsertResponse.statusCode != 201) {
        print('[EXPORT] Falha ao exportar! Status: \\${upsertResponse.statusCode}, Body: \\${upsertResponse.body}');
      }
      final sucesso = upsertResponse.statusCode == 200 || upsertResponse.statusCode == 201;
      int totalSincronizados = 0;
      if (sucesso) {
        try {
          final upsertBody = upsertResponse.body;
          final decoded = jsonDecode(upsertBody);
          if (decoded is Map && decoded['upserted'] is List) {
            final uuidsExportados = List<String>.from(decoded['upserted']);
            totalSincronizados = uuidsExportados.length;
            for (final uuid in uuidsExportados) {
              final Paciente = Pacientes.firstWhereOrNull((r) => r.uuid == uuid);
              if (Paciente != null) {
                final repo = repository;
                final PacienteAtualizado = PacienteModel(
                  uuid: Paciente.uuid,
                  nome: Paciente.nome,
                  idade: Paciente.idade,
                  sexo: Paciente.sexo,
                  patologia: Paciente.patologia,
                  atualizado: false,
                  createdAt: Paciente.createdAt,
                  updatedAt: Paciente.updatedAt,
                );
                await repo.updatePacienteByUuid(Paciente.uuid, PacienteAtualizado);
                print('[EXPORT] Marcou atualizado:false para uuid: ${Paciente.uuid}');
              }
            }
          }
        } catch (e) {
          print('[EXPORT] Erro ao marcar atualizado:false: $e');
        }
      }
      return {'sucesso': sucesso, 'sincronizados': totalSincronizados};
    } catch (e, s) {
      print('[EXPORT] Erro inesperado no upsert: $e');
      print('[EXPORT] Stack: $s');
      return {'sucesso': false, 'sincronizados': 0};
    }
  }
  static Future<bool> exportarSincronizandoComApi({
    required List<PacienteModel> Pacientes,
    required String operadorNome,
    required String operadorEmail,
    required String apiPassword,
    required PacienteRepository repository,
  String? servidor,
  }) async {
    if (Pacientes.isEmpty) {
      print('[EXPORT] Nenhum Paciente para exportar.');
      return false;
    }
    String baseUrl = servidor ?? '';
    if (baseUrl.isEmpty) {
      try {
        final box = Hive.box('logins');
        if (box.isNotEmpty) {
          final loginMap = box.getAt(0);
          if (loginMap != null && loginMap is Map && loginMap.containsKey('servidor')) {
            baseUrl = loginMap['servidor'] ?? 'https://api-cadmed.nextlab.cloud/';
          } else {
            baseUrl = 'https://api-cadmed.nextlab.cloud/';
          }
        } else {
          baseUrl = 'https://api-cadmed.nextlab.cloud/';
        }
      } catch (e) {
        baseUrl = 'https://api-cadmed.nextlab.cloud/';
      }
    }
    final uuids = Pacientes.map((r) => r.uuid).toList();
    print('[EXPORT] UUIDs locais: $uuids');
    final String syncUrl = baseUrl + 'api/pessoa/sync';
    print('[EXPORT] Usando servidor: $baseUrl');
    print('[EXPORT] Enviando para $syncUrl com senha: "$apiPassword"');
    final syncResponse = await HttpMethodService.post(
      syncUrl,
      headers: {
        'accept': 'application/json',
        'x-api-password': apiPassword,
        'Content-Type': 'application/json',
      },
      body: {'uuids': uuids},
    );
    print('[EXPORT] Status sync: ${syncResponse.statusCode}');
    print('[EXPORT] Body sync: ${syncResponse.body}');
    if (syncResponse.statusCode != 201) return false;
    final syncData = syncResponse.body;
    final missingUuids = <String>[];
    try {
      final decoded = jsonDecode(syncData);
      if (decoded is Map && decoded['missing'] is List) {
        missingUuids.addAll(List<String>.from(decoded['missing']));
      }
    } catch (e) {
      print('[EXPORT] Erro ao decodificar syncData: $e');
      return false;
    }
    print('[EXPORT] UUIDs faltando na base remota: $missingUuids');
    final temAtualizados = Pacientes.any((r) => r.atualizado == true);
    if (missingUuids.isEmpty && !temAtualizados) {
      print('[EXPORT] Nada a exportar.');
      return true;
    }
  final pessoasParaExportar = Pacientes
    .where((r) => missingUuids.contains(r.uuid) || r.atualizado == true)
    .map((r) => ExportPessoaModel.fromPacienteModel(r).copyWith(
        operador_nome: operadorNome,
        operador_email: operadorEmail,
      ).toJson())
    .toList();
    print('[EXPORT] Pessoas para exportar: $pessoasParaExportar');
    if (pessoasParaExportar.isEmpty) {
      print('[EXPORT] Nenhuma pessoa para exportar após filtro.');
      return true;
    }
  final String upsertUrl = baseUrl + 'api/pessoa/upsert-batch';
  final jsonBody = jsonEncode({'pessoas': pessoasParaExportar});
  print('[EXPORT] JSON serializado enviado para upsert: $jsonBody');
    try {
      final upsertResponse = await HttpMethodService.post(
        upsertUrl,
        headers: {
          'accept': '*/*',
          'x-api-password': apiPassword,
          'Content-Type': 'application/json',
        },
        body: {'pessoas': pessoasParaExportar},
      );
      print('[EXPORT] Status upsert: \\${upsertResponse.statusCode}');
      print('[EXPORT] Body upsert: \\${upsertResponse.body}');
      if (upsertResponse.statusCode != 200 && upsertResponse.statusCode != 201) {
        print('[EXPORT] Falha ao exportar! Status: \\${upsertResponse.statusCode}, Body: \\${upsertResponse.body}');
      }
      final sucesso = upsertResponse.statusCode == 200 || upsertResponse.statusCode == 201;
      print('[EXPORT] Sucesso upsert? $sucesso');
      if (sucesso) {
        try {
          final upsertBody = upsertResponse.body;
          final decoded = jsonDecode(upsertBody);
          if (decoded is Map && decoded['upserted'] is List) {
            final uuidsExportados = List<String>.from(decoded['upserted']);
            for (final uuid in uuidsExportados) {
              final Paciente = Pacientes.firstWhere((r) => r.uuid == uuid && r.atualizado == true,);
              final repo = repository;
              final PacienteAtualizado = PacienteModel(
                uuid: Paciente.uuid,
                nome: Paciente.nome,
                idade: Paciente.idade,
                sexo: Paciente.sexo,
                patologia: Paciente.patologia,
                atualizado: false,
                createdAt: Paciente.createdAt,
                updatedAt: Paciente.updatedAt,
              );
              await repo.updatePacienteByUuid(Paciente.uuid, PacienteAtualizado);
              print('[EXPORT] Marcou atualizado:false para uuid: ${Paciente.uuid}');
            }
          }
        } catch (e) {
          print('[EXPORT] Erro ao marcar atualizado:false: $e');
        }
      }
      return sucesso;
    } catch (e, s) {
      print('[EXPORT] Erro inesperado no upsert: $e');
      print('[EXPORT] Stack: $s');
      return false;
    }
  }

  static Future<bool> exportarPessoasBatch({
    required List<Map<String, dynamic>> pessoas,
    required String apiPassword,
  }) async {
    final String url = (pessoas.isNotEmpty && pessoas.first.containsKey('servidor'))
      ? pessoas.first['servidor'] + 'api/pessoa/upsert-batch'
      : 'https://api-cadmed.nextlab.cloud/api/pessoa/upsert-batch';
    try {
      final response = await HttpMethodService.post(
        url,
        headers: {
          'accept': '*/*',
          'x-api-password': apiPassword,
          'Content-Type': 'application/json',
        },
        body: {'pessoas': pessoas},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> exportarDados(Map<String, dynamic> dados, String url) async {
    try {
      final response = await HttpMethodService.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: dados,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
