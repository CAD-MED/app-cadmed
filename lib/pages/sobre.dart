import 'package:Cad_Med/components/navbar.dart';
import 'package:Cad_Med/components/buildtextsection.dart';
import 'package:Cad_Med/config/config.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:flutter/material.dart';

class PageSobre extends StatefulWidget {
  PageSobre({super.key});
  final String rodapeTexto = ConfigData().rodapeTexto;
  State<PageSobre> createState() => _PageSobreState();
}

class _PageSobreState extends State<PageSobre> {
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
                      BuildTextSection(title: "Sobre", text: widget.rodapeTexto),
                      BuildTextSection(
                          image: "images/banner1.png",
                          title: "Nossa motivação",
                          text: ConfigData()
                              .rodapeTextoSecond), // Texto do parágrafo 1
                      const SizedBox(height: 15),
                      sectionLogoExtensao(),
                      const SizedBox(height: 15),
                      BuildTextSection(title: "Equipe", text: ConfigData().equipe),
                      const SizedBox(height: 100),
                    ]))
              ])
            ]))));
  }
}
