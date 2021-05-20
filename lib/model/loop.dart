import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class PlayingControls extends StatelessWidget {
  final bool isPlaying;
  final LoopMode loopMode;
  final bool isPlaylist;
  final Function() onPrevious;
  final Function() onPlay;
  final Function() onNext;
  final Function() toggleLoop;
  final Function() onStop;
  final Function() toggleShuffle;

  PlayingControls({
    this.isPlaying,
    this.isPlaylist = false,
    this.loopMode,
    this.toggleLoop,
    this.toggleShuffle,
    this.onPrevious,
    this.onPlay,
    this.onNext,
    this.onStop,
  });

  Widget _loopIcon(BuildContext context) {
    final iconSize = 34.0;
    if (loopMode == LoopMode.none) {
      return Container(
        height: 30,
        width: 30,
        child: Icon(
          Icons.loop,
          size: 20,
          color: Colors.grey,
        ),
      );
    } else if (loopMode == LoopMode.playlist) {
      return Container(
        height: 30,
        width: 30,
        child: Icon(
          Icons.playlist_play,
          size: 20,
          color: Colors.white,
        ),
      );
    } else {
      //single
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 30,
            width: 30,
            child: Icon(
              Icons.loop,
              size: 25,
              color: Colors.white,
            ),
          ),
          Center(
            child: Text(
              '1',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      );
    }
  }

//  Container(

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 40,
        ),

        Container(
          height: 50,
          width: 50,
          child: IconButton(
            icon: Icon(
              Icons.skip_previous,
              size: 30,
              color: Colors.white,
            ),
            onPressed: isPlaylist ? onPrevious : null,
          ),
        ),

        // NeumorphicButton(
        //   style: NeumorphicStyle(
        //     boxShape: NeumorphicBoxShape.circle(),
        //   ),
        //   padding: EdgeInsets.all(18),
        //   onPressed: isPlaylist ? onPrevious : null,
        //   child: Icon(Icons.star_rate_sharp),
        // ),
        SizedBox(
          width: 12,
        ),

        // NeumorphicButton(
        //   style: NeumorphicStyle(
        //     boxShape: NeumorphicBoxShape.circle(),
        //   ),
        //   padding: EdgeInsets.all(24),
        //   onPressed: onPlay,
        //   child: Icon(
        //     isPlaying ? Icons.pause : Icons.play_arrow,
        //     size: 32,
        //   ),
        // ),

        Container(
          height: 80,
          width: 80,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(90.0),
                  side: BorderSide(color: Colors.white),
                ),
              ),
            ),
            onPressed: onPlay,
            child: isPlaying
                ? Icon(
                    Icons.pause,
                    size: 40,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
          ),
        ),

        SizedBox(
          width: 12,
        ),
        // NeumorphicButton(
        //   style: NeumorphicStyle(
        //     boxShape: NeumorphicBoxShape.circle(),
        //   ),
        //   padding: EdgeInsets.all(18),
        //   onPressed: isPlaylist ? onNext : null,
        //   child: Icon(Icons.next_plan),
        // ),

        Container(
          height: 50,
          width: 50,
          child: IconButton(
            icon: Icon(
              Icons.skip_next,
              size: 30,
              color: Colors.white,
            ),
            onPressed: isPlaylist ? onNext : null,
          ),
        ),
        SizedBox(
          width: 12,
        ),
        GestureDetector(
          onTap: () {
            if (toggleLoop != null) toggleLoop();
          },
          child: _loopIcon(context),
        ),
      ],
    );
  }
}
