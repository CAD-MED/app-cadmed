
import 'package:Cad_Med/models/paciente.model.dart';

class ExportPessoaModel {
  ExportPessoaModel copyWith({
    String? operador_nome,
    String? operador_email,
  }) {
    return ExportPessoaModel(
      uuid: this.uuid,
      nome: this.nome,
      idade: this.idade,
      sexo: this.sexo,
      condicaofisica: this.condicaofisica,
      operador_nome: operador_nome ?? this.operador_nome,
      operador_email: operador_email ?? this.operador_email,
      datatime: this.datatime,
    );
  }
  // Construtor auxiliar para converter PacienteModel em ExportPessoaModel
  factory ExportPessoaModel.fromPacienteModel(PacienteModel r) {
    return ExportPessoaModel(
      uuid: r.uuid,
      nome: r.nome,
      idade: r.idade,
      sexo: r.sexo,
      condicaofisica: r.patologia,
      operador_nome: '', // Preencher se necessário
      operador_email: '', // Preencher se necessário
      datatime: r.createdAt ?? DateTime.now().toUtc().toIso8601String(),
    );
  }
  final String uuid;
  final String nome;
  final int idade;
  final String sexo;
  final String condicaofisica;
  final String operador_nome;
  final String operador_email;
  final String datatime;

  ExportPessoaModel({
    required this.uuid,
    required this.nome,
    required this.idade,
    required this.sexo,
    required this.condicaofisica,
    required this.operador_nome,
    required this.operador_email,
    required this.datatime,
  });

  factory ExportPessoaModel.fromMap(Map<String, dynamic> map) {
    return ExportPessoaModel(
      uuid: map['uuid'] ?? '',
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      sexo: map['sexo'] ?? '',
      condicaofisica: map['condicaofisica'] ?? map['patologia'] ?? '',
      operador_nome: map['operador_nome'] ?? '',
      operador_email: map['operador_email'] ?? '',
      datatime: map['datatime'] ?? map['createdAt'] ?? DateTime.now().toUtc().toIso8601String(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      // Retorna no formato yyyy-MM-dd HH:mm:ss
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Map<String, dynamic> toJson() {
    // Normalizar sexo
    String sexoNormalizado = sexo.toLowerCase();
    if (sexoNormalizado == 'feminino') sexoNormalizado = 'feminino';
    else if (sexoNormalizado == 'masculino') sexoNormalizado = 'masculino';
    else if (sexoNormalizado == 'outros' || sexoNormalizado == 'outro') sexoNormalizado = 'outros';
    else sexoNormalizado = 'outros';

    // Garantir operador_email válido
    String emailValido = operador_email;

    // Formatar datatime
    String datatimeFormatado = datatime.isNotEmpty ? _formatDate(datatime) : _formatDate(DateTime.now().toUtc().toIso8601String());

    return {
      'uuid': uuid.isNotEmpty ? uuid : '',
      'nome': nome.isNotEmpty ? nome : '',
      'idade': idade,
      'sexo': sexoNormalizado,
      'patologia': condicaofisica.isNotEmpty ? condicaofisica : '',
      'operador_nome': operador_nome.isNotEmpty ? operador_nome : '',
      'operador_email': emailValido,
      'datatime': datatimeFormatado,
    };
  }
}
