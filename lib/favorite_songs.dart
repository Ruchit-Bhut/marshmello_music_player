import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marshmello_music_player/play_screen.dart';
import 'package:marshmello_music_player/provider/fav_song_model.dart';
import 'package:marshmello_music_player/provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class FavoriteSongs extends StatefulWidget {
  const FavoriteSongs({
    required this.songs,
    super.key,
  });

  final List<SongModel> songs;
  @override
  State<FavoriteSongs> createState() => _FavoriteSongsState();
}

class _FavoriteSongsState extends State<FavoriteSongs> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();


  Future<void> playSong(String? uri) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      await _audioPlayer.play();
    } on Exception {
      stdout.write('Error parsing song');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
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
              image: AssetImage('assets/icons/ThreeDot.png'),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
        backgroundColor: const Color(0xff100919),
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.chevron_left,
            size: 35,
          ),
        ),
        title: const Text(
          'Your Favourite Song List',
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: DecoratedBox(
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
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              itemCount: widget.songs.length,
              itemBuilder: (context, index) {
                return context
                        .watch<FavSongProvider>()
                        .isFav(widget.songs.elementAt(index).id)
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white10,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: ListTile(
                          onTap: () {
                            context
                                .read<SongModelProvider>()
                                .setId(widget.songs.length);
                            Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (context) => PlayMusicScreen(
                                  songModel: widget.songs.elementAt(index),
                                  audioPlayer: _audioPlayer,
                                ),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: QueryArtworkWidget(
                              id: widget.songs.elementAt(index).id,
                              type: ArtworkType.AUDIO,
                              artworkHeight: 50,
                              artworkWidth: 50,
                              nullArtworkWidget: Image.asset(
                                'assets/icons/music.png',
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                          title: Text(
                            widget.songs.elementAt(index).displayNameWOExt,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${widget.songs.elementAt(index).artist}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          trailing: InkWell(
                            onTap: () {
                              if (context.read<FavSongProvider>().isFav(
                                    widget.songs.elementAt(index).id,
                                  )) {
                                context
                                    .read<FavSongProvider>()
                                    .remFav(widget.songs.elementAt(index).id);
                              } else {
                                context
                                    .read<FavSongProvider>()
                                    .addToFav(widget.songs.elementAt(index).id);
                              }
                            },
                            child: context
                                    .watch<FavSongProvider>()
                                    .isFav(widget.songs.elementAt(index).id)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.pink,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.favorite_outline_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
