import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/outlinebuttoncustom.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPage.dart';
import 'package:Cad_Med/pages/cadastro_paciente.dart';
import 'package:Cad_Med/pages/configuracao.dart';
import 'package:Cad_Med/pages/sobre.dart';
import 'package:Cad_Med/pages/visualiza_cadastro.dart';
import 'package:Cad_Med/repository/user_repository.dart';
import 'package:Cad_Med/services/user_service.dart';
import 'package:flutter/material.dart';

class PageInicio extends StatefulWidget {
  const PageInicio({super.key});

  @override
  State<PageInicio> createState() => _PageInicioState();
}

class _PageInicioState extends State<PageInicio> {
  late UserRepository userRepository;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    final hiveHelper = HiveHelper();
    userRepository = UserRepository(hiveHelper);
    getFirstUser(repository: userRepository).then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  Widget build(BuildContext context) {
    double sMaxwidth = MediaQuery.of(context).size.width;
    double margem = 60.0;
    double buttonSize = ((sMaxwidth - margem) / 2) - 25;
    if (sMaxwidth > 500) {
      buttonSize = ((400 - margem) / 2) - 25;
    }
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Column(children: [
              Navbar(sMaxwidth),
              Container(
                width: sMaxwidth > 500 ? 400 : (sMaxwidth - margem),
                child: Column(
                  children: [
                    userData != null
                        ? BuildTextSection(
                            scale: 1.2,
                            title: "Inicio",
                            text: "Seja bem vindo(a), ${userData!['nome']}",
                            color: const Color(0xff558C54))
                        : Container(),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlineButtonCustom(
                                size: buttonSize,
                                onTap: () {
                                  Navigator.of(context).push(
                                      SlideTransitionPage(
                                          page: PageCadastrar()));
                                },
                                title: "Cadastrar",
                                icon: Icons.group),
                            OutlineButtonCustom(
                                size: buttonSize,
                                onTap: () {
                                  Navigator.of(context).push(
                                      SlideTransitionPage(
                                          page: PageVisualizarCadastro()));
                                },
                                title: "Visualizar",
                                icon: Icons.dashboard),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlineButtonCustom(
                                  size: buttonSize,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        SlideTransitionPage(
                                            page: Pagesettings()));
                                  },
                                  title: "Configurar",
                                  icon: Icons.settings),
                              OutlineButtonCustom(
                                  size: buttonSize,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        SlideTransitionPage(page: PageSobre()));
                                  },
                                  title: "Sobre",
                                  icon: Icons.view_cozy)
                            ]),
                        const SizedBox(height: 40),
                        sectionLogoExtensao(),
                        const SizedBox(height: 100),
                      ],
                    )
                  ],
                ),
              )
            ]))));
  }
}

Widget sectionLogoExtensao() {
  return SizedBox(
      child: Column(children: [
    Text("Projeto de extensão",
        style: TextStyle(fontSize: 20, color: Colors.green[800])),
    const SizedBox(height: 5),
    const Image(image: AssetImage("images/logoUnama.png")),
    const SizedBox(height: 5),
    Text("Faculdade Unama",
        style: TextStyle(fontSize: 20, color: Colors.green[800])),
  ]));
}