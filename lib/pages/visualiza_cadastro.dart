import 'package:Cad_Med/components/cardUser.dart';
import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPage.dart';
import 'package:Cad_Med/models/paciente.model.dart';
import 'package:Cad_Med/pages/editar_paciente.dart';
import 'package:Cad_Med/repository/paciente_repository.dart';
import 'package:Cad_Med/services/paciente_service.dart';
import 'package:flutter/material.dart';

class PageVisualizarCadastro extends StatefulWidget {
  const PageVisualizarCadastro({super.key});
  final String rodapeTexto =
      "Bem-vindo à sua central! Aqui, você pode visualizar e analisar as informações de todos cadastrados de forma clara e acessível. ";

  @override
  State<PageVisualizarCadastro> createState() => _PageVisualizarCadastroState();
}

class _PageVisualizarCadastroState extends State<PageVisualizarCadastro> {
  bool isLoading = true;
  bool isEmptyData = false;
  List<PacienteModel> users = [];
  late PacienteRepository pacienteRepository;

  @override
  void initState() {
    super.initState();
    final hiveHelper = HiveHelper();
    pacienteRepository = PacienteRepository(hiveHelper);
    loadData();
  }

  void loadData() async {
    try {
      final allPacientes = await getAllPacientes(repository: pacienteRepository);
      if (allPacientes.isEmpty) {
        setState(() {
          isEmptyData = true;
          isLoading = false;  
        });
      } else {
        setState(() {
          users = allPacientes;
          isLoading = false;  
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double sMaxwidth = MediaQuery.of(context).size.width;
    double margem = 60.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())  
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Navbar(sMaxwidth),
                    Column(
                      children: [
                        SizedBox(
                          width: sMaxwidth - margem,
                          child: Column(
                            children: [
                              BuildTextSection(
                                title: "Visualizar dados",
                                text: widget.rodapeTexto,
                              ),
                              const SizedBox(height: 15),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: users.length,  
                                itemBuilder: (context, index) {
                                  var user = users[index];
                                  return cardUser(
                                    width: sMaxwidth,
                                    nome: user.nome,
                                    id: user.uuid,
                                    patologia: user.patologia,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        SlideTransitionPage(
                                          page: PageEditar(
                                            userUuid: user.uuid,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              isEmptyData
                                  ? Column(
                                      children: [
                                        SizedBox(height: 150),
                                        Center(
                                          child: Text("Nada ainda cadastrado"),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}