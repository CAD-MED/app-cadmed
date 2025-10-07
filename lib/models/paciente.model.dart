

class PacienteModel {
  String uuid;
  String nome;
  int idade;
  String sexo;
  String patologia;
  bool atualizado;
  String? createdAt; // Campo opcional
  String? updatedAt; // Campo opcional

  // Construtor da classe PacienteModel
  PacienteModel({
    required this.uuid,
    required this.nome,
    required this.idade,
    required this.sexo,
    required this.patologia,
    this.atualizado = false,
    this.createdAt, // Opcional
    this.updatedAt, // Opcional
  });

  // Método que cria um objeto PacienteModel a partir de um Map
  factory PacienteModel.fromMap(Map<String, dynamic> map) {
    return PacienteModel(
      uuid: map['uuid'] ?? '',
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      sexo: map['sexo'] ?? '',
      patologia: map['patologia'] ?? '',
      atualizado: map['atualizado'] ?? false,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  // Método que converte um objeto PacienteModel em um Map
  Map<String, dynamic> toMap() {
    final map = {
      'uuid': uuid,
      'nome': nome,
      'idade': idade,
      'sexo': sexo,
      'patologia': patologia,
      'atualizado': atualizado,
    };
    if (createdAt != null) {
      map['createdAt'] = createdAt as dynamic;
    }
    if (updatedAt != null) {
      map['updatedAt'] = updatedAt as dynamic;
    }
    return map;
  }
}
