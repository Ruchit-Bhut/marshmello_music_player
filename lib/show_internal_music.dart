import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marshmello_music_player/favorite_songs.dart';
import 'package:marshmello_music_player/play_screen.dart';
import 'package:marshmello_music_player/provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ShowInternalMusic extends StatefulWidget {
  const ShowInternalMusic({Key? key}) : super(key: key);

  @override
  State<ShowInternalMusic> createState() => _ShowInternalMusicState();
}

class _ShowInternalMusicState extends State<ShowInternalMusic> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      _audioPlayer.play();
    } on Exception {
      stdout.write("Error parsing song");
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    Permission.storage.request();
  }

  final audioQuery = new OnAudioQuery();

  String isSearching = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        isSearching = value;
                      },
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        fillColor: Colors.white12,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        hintText: 'Search Song ',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 18),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(15),
                          width: 18,
                          child: Image.asset('assets/icons/search.png'),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteSongs(),
                          ),
                        );
                      },
                      child: Image.asset("assets/icons/lover.png",
                          height: 25, width: 25),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Your Songs",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: FutureBuilder<List<SongModel>>(
                  future: audioQuery.querySongs(
                    sortType: null,
                    orderType: OrderType.ASC_OR_SMALLER,
                    uriType: UriType.EXTERNAL,
                    ignoreCase: true,
                  ),
                  builder: (context, item) {
                    if (item.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (item.data!.isEmpty) {
                      return const Text("No Song");
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          context
                              .read<SongModelProvider>()
                              .setId(item.data![index].id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayMusicScreen(
                                songModel: item.data![index],
                                audioPlayer: _audioPlayer,
                              ),
                            ),
                          );
                          playSong(item.data![index].uri);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black26,
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: ListTile(
                            onTap: (){
                              context
                                  .read<SongModelProvider>()
                                  .setId(item.data![index].id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayMusicScreen(
                                    songModel: item.data![index],
                                    audioPlayer: _audioPlayer,
                                  ),
                                ),
                              );
                              playSong(item.data![index].uri);
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: QueryArtworkWidget(
                                id: item.data![index].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Image.asset(
                                  "assets/icons/music.png",
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ),
                            title: Text(
                              item.data![index].displayNameWOExt,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "${item.data![index].artist}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FavoriteSongs(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.favorite_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      itemCount: item.data!.length,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
