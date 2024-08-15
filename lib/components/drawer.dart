import 'package:chat/pages/settings.dart';
import 'package:flutter/material.dart';
import '../services/auth/authService.dart';


class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(){
    final authservice = AuthService();
    authservice.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(Icons.message,
                    color: Theme.of(context).colorScheme.primary,
                    size: 75,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  title: Text("H O M E"),
                  leading: Icon(Icons.home),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  title: Text("S E T T I N G"),
                  leading: Icon(Icons.settings),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(),));
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0,bottom: 50),
            child: ListTile(
              title: Text("L O G O U T"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),

    );
  }
}
