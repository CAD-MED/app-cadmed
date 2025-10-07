import 'package:Cad_Med/components/selectiondropdown.dart';
import 'package:Cad_Med/components/elevatedbuttoncustom.dart';
import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/components/textfieldCustom.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPageRemove.dart';
import 'package:Cad_Med/messageAlerts/alerts.dart';
import 'package:Cad_Med/models/paciente.model.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';
import 'package:Cad_Med/services/data_service.dart';
import 'package:Cad_Med/services/paciente_service.dart';
import 'package:flutter/material.dart';

class PageEditar extends StatefulWidget {
  final String userUuid; // ID do usuário para busca

  const PageEditar({super.key, required this.userUuid});

  @override
  State<PageEditar> createState() => _PageEditarState();
}

class _PageEditarState extends State<PageEditar> {
  late PacienteRepository pacienteRepository;
  late TextEditingController controllerTitle;
  late TextEditingController controllerAge;
  late TextEditingController controllerSelectGen;
  late TextEditingController controllerPatologia;
  PacienteModel? _paciente;

  List<String> lista_de_patologias = patologiasMaisVistas;
  bool visibleField = false;

  @override
  void initState() {
    super.initState();
    final hiveHelper = HiveHelper();
    pacienteRepository = PacienteRepository(hiveHelper);

    controllerTitle = TextEditingController();
    controllerAge = TextEditingController();
    controllerSelectGen = TextEditingController();
    controllerPatologia = TextEditingController();

    getPacienteByUuid(repository: pacienteRepository, uuid: widget.userUuid).then((paciente) {
      if (paciente != null) {
        setState(() {
          _paciente = paciente;
          controllerTitle.text = paciente.nome;
          controllerAge.text = paciente.idade.toString();
          controllerSelectGen.text = paciente.sexo;
          controllerPatologia.text = paciente.patologia;

          if (paciente.patologia == "Outros") {
            visibleField = true;
          }
        });
      }
    });
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
              Column(children: [
                SizedBox(
                    width: sMaxwidth - margem,
                    child: Column(children: [
                      BuildTextSection(
                          title: "Atualizar dados",
                          text: "Preencha os campos abaixo"),
                      const SizedBox(height: 15),
                      TextfieldCustom(
                          keyboardType: TextInputType.name,
                          title: "Nome completo",
                          hintText: "Nome completo",
                          controller: controllerTitle,
                          icon: Icons.account_box_outlined),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                              width: 200,
                              child: TextfieldCustom(
                                  keyboardType: TextInputType.number,
                                  title: "Idade",
                                  hintText: "Idade",
                                  controller: controllerAge,
                                  icon: Icons.badge))),
                      SelectionDropdown(
                          width: sMaxwidth - margem,
                          title: "Sexo",
                          icon: Icons.wc,
                          hintText: "o gênero",
                          controller: controllerSelectGen,
                          items: ['Selecione', 'Masculino', 'Feminino'],
                          selectedValue:
                              controllerSelectGen.text,  
                          onChanged: (newValue) {
                            controllerSelectGen.text = newValue ?? '';
                          }),
                      const SizedBox(height: 15),
                      SelectionDropdown(
                          width: sMaxwidth - margem,
                          title: "Patologia",
                          icon: Icons.menu,
                          hintText: "Patologia",
                          controller: controllerPatologia,
                          items: lista_de_patologias,
                          selectedValue:
                              controllerPatologia.text,  
                          onChanged: (newValue) {
                            if (newValue == "Outros") {
                              setState(() {
                                visibleField = true;
                                controllerPatologia.text = "";
                              });
                            } else {
                              setState(() {
                                visibleField = false;
                              });
                              controllerPatologia.text = newValue ?? '';
                            }
                          }),
                      visibleField ? const SizedBox(height: 15) : Container(),
                      visibleField
                          ? TextfieldCustom(
                              keyboardType: TextInputType.name,
                              title: "Adicione a patologia",
                              hintText: "Patologia",
                              controller: controllerPatologia,
                              icon: Icons.menu)
                          : Container(),
                      const SizedBox(height: 50),
                      ElevatedButtonCustom(
                          maxWidth: sMaxwidth,
                          text: "Atualizar",
                          onPressed: () async {
                            if (controllerTitle.text.isEmpty ||
                                controllerAge.text.isEmpty ||
                                controllerSelectGen.text.isEmpty ||
                                controllerPatologia.text.isEmpty ||
                                controllerPatologia.text == "Selecione" ||
                                controllerSelectGen.text == "Selecione") {
                              alertFailField(context);
                            } else {
                              alertSucessUpdate(context);
                              if (_paciente != null) {
                                final updatedPaciente = PacienteModel(
                                  uuid: _paciente!.uuid,
                                  nome: controllerTitle.text,
                                  idade: int.parse(controllerAge.text),
                                  sexo: controllerSelectGen.text,
                                  patologia: controllerPatologia.text,
                                  atualizado: true,
                                  createdAt: _paciente!.createdAt,
                                  updatedAt: DateTime.now().toIso8601String(),
                                );
                                await updatePaciente(
                                    repository: pacienteRepository,
                                    uuid: widget.userUuid,
                                    Paciente: updatedPaciente);
                              }
                              // Process the update here
                              navigateAndRemoveUntil(context, PageInicio());
                            }
                          }),
                      SizedBox(height: 10),
                      ElevatedButtonCustom(
                          color: Colors.red,
                          maxWidth: sMaxwidth,
                          text: "Deletar",
                          onPressed: () async {
                            alertSucessDelete(context);
                            await deletePaciente(
                              repository: pacienteRepository,
                              uuid: widget.userUuid,
                            );
                            // Process the update here
                            navigateAndRemoveUntil(context, PageInicio());
                          }),
                      const SizedBox(height: 100),
                    ]))
              ])
            ]))));
  }
}