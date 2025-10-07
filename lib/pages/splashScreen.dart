import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/effects/SlideTransitionPage.dart';
import 'package:Cad_Med/pages/inicio.dart';
import 'package:Cad_Med/pages/inicializacao.dart';
import 'package:Cad_Med/repository/user_repository.dart';
import 'package:Cad_Med/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  HiveHelper dbHelper = HiveHelper();
  List userData = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();  

  getAllLogin(repository: UserRepository(dbHelper)).then((data) {
      setState(() {
        userData = data;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (userData.isNotEmpty) {
        Navigator.of(context)
            .pushReplacement(SlideTransitionPage(page: const PageInicio()));
      } else {
        Navigator.of(context)
            .pushReplacement(SlideTransitionPage(page: const PageInit()));
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (await _hasStoragePermission() == false) {
      await Permission.storage.request();
    }
  }

  Future<bool> _hasStoragePermission() async {
    var status = await Permission.storage.status;
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/walpaper.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: largura - 100,
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(.7)),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          Image(image: AssetImage("images/logoFrame.png")),
                          SizedBox(height: 40),
                          Center(
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))),
                          SizedBox(height: 50),
                        ])),
                const SizedBox(height: 20),
                Container(
                  width: largura - 100,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(.7)),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      sectionLogoExtensao(),
                      const SizedBox(height: 30),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
