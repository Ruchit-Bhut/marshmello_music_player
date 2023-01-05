// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marshmello_music_player/favorite_songs.dart';
import 'package:marshmello_music_player/play_screen.dart';
import 'package:marshmello_music_player/provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class ShowInternalMusic extends StatefulWidget {
  const ShowInternalMusic({super.key});

  @override
  State<ShowInternalMusic> createState() => _ShowInternalMusicState();
}

class _ShowInternalMusicState extends State<ShowInternalMusic> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchingController = TextEditingController();

  bool isFavorite = false;

  String isSearching = '';

  playSong(String? uri) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      _audioPlayer.play();
    } on Exception {
      stdout.write('Error parsing song');
    }
  }

  final OnAudioQuery audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    if (!kIsWeb) {
      final permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<SongModel>>(
        future: audioQuery.querySongs(
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
            return const Text('No Song Found');
          }
          return DecoratedBox(
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
                          controller: _searchingController,
                          onChanged: (value) {
                            setState(() {
                              isSearching = value;
                            });
                          },
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            fillColor: isSearching == ''
                                ? Colors.white10
                                : Color(0xff30164e),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Search Song ',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(15),
                              width: 18,
                              child: Image.asset('assets/icons/search.png'),
                            ),
                            suffixIcon: isSearching == ''
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      setState(_searchingController.clear);
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (context) => const FavoriteSongs(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/icons/lover.png',
                            height: 25,
                            width: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Your Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      // Text(
                      //   'See All',
                      //   style: TextStyle(color: Colors.grey, fontSize: 16),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        if (item.data![index].displayName
                            .toLowerCase()
                            .startsWith(isSearching.toLowerCase())) {
                          return Container(
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
                                    .setId(item.data![index].id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (context) => PlayMusicScreen(
                                      songModel: item.data![index],
                                      audioPlayer: _audioPlayer,
                                    ),
                                  ),
                                );
                                // playSong(item.data![index].uri);
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: QueryArtworkWidget(
                                  id: item.data![index].id,
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
                                item.data![index].displayNameWOExt,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${item.data![index].artist}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              trailing: InkWell(
                                onTap: () {},
                                child: isFavorite == true
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        Icons.favorite_outline_rounded,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          );
                        }
                        if (_searchingController.text == '') {
                          return Container(
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
                                    .setId(item.data![index].id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (context) => PlayMusicScreen(
                                      songModel: item.data![index],
                                      audioPlayer: _audioPlayer,
                                    ),
                                  ),
                                );
                                // playSong(item.data![index].uri);
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: QueryArtworkWidget(
                                  id: item.data![index].id,
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
                                item.data![index].displayNameWOExt,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${item.data![index].artist}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              trailing: InkWell(
                                onTap: () {},
                                child: isFavorite == true
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        Icons.favorite_outline_rounded,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//
// Container(
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(12),
// color: Colors.white10,
// ),
// margin: const EdgeInsets.symmetric(
// horizontal: 10,
// vertical: 4,
// ),
// child: ListTile(
// onTap: () {
// context
//     .read<SongModelProvider>()
//     .setId(item.data![index].id);
// Navigator.push(
// context,
// MaterialPageRoute<dynamic>(
// builder: (context) => PlayMusicScreen(
// songModel: item.data![index],
// audioPlayer: _audioPlayer,
// ),
// ),
// );
// // playSong(item.data![index].uri);
// },
// leading: ClipRRect(
// borderRadius: BorderRadius.circular(10),
// child: QueryArtworkWidget(
// id: item.data![index].id,
// type: ArtworkType.AUDIO,
// artworkHeight: 50,
// artworkWidth: 50,
// nullArtworkWidget: Image.asset(
// 'assets/icons/music.png',
// height: 50,
// width: 50,
// ),
// ),
// ),
// title: Text(
// item.data![index].displayNameWOExt,
// style: const TextStyle(
// fontSize: 15,
// color: Colors.white,
// ),
// ),
// subtitle: Text(
// '${item.data![index].artist}',
// style: const TextStyle(
// fontSize: 13,
// color: Colors.white60,
// ),
// ),
// trailing: InkWell(
// onTap: () {
//
// },
// child: isFavorite == true
// ? Icon(
// Icons.favorite,
// color: Colors.white,
// )
// : Icon(
// Icons.favorite_outline_rounded,
// color: Colors.white,
// ),
// ),
// ),
// );
