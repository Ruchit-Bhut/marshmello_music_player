import 'package:flutter/material.dart';
import 'package:marshmello_music_player/show_internal_music.dart';

class FavoriteSongs extends StatefulWidget {
  const FavoriteSongs({Key? key}) : super(key: key);

  @override
  State<FavoriteSongs> createState() => _FavoriteSongsState();
}

class _FavoriteSongsState extends State<FavoriteSongs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        actions: const [
          SizedBox(
            width: 6,
            child: Image(
              image: AssetImage("assets/icons/ThreeDot.png"),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Color(0xff100919),
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ShowInternalMusic(),
              ),
            );
          },
          child: const Icon(
            Icons.chevron_left,
            size: 35,
          ),
        ),
        title: const Text(
          "Your Favourit Song List",
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff100919),
                Color(0xff110c1d),
                Color(0xff1b0c2b),
                Color(0xff30164e),
                Color(0xff3b1a60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}