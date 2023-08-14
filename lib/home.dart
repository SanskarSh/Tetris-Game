import 'package:flutter/material.dart';
import 'package:tetris_game/tetris/board.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [
          SizedBox(height: 25),
          Text(
            "For Introverts",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 15,
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
            height: 10,
          ),
          buildTile(
            context,
            'Tetris',
            GameBoard(),
            "The Ultimate Test of Your Spatial Skills \nWhere clearing lines is the only therapy for the chaos you've created!",
          ),
          Text(
            "For Ambiverts",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 15,
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
            height: 10,
          ),
        ],
      ),
    );
  }

  Padding buildTile(
      BuildContext context, String title, Widget NextPage, String subTitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.black,
        subtitle: Text(
          subTitle,
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  image: AssetImage('assets/image/tetris.png'))),
        ),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => NextPage)),
      ),
    );
  }
}
