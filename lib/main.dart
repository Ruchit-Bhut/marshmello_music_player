// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:marshmello_music_player/home_page.dart';
import 'package:marshmello_music_player/provider/fav_song_model.dart';
import 'package:marshmello_music_player/provider/song_model_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SongModelProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FavSongProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
