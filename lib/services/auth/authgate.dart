import 'package:chat/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loginORregister.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          //user logged in
          if(snapshot.hasData){
            return Home();
          }

          //not logged in
          else{
            return LoginOrRegister();
          }
        },
      )
    );
  }
}
