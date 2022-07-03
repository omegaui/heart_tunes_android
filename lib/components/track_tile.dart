
import 'package:flutter/material.dart';
import 'package:heart_tunes_android/io/app_data_manager.dart';
import 'package:heart_tunes_android/io/track_manager.dart';
import 'package:heart_tunes_android/screens/home_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../io/track_data.dart';

const int sensitivity = 8;

class TrackTile extends StatefulWidget{

  final Track track;

  const TrackTile({Key? key, required this.track}) : super(key: key);

  @override
  State<TrackTile> createState() => TrackTileState();
}

class TrackTileState extends State<TrackTile> {

  double completionPercentage = 0;
  double swipeCompletionPercentage = 0;
  bool swipingRight = false;
  bool swipingRightCompleted = false;
  bool implantedTrackListeners = false;

  @override
  void initState() {
    super.initState();
    if(!implantedTrackListeners){
      implantedTrackListeners = true;
      widget.track.onFavouriteToggleList.add((favourite) {
        rebuild();
      });
      widget.track.trackPlayerService.onPlayerStateChangedList.add((state) {
        rebuild();
      });
      widget.track.trackPlayerService.onPlayerCompleteList.add(() {
        rebuild();
      });
      widget.track.trackPlayerService.onPositionChangedList.add((event) async {
        completionPercentage = await widget.track.trackPlayerService.getCompletionPercentage();
        if(completionPercentage >= 0.0 && completionPercentage <= 1.0){
          rebuild();
        }
        else{
          completionPercentage = 0;
        }
      });
    }
  }

  void rebuild(){
    if(!mounted) {
      return;
    }
    setState(() {
      // Just requesting widget rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        putToView(widget.track);
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > sensitivity) {
          swipingRight = true;
        }
      },
      onHorizontalDragEnd: (details){
        setState(() {
          if(swipingRight){
            removeTrack(widget.track);
            trackListPanelKey.currentState?.rebuild();
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.track.trackPlayerService.playing ? Colors.blueGrey.shade800.withOpacity(0.3) : Colors.grey.shade800.withOpacity(0.1),
        ),
        height: 50,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: widget.track.trackMetaDataService.getArtworkImage(),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(colors: [Colors.white, Colors.grey.shade800]).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            widget.track.trackMetaDataService.getTitle(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          widget.track.trackMetaDataService.getArtist(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.track.toggleFavourite();
                    },
                    icon: Icon(
                      widget.track.favourite ? Icons.favorite_outlined : Icons.heart_broken_outlined,
                      color: widget.track.favourite ? Colors.red : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if(!widget.track.trackPlayerService.playing) {
                        putToView(widget.track);
                      }
                      else{
                        widget.track.trackPlayerService.pause();
                      }
                    },
                    icon: Icon(
                      widget.track.trackPlayerService.playing ? Icons.pause_circle : Icons.play_arrow_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: LinearPercentIndicator(
                lineHeight: widget.track.trackPlayerService.playing ? 3 : 1,
                backgroundColor: Colors.grey.shade900,
                progressColor: widget.track.trackPlayerService.playing ? Colors.green : Colors.yellow,
                barRadius: const Radius.circular(5),
                percent: completionPercentage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



