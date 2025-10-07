import 'package:Cad_Med/components/elevatedbuttoncustom.dart';
import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPage.dart';
import 'package:Cad_Med/pages/editar_usuario.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';
import 'package:Cad_Med/services/paciente_service.dart';
import 'package:flutter/material.dart';
import 'package:Cad_Med/services/export_service.dart';
import 'package:hive/hive.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:share_plus/share_plus.dart';

class Pagesettings extends StatefulWidget {
  const Pagesettings({super.key});

  @override
  State<Pagesettings> createState() => _PagesettingsState();
}

class _PagesettingsState extends State<Pagesettings> {
  final String rodapeTexto =
      "Explore as configurações para personalizar sua experiência e garantir que o CadMed continue a atender às suas necessidades de forma eficaz e segura.";
  bool loading = false;
  final HiveHelper dbHelper = HiveHelper();

  // Função para mostrar a confirmação de exportação
  Future<void> _showConfirmExportDialog(BuildContext context) async {
    // Simulação: todos com atualizado:true serão sincronizados
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Exportar dados',
      text: 'Você deseja exportar os dados do aplicativo?',
      confirmBtnText: 'Sim',
      cancelBtnText: 'Não',
      onConfirmBtnTap: () {
        Navigator.of(context).pop(); // Fechar o popup de confirmação
        _exportData(context); // Iniciar o processo de exportação
      },
    );
  }

  // Função para exportar os dados e tratar erro/sucesso
  Future<Map<String, dynamic>> exportDatabase(
      {required HiveHelper dbHelper}) async {
    final repo = PacienteRepository(dbHelper);
    final Pacientes = await getAllPacientes(repository: repo);
    print('[EXPORT][DEBUG] Estado dos Pacientes antes de exportar:');
    for (final r in Pacientes) {
      print(
          '[EXPORT][DEBUG] uuid: ${r.uuid}, nome: ${r.nome}, atualizado: ${r.atualizado}');
    }
    if (Pacientes.isEmpty) {
      return {'status': 404, 'sincronizados': 0}; // Nenhum Paciente cadastrado
    }
    // Busca a senha do Hive (box logins)
    final loginsBox = Hive.box('logins');
    print('[EXPORT] Chaves em loginsBox: \\${loginsBox.keys}');
    for (var k in loginsBox.keys) {
      print('[EXPORT] loginsBox[${k.toString()}] = \\${loginsBox.get(k)}');
    }
    final loginMap = loginsBox.isNotEmpty ? loginsBox.getAt(0) : null;
    final apiPassword =
        loginMap != null && loginMap is Map && loginMap.containsKey('senha')
            ? loginMap['senha']
            : '';
    final operadorNome =
        loginMap != null && loginMap is Map && loginMap.containsKey('nome')
            ? loginMap['nome']
            : '';
    final operadorEmail =
        loginMap != null && loginMap is Map && loginMap.containsKey('nome')
            ? loginMap['nome']
            : '';
    print('[EXPORT] Senha lida do Hive: "$apiPassword"');
    print('[EXPORT] Operador nome: "$operadorNome"');
    print('[EXPORT] Operador email: "$operadorEmail"');
    if (apiPassword.isEmpty) {
      print('[EXPORT] Senha não encontrada no Hive!');
      return {'status': 403, 'sincronizados': 0}; // Sem senha
    }
    // Passa PacienteModel para ExportService, junto com operador info
    final result = await ExportService.exportarSincronizandoComApiComRetorno(
      Pacientes: Pacientes,
      operadorNome: operadorNome,
      operadorEmail: operadorEmail,
      apiPassword: apiPassword,
      repository: repo,
    );
    print('[EXPORT] Resultado da exportação: ${result['sucesso']}');
    return {
      'status': result['sucesso'] ? 201 : 500,
      'sincronizados': result['sincronizados'] ?? 0
    };
  }

  Future<String> exportDatabaseCopy({required HiveHelper dbHelper}) async {
    List<Map<String, dynamic>> Pacientes = List<Map<String, dynamic>>.from(
        await getAllPacientes(repository: PacienteRepository(dbHelper)));
    if (Pacientes.isEmpty) {
      return "";
    }
    return Pacientes.toString();
  }

  Future<void> _exportData(BuildContext context) async {
    // Exibir popup de loading
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Exportando',
      text: 'Aguarde enquanto os dados estão sendo exportados...',
      barrierDismissible: false,
    );

    try {
      // Antes de exportar, calcular quantos estavam atualizados
      final repo = PacienteRepository(dbHelper);
      final PacientesAntes = await getAllPacientes(repository: repo);
      final totalCadastrados = PacientesAntes.length;
      final totalAtualizadosAntes =
          PacientesAntes.where((r) => r.atualizado == true).length;

      // Chamar a função real de exportação e verificar o status
      final exportResult = await exportDatabase(dbHelper: dbHelper);
      final int statusCode = exportResult['status'] ?? 500;
      final int totalSincronizadosAgora = exportResult['sincronizados'] ?? 0;

      // Fechar o popup de loading
      Navigator.of(context).pop();

      // Após exportar, atualizar lista
      final PacientesDepois = await getAllPacientes(repository: repo);
      final totalSincronizados =
          PacientesDepois.where((r) => r.atualizado == false).length;
      if (statusCode == 404) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Nenhum Paciente cadastrado',
          text: 'Não há Pacientes cadastrados neste dispositivo.',
        );
      } else if (statusCode == 403) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Acesso negado',
          text:
              'A senha fornecida está incorreta. Verifique e tente novamente.',
        );
      } else if (statusCode == 400) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Erro nos dados',
          text:
              'Os dados parecem estar vazios ou corrompidos. Verifique e tente exportar novamente.',
        );
      } else if (statusCode == 201) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Exportação concluída',
          widget: Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text(
              'Total: $totalCadastrados\n'
              'Já sincronizados: $totalSincronizados\n'
              'Sincronizados agora: $totalSincronizadosAgora\n'
              'Atualizados/inclusos: $totalAtualizadosAntes',
              textAlign: TextAlign.left,
            ),
          ),
        );
      } else if (statusCode == 500) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Erro no servidor',
          text:
              'Ocorreu um erro interno no servidor. Tente novamente mais tarde.',
        );
      } else {
        // Exibir popup de erro para outros status de erro desconhecidos
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Erro desconhecido',
          text:
              'Houve um erro inesperado ao exportar os dados. Código: $statusCode',
        );
      }
    } catch (error) {
      // Fechar o popup de loading
      Navigator.of(context).pop();

      // Exibir popup de erro
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Erro na exportação',
        text: 'Houve um erro ao exportar os dados. Tente novamente.',
      );
    }
  }

  // Função para exportar os dados em CSV e baixar
  Future<void> _downloadCsv(BuildContext context) async {
    try {
      final repo = PacienteRepository(dbHelper);
      final csvPath = await repo.exportToCsvFile();
      await Share.shareXFiles([XFile(csvPath, mimeType: 'text/csv')],
          subject: 'Exportação de Pacientes',
          text: 'Segue o arquivo CSV exportado dos Pacientes.');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'CSV gerado!',
        text: 'Arquivo compartilhado com sucesso!',
      );
    } catch (error, stack) {
      print('Erro ao gerar CSV:');
      print(error);
      print(stack);
      final msg =
          error.toString().contains('Nenhum Paciente encontrado para exportar.')
              ? 'Nenhum Paciente cadastrado para exportar.'
              : 'Ocorreu um erro ao gerar o CSV. Tente novamente.\n$error';
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Erro',
        text: msg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sMaxwidth = MediaQuery.of(context).size.width;
    double margem = 60.0;

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Column(children: [
              Navbar(sMaxwidth),
              SizedBox(
                width: sMaxwidth - margem,
                child: Column(
                  children: [
                    BuildTextSection(
                      title: loading ? "Carregando dados" : "Configuração",
                      text: loading ? "" : rodapeTexto,
                    ),
                    const SizedBox(height: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loading
                            ? Container()
                            : ElevatedButtonCustom(
                                maxWidth: sMaxwidth,
                                onPressed: () {
                                  Navigator.of(context).push(
                                      SlideTransitionPage(
                                          page: PageEditeUser()));
                                },
                                text: "Editar cadastro"),
                        SizedBox(height: 15),
                        loading
                            ? Container()
                            : ElevatedButtonCustom(
                                maxWidth: sMaxwidth,
                                onPressed: () {
                                  _showConfirmExportDialog(context);
                                },
                                text: "Exportar banco de dados"),
                        SizedBox(height: 15),
                        loading
                            ? Container()
                            : ElevatedButtonCustom(
                                maxWidth: sMaxwidth,
                                onPressed: () {
                                  _downloadCsv(context);
                                },
                                text: "Baixar dados em CSV"),
                        !loading ? Container() : CircularProgressIndicator(),
                        const SizedBox(height: 100),
                      ],
                    )
                  ],
                ),
              )
            ]))));
  }
}
