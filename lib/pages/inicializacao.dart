import 'package:Cad_Med/components/elevatedbuttoncustom.dart';
import 'package:Cad_Med/components/navbarcustom.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/components/textfieldCustom.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPage.dart';
import 'package:Cad_Med/messageAlerts/alerts.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:Cad_Med/repository/user_repository.dart';
import 'package:Cad_Med/services/user_service.dart';
import 'package:flutter/material.dart';

class PageInit extends StatefulWidget {
  const PageInit({super.key});

  @override
  State<PageInit> createState() => _PageInitState();
}

class _PageInitState extends State<PageInit> {
  final String rodapeTexto =
      "Bem-vindo ao CadMed! Para começar a sua jornada, precisamos de algumas informações básicas. Preencha os campos abaixo para criar seu perfil:";
  TextEditingController controllerNome = TextEditingController();
  TextEditingController controllerPosto = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  late UserRepository userRepository;

  @override
  void initState() {
    super.initState();
    final hiveHelper = HiveHelper();
    userRepository = UserRepository(hiveHelper);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
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
              NavbarCustom(sMaxwidth),
              Column(children: [
                SizedBox(
                    width: sMaxwidth - margem,
                    child: Column(children: [
                      BuildTextSection(
                          title: "Cadastro de Usuário", text: rodapeTexto),
                      const SizedBox(height: 15),
                      TextfieldCustom(
                          keyboardType: TextInputType.emailAddress,
                          title: "E-mail",
                          hintText: "Digite seu email",
                          controller: controllerEmail,
                          icon: Icons.email),
                      // const SizedBox(height: 15),
                      TextfieldCustom(
                          keyboardType: TextInputType.text,
                          title: "Posto de atendimento",
                          hintText: "Posto",
                          controller: controllerPosto,
                          icon: Icons.domain),
                      // const SizedBox(height: 15),
                      TextfieldCustom(
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          title: "Senha do banco de dados",
                          hintText: "Senha",
                          controller: controllerSenha,
                          icon: Icons.key),
                      const SizedBox(height: 30),
                      ElevatedButtonCustom(
                          maxWidth: sMaxwidth,
                          text: "Iniciar app",
                          onPressed: () async {
                            // verificando se todos os campos estão preenchidos corretamente
                            if (controllerEmail.text.isEmpty ||
                                controllerPosto.text.isEmpty ||
                                controllerSenha.text.isEmpty) {
                              alertFailField(context);
                            } else if (!isValidEmail(controllerEmail.text)) {
                              alertFailEmail(context);
                            } else {
                              alertSucess(context);
                              await addUser(
                                  repository: userRepository,
                                  nome: controllerEmail.text,
                                  posto: controllerPosto.text,
                                  senha: controllerSenha.text,
                                  servidor: 'https://api-cadmed.nextlab.cloud/');
                              Navigator.of(context).pushReplacement(
                                  SlideTransitionPage(page: PageInicio()));
                            }
                          }),
                      const SizedBox(height: 100),
                    ]))
              ])
            ]))));
  }
}