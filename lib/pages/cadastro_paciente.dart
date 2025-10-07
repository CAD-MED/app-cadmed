import 'package:Cad_Med/components/selectiondropdown.dart';
import 'package:Cad_Med/components/elevatedbuttoncustom.dart';
import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/components/textfieldCustom.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPageRemove.dart';
import 'package:Cad_Med/messageAlerts/alerts.dart';
import 'package:Cad_Med/models/paciente.model.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';
import 'package:Cad_Med/services/data_service.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:Cad_Med/services/paciente_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PageCadastrar extends StatefulWidget {
  const PageCadastrar({super.key});
  final String rodapeTexto =
      "Para oferecer uma experiência personalizada, precisamos coletar algumas informações adicionais sobre sua saúde. Preencha os campos abaixo:";

  @override
  State<PageCadastrar> createState() => _PageCadastrarState();
}

class _PageCadastrarState extends State<PageCadastrar> {
  final Uuid uuidGen = Uuid();
  final HiveHelper dbHelper = HiveHelper();
  late final PacienteRepository pacienteRepository;
  @override
  void initState() {
    super.initState();
    pacienteRepository = PacienteRepository(dbHelper);
  }
  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerAge = TextEditingController();
  TextEditingController controllerSelectGen = TextEditingController();
  TextEditingController controllerPatologia = TextEditingController();
  List<String> lista_de_patologias = patologiasMaisVistas;
  bool visibleField = false;

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
                          title: "Coleta de dados", text: widget.rodapeTexto),
                      const SizedBox(height: 15),
                      TextfieldCustom(
                          keyboardType: TextInputType.name,
                          title: "Nome completo",
                          hintText: "Nome completo",
                          controller: controllerTitle,
                          icon: Icons.account_box_outlined),
                      // const SizedBox(height: 15),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                              width: 200,
                              child: TextfieldCustom(
                                  keyboardType: TextInputType.number,
                                  isNumeric: true,
                                  title: "Idade",
                                  hintText: "Idade",
                                  controller: controllerAge,
                                  icon: Icons.badge))),
                      // const SizedBox(height: 15),
                      SelectionDropdown(
                          width: sMaxwidth - margem,
                          title: "Sexo",
                          icon: Icons.wc,
                          hintText: "o gênero",
                          controller: controllerSelectGen,
                          items: ['Selecione', 'Masculino', 'Feminino'],
                          selectedValue: 'Selecione', // Valor inicial
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
                          selectedValue: 'Selecione', // Valor inicial
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
                          text: "Cadastrar",
                          onPressed: () async {
                            if (controllerTitle.text.isEmpty ||
                                controllerAge.text.isEmpty ||
                                controllerSelectGen.text.isEmpty ||
                                controllerPatologia.text.isEmpty ||
                                controllerPatologia.text == "Selecione" ||
                                controllerSelectGen.text == "Selecione") {
                              alertFailField(context);
                            } else {
                              alertSucess(context);
                              final paciente = PacienteModel(
                                  uuid: uuidGen.v4(),
                                  nome: controllerTitle.text,
                                  idade: int.parse(controllerAge.text),
                                  sexo: controllerSelectGen.text,
                                  patologia: controllerPatologia.text);
                                  
                              await addPaciente(
                                  repository: pacienteRepository,
                                  paciente: paciente);
                              navigateAndRemoveUntil(context, PageInicio());
                            }
                          }),
                      const SizedBox(height: 100),
                    ]))
              ])
            ]))));
  }
}
