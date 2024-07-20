import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.urls, required this.releaseId, required this.episode, required this.releaseName});

  final List<String> urls;
  final int releaseId;
  final int episode;
  final String releaseName;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  int quality = 0;
  int playFrom = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void savePLayFrom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('${widget.releaseId}ep${widget.episode}playFrom', playFrom);
  }

  void _initializePlayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? playFromLoaded = prefs.getInt('${widget.releaseId}ep${widget.episode}playFrom');
    int? defaultQuality = prefs.getInt('defaultQuality');
    if (playFromLoaded != null) {
      playFrom = playFromLoaded;
    }
    if (defaultQuality != null) {
      quality = defaultQuality;
    }
    videoPlayerController =
        VideoPlayerController.network(widget.urls[quality]);
    await videoPlayerController!.initialize();
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        startAt: Duration(seconds: playFrom),
        fullScreenByDefault: false,
        looping: false,
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      var size = MediaQuery.of(context).size;
                      return SizedBox(
                        width: size.width > 400 ? size.width * 0.9 : size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: quality == 0 ? Text('1080p', style: TextStyle(color: Theme.of(context).primaryColor),) : const Text('1080p'),
                              onTap: () {
                                setState(() {
                                  quality = 0;
                                  chewieController!.pause();
                                  _initializePlayer();
                                  Navigator.pop(context);
                                });
                              },
                            ),
                            ListTile(
                              title: quality == 1 ? Text('720p', style: TextStyle(color: Theme.of(context).primaryColor),) : const Text('720p'),
                              onTap: () {
                                setState(() {
                                  quality = 1;
                                  chewieController!.pause();
                                  _initializePlayer();
                                  Navigator.pop(context);
                                });
                              },
                            ),
                            ListTile(
                              title: quality == 2 ? Text('480p', style: TextStyle(color: Theme.of(context).primaryColor),) : const Text('480p'),
                              onTap: () {
                                setState(() {
                                  quality = 2;
                                  chewieController!.pause();
                                  _initializePlayer();
                                  Navigator.pop(context);
                                });
                              },
                            )
                          ],
                        ),
                      );
                    }
                  );
                },
                title: 'Качество воспроизведения',
                iconData: Icons.high_quality_outlined
            ),
          ];
        },
      optionsTranslation: OptionsTranslation(playbackSpeedButtonText: 'Скорость воспроизведения', cancelButtonText: 'Закрыть')
    );
    videoPlayerController!.addListener(() {
      playFrom = videoPlayerController!.value.position.inSeconds;
      savePLayFrom();
    });
    setState(() {});
  }

  @override
  void dispose() {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    if (chewieController != null) {
      chewieController!.dispose();
    }
    savePLayFrom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BetterLibriaPLayer β'),
      ),
      body: chewieController != null
          ? ListView(
        children: [
          Card(
            child: SizedBox(
              width: size.width - 10,
              height: size.height * 0.5,
              child: Chewie(controller: chewieController!),
            ),
          ),
          Card(
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5), child: Text('${widget.releaseName}, Эпизод ${widget.episode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
          )
        ],
      )
          : const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Загружаем видео', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          CircularProgressIndicator()
        ],
      )),
    );
  }
}
