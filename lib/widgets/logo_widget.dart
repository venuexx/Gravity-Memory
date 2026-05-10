import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Maze ikonu ──
        const _MazeIcon(),
        const SizedBox(height: 28),
        // ── "GRAVITY" yazısı ──
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
          ).createShader(bounds),
          child: Text(
            'GRAVITY',
            style: AppTextStyles.title(size: 44, color: AppColors.white),
          ),
        ),
        const SizedBox(height: 2),
        // ── "MEMORY" yazısı ──
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5C518), Color(0xFFB8931A)],
          ).createShader(bounds),
          child: Text(
            'MEMORY',
            style: AppTextStyles.title(size: 44, color: AppColors.accent),
          ),
        ),
        const SizedBox(height: 10),
        // ── Alt çizgi ──
        Container(
          width: 48,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(160),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _MazeIcon extends StatefulWidget {
  // 0=gri, 1=beyaz hücre, 2=her zaman sarı hücre (sol alt)
  static const _grid = [
    [0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 1, 0],
    [0, 2, 1, 1, 0],
  ];

  const _MazeIcon();

  @override
  State<_MazeIcon> createState() => _MazeIconState();
}

class _MazeIconState extends State<_MazeIcon> {
  static final _litCells = [
    for (int r = 0; r < _MazeIcon._grid.length; r++)
      for (int c = 0; c < _MazeIcon._grid[r].length; c++)
        if (_MazeIcon._grid[r][c] >= 1) (r, c),
  ];

  int _activeIndex = 0;
  Timer? _timer;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    final delay = 500 + _rng.nextInt(400); // 500–900ms yavaş
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _activeIndex = (_activeIndex + 1) % _litCells.length;
      });
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCell = _litCells[_activeIndex];
    const cell = 11.0;
    const gap = 3.0;
    final w = 5 * cell + 4 * gap;
    final h = 5 * cell + 4 * gap;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(40),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_MazeIcon._grid.length, (r) {
              return Padding(
                padding: EdgeInsets.only(top: r == 0 ? 0 : gap),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_MazeIcon._grid[r].length, (c) {
                    final val = _MazeIcon._grid[r][c];
                    final isLit = val >= 1;
                    final isYellow = val == 2; // sol alt — her zaman sarı
                    final isActive = activeCell == (r, c);

                    final Color baseColor;
                    if (!isLit) {
                      baseColor = AppColors.greyDark;
                    } else if (isYellow) {
                      baseColor = AppColors.accent; // sarı sabit
                    } else {
                      baseColor = isActive
                          ? AppColors.white
                          : AppColors.white.withAlpha(180);
                    }

                    return Padding(
                      padding: EdgeInsets.only(left: c == 0 ? 0 : gap),
                      child: AnimatedScale(
                        scale: (isActive && !isYellow) ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: cell,
                          height: cell,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
