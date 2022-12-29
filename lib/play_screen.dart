import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marshmello_music_player/provider/song_model_provider.dart';
import 'package:marshmello_music_player/show_internal_music.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class PlayMusicScreen extends StatefulWidget {
  const PlayMusicScreen(
      {Key? key, required this.songModel, required this.audioPlayer})
      : super(key: key);

  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<PlayMusicScreen> createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {

  Duration _duration = const Duration();
  Duration _position = const Duration();

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    playSong();
  }
  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.songModel.uri!),
        ),
      );
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      stdout.write("Cannot Parse Song");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
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
              image: AssetImage("assets/icons/ThreeDot.png"),
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
        title: Text(
          widget.songModel.displayNameWOExt,
          style: const TextStyle(fontSize: 22),
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
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const ArtWorkWidget(),
                // Container(
                //   height: 300,
                //   width: 300,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     color: Colors.white12,
                //   ),
                // ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.songModel.displayNameWOExt,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.favorite_outline_rounded,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Text(
                        widget.songModel.artist.toString() == "<unknown>"
                            ? "Unknown Artist"
                            : widget.songModel.artist.toString(),
                        maxLines: 1,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Text(
                            _position.toString().split(".")[0],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          Expanded(
                            child: Slider(
                              value: _position.inSeconds.toDouble(),
                              min: const Duration(microseconds: 0)
                                  .inSeconds
                                  .toDouble(),
                              max: _duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                setState(
                                      () {
                                    changeToSeconds(value.toInt());
                                    value = value;
                                  },
                                );
                              },
                            ),
                          ),
                          Text(
                            _duration.toString().split(".")[0],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 45,
                          color: Colors.white,
                          onPressed: () {},
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(
                          iconSize: 70,
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              if (_isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon: Icon(_isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(
                          iconSize: 45,
                          color: Colors.white,
                          onPressed: () {},
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    Key? key,
    // required this.widget,
  }) : super(key: key);

  // final PlayMusicScreen widget;

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 300,
      artworkWidth: 300,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: Image.asset(
        "assets/icons/music.png",
        height: 300,
        width: 300,
      ),
    );
  }
}

