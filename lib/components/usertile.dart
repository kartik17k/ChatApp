import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? ontap;
  const UserTile({super.key,required this.text,required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            //icons
            Icon(Icons.person),

            SizedBox(width: 10,),

            //user name
            Expanded(child: Text(text),),//expanded used for responsive
          ],
        ),
      ),
    );
  }
}
