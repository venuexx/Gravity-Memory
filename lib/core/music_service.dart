import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _timerPlayer = AudioPlayer();
  final _random = Random();

  static const List<String> _tracks = [
    'assets/music/track_1.mp3',
    'assets/music/track_2.mp3',
    'assets/music/track_3.mp3',
    'assets/music/track_4.mp3',
  ];

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _timerPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMenu() async {
    await init();
    await stopTimer();
    final track = _tracks[_random.nextInt(_tracks.length)];
    await _player.setVolume(0.75);
    await _player.play(AssetSource(track.replaceFirst('assets/', '')));
  }

  Future<void> playGame() async {
    await init();
    await _player.setVolume(0.30);
    final state = _player.state;
    if (state != PlayerState.playing) {
      final track = _tracks[_random.nextInt(_tracks.length)];
      await _player.play(AssetSource(track.replaceFirst('assets/', '')));
    }
  }

  Future<void> startTimer() async {
    await init();
    await _timerPlayer.play(AssetSource('music/timer.mp3'));
  }

  Future<void> stopTimer() async {
    await _timerPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }
}
