import 'package:flutter/material.dart';

class DeleteAcc extends StatelessWidget {
  const DeleteAcc({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About App"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                     Text("sfsdgfsdgs"),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
