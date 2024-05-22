import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CustomVideoCarousel extends StatefulWidget {
  const CustomVideoCarousel({Key? key}) : super(key: key);

  @override
  _CustomVideoCarouselState createState() => _CustomVideoCarouselState();
}

class _CustomVideoCarouselState extends State<CustomVideoCarousel> {
  final List<String> videoIds = [
    'MF7reW-hkJE',
    'TZEzK9q9Feo',
  ];

  final List<String> articleTitles = [
    'Title 1',
    'Title 2',
  ];

  final List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var videoId in videoIds) {
      _controllers.add(
        YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          aspectRatio: 2.0,
          autoPlay: false,
          enlargeCenterPage: true,
        ),
        itemCount: videoIds.length,
        itemBuilder: (context, index, realIndex) {
          final controller = _controllers[index];
          return Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              // onTap: () {
              //   navigateToRoute(context, 'https://youtu.be/' + videoIds[index]);
              // },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio:
                          16 / 9, // Ensure the aspect ratio matches the video
                      child: YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: true,
                        onReady: () {
                          setState(() {
                            controller.play();
                          });
                        },
                        onEnded: (YoutubeMetaData metaData) {
                          controller.seekTo(Duration.zero);
                          controller.pause();
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 8),
                        // child: Text(
                        //   // articleTitles[index],
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //     fontSize: MediaQuery.of(context).size.width * 0.05,
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SafeWebView extends StatelessWidget {
  final String url;

  const SafeWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement the webview here, this is just a placeholder
    return Scaffold(
      appBar: AppBar(title: Text("WebView")),
      body: Center(child: Text("WebView for $url")),
    );
  }
}
