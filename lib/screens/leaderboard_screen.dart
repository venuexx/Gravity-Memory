import 'package:flutter/material.dart';
import '../core/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sahte global liderlik verileri
  static final _globalEntries = [
    _Entry(rank: 1, name: 'PlayerOne', score: 14500),
    _Entry(rank: 2, name: 'MemoryKing', score: 13200),
    _Entry(rank: 3, name: 'BrainStorm', score: 12000),
    _Entry(rank: 4, name: 'You', score: 9800, isMe: true),
    _Entry(rank: 5, name: 'ThinkFast', score: 9000),
    _Entry(rank: 6, name: 'DarkPath', score: 8700),
    _Entry(rank: 7, name: 'MazeMaster', score: 7600),
    _Entry(rank: 8, name: 'GridRunner', score: 6400),
  ];

  static final _friendEntries = [
    _Entry(rank: 1, name: 'You', score: 9800, isMe: true),
    _Entry(rank: 2, name: 'Alex', score: 7200),
    _Entry(rank: 3, name: 'Sam', score: 5100),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.accent,
              labelStyle: AppTextStyles.label(size: 12).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 14),
                      SizedBox(width: 6),
                      Text('GLOBAL'),
                    ],
                  ),
                ),
                Tab(text: 'FRIENDS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LeaderList(entries: _globalEntries),
                  _LeaderList(entries: _friendEntries),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  final int rank;
  final String name;
  final int score;
  final bool isMe;

  const _Entry({
    required this.rank,
    required this.name,
    required this.score,
    this.isMe = false,
  });
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: AppColors.white, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text('LEADERBOARD', style: AppTextStyles.title(size: 16)),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _LeaderList extends StatelessWidget {
  final List<_Entry> entries;
  const _LeaderList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: e.isMe ? AppColors.surface : AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: e.isMe
                ? Border.all(color: AppColors.accent.withAlpha(100), width: 1)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${e.rank}',
                  style: AppTextStyles.body(
                    size: 16,
                    color: e.rank <= 3 ? AppColors.accent : AppColors.grey,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.name,
                  style: AppTextStyles.body(
                    size: 14,
                    color: e.isMe ? AppColors.accent : AppColors.white,
                  ),
                ),
              ),
              Text(
                '${e.score}',
                style: AppTextStyles.body(
                  size: 14,
                  color: e.isMe ? AppColors.accent : AppColors.greyLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
