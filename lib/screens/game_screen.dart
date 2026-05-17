import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_data.dart';
import '../core/save_service.dart';
import '../core/ad_service.dart';
import '../core/music_service.dart';
import '../widgets/ad_banner_widget.dart';

enum GamePhase { memorize, playing, paused }

class GameScreen extends StatefulWidget {
  final int levelId;
  final int? resumeRow;
  final int? resumeCol;
  final int? resumeTime;
  final int? resumeMoves;
  const GameScreen({
    super.key,
    required this.levelId,
    this.resumeRow,
    this.resumeCol,
    this.resumeTime,
    this.resumeMoves,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late LevelData _level;
  late GamePhase _phase;
  late int _playerRow;
  late int _playerCol;
  final List<(int, int)> _trail = [];
  int _moves = 0;
  int _elapsedSeconds = 20;
  late int _memorizeCountdown;
  Timer? _timer;
  late AnimationController _flashController;
  late AnimationController _transitionController;

  @override
  void initState() {
    super.initState();
    _level = kAllLevels.firstWhere((l) => l.id == widget.levelId);
    final bool isResume = widget.resumeRow != null;
    if (isResume) {
      _playerRow = widget.resumeRow!;
      _playerCol = widget.resumeCol!;
      _elapsedSeconds = widget.resumeTime!;
      _moves = widget.resumeMoves!;
    } else {
      final (sr, sc) = _level.startPos;
      _playerRow = sr;
      _playerCol = sc;
    }
    _memorizeCountdown = 3;
    _phase = GamePhase.memorize;
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startMemorizeTimer();
    AdService.instance.preload();
    MusicService.instance.setVolume(0.30);
  }

  void _startMemorizeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _memorizeCountdown--);
      if (_memorizeCountdown <= 0) {
        t.cancel();
        _startPlaying();
      }
    });
  }

  void _startPlaying() {
    _transitionController.forward().then((_) {
      if (!mounted) return;
      setState(() => _phase = GamePhase.playing);
      _transitionController.reverse();
      MusicService.instance.startTimer();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_phase != GamePhase.playing) return;
        setState(() => _elapsedSeconds--);
        if (_elapsedSeconds <= 0) {
          t.cancel();
          _showFailed();
        }
      });
    });
  }

  void _showFailed() {
    if (!mounted) return;
    MusicService.instance.stopTimer();
    _goToFail();
  }

  void _goToFail() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.fail,
      arguments: {
        'levelId': widget.levelId,
        'resumeRow': _playerRow,
        'resumeCol': _playerCol,
        'resumeTime': _elapsedSeconds,
        'resumeMoves': _moves,
      },
    );
  }

  void _move(int dRow, int dCol) {
    if (_phase != GamePhase.playing) return;
    final nr = _playerRow + dRow;
    final nc = _playerCol + dCol;

    if (nr < 0 || nr >= _level.rows || nc < 0 || nc >= _level.cols) return;

    setState(() => _moves++);

    final cell = _level.grid[nr][nc];
    if (cell == 0) {
      MusicService.instance.playBurn();
      _flashController.forward(from: 0);
      HapticFeedback.heavyImpact();
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _showFailed();
      });
      return;
    }

    MusicService.instance.playMove();
    final prevRow = _playerRow;
    final prevCol = _playerCol;
    setState(() {
      _trail.add((prevRow, prevCol));
      if (_trail.length > 6) _trail.removeAt(0);
      _playerRow = nr;
      _playerCol = nc;
    });

    if (cell == 3) {
      _timer?.cancel();
      MusicService.instance.playSuccess();
      context.read<SaveService>().saveLevel(widget.levelId);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        MusicService.instance.stopTimer();
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.success,
          arguments: {
            'levelId': widget.levelId,
            'timeSeconds': 20 - _elapsedSeconds,
            'moves': _moves,
          },
        );
      });
    }
  }

  void _togglePause() {
    if (_phase == GamePhase.paused) {
      MusicService.instance.resumeTimer();
      setState(() => _phase = GamePhase.playing);
    } else {
      MusicService.instance.pauseTimer();
      setState(() => _phase = GamePhase.paused);
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    MusicService.instance.stopTimer();
    _flashController.dispose();
    _transitionController.dispose();
    MusicService.instance.setVolume(0.75);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _flashController,
          builder: (context, child) {
            final flashValue = _flashController.value;
            return Container(
              color: flashValue > 0
                  ? AppColors.danger.withAlpha((flashValue * 80).toInt())
                  : Colors.transparent,
              child: child,
            );
          },
          child: Column(
            children: [
              _TopHud(
                remainingSeconds: _elapsedSeconds,
                phase: _phase,
                onPause: _togglePause,
                levelId: widget.levelId,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _MazeWidget(
                      level: _level,
                      phase: _phase,
                      playerRow: _playerRow,
                      playerCol: _playerCol,
                      trail: _trail,
                    ),
                    if (_phase == GamePhase.memorize)
                      _MemorizeOverlay(seconds: _memorizeCountdown),
                    if (_phase == GamePhase.paused)
                      _PauseOverlay(
                        onResume: _togglePause,
                        onLevels: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.levelSelect,
                          (r) => false,
                        ),
                        onHome: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.mainMenu,
                          (r) => false,
                        ),
                      ),
                    // ── Fade geçiş overlay ──
                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, _) => IgnorePointer(
                        child: Opacity(
                          opacity: _transitionController.value,
                          child: Container(
                              color: AppColors.background),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: _DPad(onMove: _move),
              ),
              const SizedBox(
                height: 50,
                child: Center(child: AdBannerWidget()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TOP HUD ─────────────────────────────────────────────────────────────────

class _TopHud extends StatelessWidget {
  final int remainingSeconds;
  final GamePhase phase;
  final VoidCallback onPause;
  final int levelId;

  const _TopHud({
    required this.remainingSeconds,
    required this.phase,
    required this.onPause,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = remainingSeconds <= 5;
    final isWarning = remainingSeconds <= 10 && !isUrgent;
    final timerColor = isUrgent
        ? AppColors.danger
        : isWarning
            ? AppColors.accent
            : AppColors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.greyDark.withAlpha(80), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Sayaç ──
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: timerColor.withAlpha(180),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  remainingSeconds.toString().padLeft(2, '0'),
                  style: AppTextStyles.title(
                    size: 22,
                    color: timerColor,
                  ),
                ),
              ],
            ),
          ),
          // ── Level ──
          Expanded(
            child: Center(
              child: Text(
                'LEVEL $levelId',
                style: AppTextStyles.title(
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          // ── Pause ──
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onPause,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.accent.withAlpha(60), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(25),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    phase == GamePhase.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MAZE ─────────────────────────────────────────────────────────────────────

class _MazeWidget extends StatefulWidget {
  final LevelData level;
  final GamePhase phase;
  final int playerRow;
  final int playerCol;
  final List<(int, int)> trail;

  const _MazeWidget({
    required this.level,
    required this.phase,
    required this.playerRow,
    required this.playerCol,
    required this.trail,
  });

  @override
  State<_MazeWidget> createState() => _MazeWidgetState();
}

class _MazeWidgetState extends State<_MazeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveCtrl;
  late Animation<double> _rowAnim;
  late Animation<double> _colAnim;
  double _fromRow = 0;
  double _fromCol = 0;

  static const _moveDuration = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _fromRow = widget.playerRow.toDouble();
    _fromCol = widget.playerCol.toDouble();
    _moveCtrl = AnimationController(vsync: this, duration: _moveDuration);
    _rowAnim = AlwaysStoppedAnimation(_fromRow);
    _colAnim = AlwaysStoppedAnimation(_fromCol);
  }

  @override
  void didUpdateWidget(_MazeWidget old) {
    super.didUpdateWidget(old);
    if (old.playerRow != widget.playerRow || old.playerCol != widget.playerCol) {
      _fromRow = _rowAnim.value;
      _fromCol = _colAnim.value;
      _rowAnim = Tween<double>(
        begin: _fromRow,
        end: widget.playerRow.toDouble(),
      ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeOut));
      _colAnim = Tween<double>(
        begin: _fromCol,
        end: widget.playerCol.toDouble(),
      ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeOut));
      _moveCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _moveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showMap = widget.phase == GamePhase.memorize;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final availH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.55;
        final byWidth = (availW - 32) / widget.level.cols;
        final byHeight = (availH - 32) / widget.level.rows;
        final tileSize =
            (byWidth < byHeight ? byWidth : byHeight).clamp(14.0, 48.0);
        final cellStep = tileSize + 3.0;
        final gridW = widget.level.cols * cellStep;
        final gridH = widget.level.rows * cellStep;

        return Center(
          child: SizedBox(
            width: gridW,
            height: gridH,
            child: AnimatedBuilder(
              animation: _moveCtrl,
              builder: (context, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Zemin hücreleri ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.level.rows, (r) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.level.cols, (c) {
                            return _buildCell(r, c, showMap, tileSize);
                          }),
                        );
                      }),
                    ),

                    // ── İz hücreleri ──
                    ...List.generate(widget.trail.length, (i) {
                      final (tr, tc) = widget.trail[i];
                      final opacity =
                          ((i + 1) / (widget.trail.length + 1)) * 0.45;
                      return Positioned(
                        left: tc * cellStep + 1.5,
                        top: tr * cellStep + 1.5,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: tileSize,
                            height: tileSize,
                            decoration: BoxDecoration(
                              color: AppColors.playerColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    }),

                    // ── Animasyonlu oyuncu ──
                    Positioned(
                      left: _colAnim.value * cellStep + 1.5,
                      top: _rowAnim.value * cellStep + 1.5,
                      child: Container(
                        width: tileSize,
                        height: tileSize,
                        decoration: BoxDecoration(
                          color: AppColors.playerColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.playerColor.withAlpha(80),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Vignette aydınlatma ──
                    if (widget.phase == GamePhase.playing)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _VignettePainter(
                              playerCenter: Offset(
                                (_colAnim.value + 0.5) * cellStep,
                                (_rowAnim.value + 0.5) * cellStep,
                              ),
                              glowRadius: tileSize * 3.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int r, int c, bool showMap, double tileSize) {
    final cell = widget.level.grid[r][c];
    final (exitR, exitC) = widget.level.exitPos;
    final isExit = r == exitR && c == exitC;

    Color cellColor;
    Widget? child;

    if (showMap) {
      if (cell == 0) {
        cellColor = AppColors.tileWall;
      } else if (cell == 3) {
        cellColor = AppColors.tilePath;
        child = Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.exitColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      } else {
        cellColor = AppColors.tilePath;
      }
    } else {
      if (isExit) {
        cellColor = AppColors.tilePath;
        child = Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.exitColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      } else {
        cellColor = AppColors.background;
      }
    }

    final isDarkCell = !showMap && !isExit;
    return Container(
      width: tileSize,
      height: tileSize,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border: isDarkCell
            ? Border.all(color: const Color(0xFF1F1F1F), width: 1)
            : null,
      ),
      child: child,
    );
  }
}

// ─── OVERLAYS ────────────────────────────────────────────────────────────────

class _MemorizeOverlay extends StatelessWidget {
  final int seconds;
  const _MemorizeOverlay({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      child: Column(
        children: [
          Text(
            'MEMORIZE THE PATH',
            style: AppTextStyles.label(size: 13, color: AppColors.greyLight),
          ),
          const SizedBox(height: 4),
          Text(
            '$seconds',
            style: AppTextStyles.title(size: 40, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onLevels;
  final VoidCallback onHome;

  const _PauseOverlay({
    required this.onResume,
    required this.onLevels,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withAlpha(230),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.greyDark, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── İkon ──
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accent.withAlpha(80), width: 1.5),
                ),
                child: const Icon(Icons.pause_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(height: 16),
              Text('PAUSED',
                  style: AppTextStyles.title(size: 22, color: AppColors.white)),
              const SizedBox(height: 6),
              Container(width: 40, height: 1.5, color: AppColors.accent),
              const SizedBox(height: 28),
              // ── RESUME ──
              _pauseBtn(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                color: AppColors.accent,
                textColor: AppColors.background,
                onTap: onResume,
              ),
              const SizedBox(height: 12),
              // ── LEVELS ──
              _pauseBtn(
                label: 'LEVELS',
                icon: Icons.grid_view_rounded,
                color: AppColors.card,
                textColor: AppColors.white,
                onTap: onLevels,
              ),
              const SizedBox(height: 12),
              // ── HOME ──
              _pauseBtn(
                label: 'HOME',
                icon: Icons.home_rounded,
                color: AppColors.card,
                textColor: AppColors.white,
                onTap: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pauseBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.greyDark.withAlpha(80), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body(size: 13, color: textColor)
                  .copyWith(fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── D-PAD ───────────────────────────────────────────────────────────────────

class _DPad extends StatelessWidget {
  final void Function(int dRow, int dCol) onMove;

  const _DPad({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadBtn(icon: Icons.keyboard_arrow_up, onTap: () => onMove(-1, 0)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadBtn(icon: Icons.keyboard_arrow_left, onTap: () => onMove(0, -1)),
              const SizedBox(width: 52),
              _DPadBtn(icon: Icons.keyboard_arrow_right, onTap: () => onMove(0, 1)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadBtn(icon: Icons.keyboard_arrow_down, onTap: () => onMove(1, 0)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DPadBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DPadBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyDark, width: 1),
        ),
        child: Icon(icon, color: AppColors.white, size: 34),
      ),
    );
  }
}

// ─── VIGNETTE ────────────────────────────────────────────────────────────────

class _VignettePainter extends CustomPainter {
  final Offset playerCenter;
  final double glowRadius;

  const _VignettePainter({
    required this.playerCenter,
    required this.glowRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Merkeze hafif beyaz parıltı — grid hücrelerini az aydınlatır
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        playerCenter,
        glowRadius * 0.9,
        [
          const Color(0x22FFFFFF), // oyuncu çevresinde ince beyaz ışık
          const Color(0x0AFFFFFF),
          const Color(0x00FFFFFF),
        ],
        [0.0, 0.40, 1.0],
        TileMode.clamp,
      )
      ..blendMode = BlendMode.screen;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaint,
    );

    // 2) Kenarları karanlık tutan ana vignette
    final vignettePaint = Paint()
      ..shader = ui.Gradient.radial(
        playerCenter,
        glowRadius,
        [
          const Color(0x00000000),
          const Color(0x00000000),
          const Color(0xCC111111),
          const Color(0xEE111111),
        ],
        [0.0, 0.28, 0.72, 1.0],
        TileMode.clamp,
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );
  }

  @override
  bool shouldRepaint(_VignettePainter old) =>
      old.playerCenter != playerCenter || old.glowRadius != glowRadius;
}
