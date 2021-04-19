import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TrialAgain extends StatefulWidget {
  @override
  _TrialAgainState createState() => _TrialAgainState();
}

class _TrialAgainState extends State<TrialAgain> {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Stack(
            children: [
              Container(
                color: Colors.red,
                width: Get.width,
                height: 300,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      await _assetsAudioPlayer.open(
                        Audio.file('/var/mobile/Containers/Data/Application/B828D1C5-8413-4135-9843-A8D8BA87FE31/Documents/Cleopatra.mp4'),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 200,
                  color: Colors.blue,
                  width: Get.width,
                  child: _assetsAudioPlayer.builderRealtimePlayingInfos(
                    builder: (context, RealtimePlayingInfos infos) {
                      // if (infos == null) {
                      //   return SizedBox();
                      // }
                      // return Container(color: Colors.blue, height: 200);
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(width: 15),
                                Container(
                                  width: 40,
                                  color: Colors.black,
                                  child: Text(
                                    durationToString(infos.currentPosition),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 40,
                                  child: Text(
                                    durationToString(infos.duration),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(width: 10),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: Get.width,
                                    child: Slider(
                                      activeColor: Colors.red,
                                      inactiveColor: Colors.grey,
                                      min: 0,
                                      max: infos.duration.inMilliseconds.toDouble(),
                                      value: infos.currentPosition.inMilliseconds.toDouble(),
                                      onChanged: (double value) {
                                        _assetsAudioPlayer.seek(value.milliseconds);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
