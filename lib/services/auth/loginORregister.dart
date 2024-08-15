import 'package:chat/pages/login.dart';
import 'package:chat/pages/register.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initial state
  bool loginPage = true;

  void toogle(){
    setState(() {
      loginPage = !loginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(loginPage){
      return Login(onTap: toogle,);
    }else{
      return Register(onTap: toogle,);
    }
  }
}
