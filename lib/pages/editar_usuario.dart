import 'package:Cad_Med/components/elevatedbuttoncustom.dart';
import 'package:Cad_Med/components/navbarcustom.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/components/textfieldCustom.dart';
import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPageRemove.dart';
import 'package:Cad_Med/messageAlerts/alerts.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:Cad_Med/repository/user_repository.dart';
import 'package:Cad_Med/services/user_service.dart';
import 'package:flutter/material.dart';

class PageEditeUser extends StatefulWidget {
  const PageEditeUser({super.key});

  @override
  State<PageEditeUser> createState() => _PageEditeUserState();
}

class _PageEditeUserState extends State<PageEditeUser> {
  final String rodapeTexto =
      "Bem-vindo ao CadMed! Para começar a sua jornada, precisamos de algumas informações básicas. Preencha os campos abaixo para criar seu perfil:";

  late UserRepository userRepository;
  // Controladores dos campos de texto
  TextEditingController controllerNome = TextEditingController();
  TextEditingController controllerPosto = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  bool loading = false;
  int? userKey;

  @override
  void initState() {
    super.initState();
    final hiveHelper = HiveHelper();
    userRepository = UserRepository(hiveHelper);
    getFirstUser(repository: userRepository).then((data) {
      if (data != null) {
        setState(() {
          controllerNome.text = data["nome"];
          controllerPosto.text = data["posto"];
          controllerSenha.text = data["senha"];
          userKey = data["key"];
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
              child: Column(
                children: [
                  NavbarCustom(sMaxwidth),  
                  SizedBox(
                      width: sMaxwidth - margem,
                      child: Column(children: [
                        BuildTextSection(
                            title: "Cadastro de usuario", text: rodapeTexto),
                        const SizedBox(height: 15),
                        TextfieldCustom(
                            enabled: false,
                            keyboardType: TextInputType.name,
                            title: "email",
                            hintText: "email",
                            controller: controllerNome,
                            icon: Icons.account_box_outlined),
                        TextfieldCustom(
                            keyboardType: TextInputType.text,
                            title: "posto de atendimento",
                            hintText: "posto",
                            controller: controllerPosto,
                            icon: Icons.domain),
                        TextfieldCustom(
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            title: "senha do banco de dados",
                            hintText: "senha",
                            controller: controllerSenha,
                            icon: Icons.key),
                        const SizedBox(height: 30),
                        loading
                            ? CircularProgressIndicator()
                            : ElevatedButtonCustom(
                                maxWidth: sMaxwidth,
                                text: "Atualizar cadastro",
                                onPressed: () async {
                                  // Verificando se todos os campos estão preenchidos corretamente
                                  if (controllerNome.text.isEmpty ||
                                      controllerPosto.text.isEmpty ||
                                      controllerSenha.text.isEmpty) {
                                    alertFailField(context);
                                  } else {
                                    alertSucessUpdate(context);
                                    // função para atualizar database
                                    setState(() {
                                      loading = true;
                                    });
                                    if (userKey != null) {
                                      await updateUser(
                                          repository: userRepository,
                                          id: userKey!,
                                          nome: controllerNome.text,
                                          posto: controllerPosto.text,
                                          senha: controllerSenha.text);
                                    }
                                    //

                                    navigateAndRemoveUntil(
                                        context, PageInicio());
                                  }
                                }),
                        const SizedBox(height: 100),
                      ])),
                ],
              ),
            )));
  }
}