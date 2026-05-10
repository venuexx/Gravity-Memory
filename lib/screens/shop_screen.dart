import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/save_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _chars = [
    (id: 0, price: 0, emoji: '◻'),
    (id: 1, price: 1000, emoji: '◈'),
    (id: 2, price: 1500, emoji: '◉'),
    (id: 3, price: 2000, emoji: '◆'),
    (id: 4, price: 2500, emoji: '●'),
    (id: 5, price: 3000, emoji: '■'),
  ];

  static const _tiles = [
    (id: 0, price: 0, label: 'DEFAULT'),
    (id: 1, price: 1000, label: 'DARK'),
    (id: 2, price: 1500, label: 'NEON'),
    (id: 3, price: 2000, label: 'STONE'),
    (id: 4, price: 2500, label: 'METAL'),
    (id: 5, price: 3000, label: 'GOLD'),
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
    final save = context.watch<SaveService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ShopHeader(coins: save.coins),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.accent,
              labelStyle: AppTextStyles.label(size: 12).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
              tabs: const [Tab(text: 'CHARACTERS'), Tab(text: 'TILES')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ItemGrid(
                    items: _chars
                        .map((c) => _ShopItem(
                              id: c.id,
                              label: c.emoji,
                              price: c.price,
                              owned: save.ownedChars.contains(c.id),
                              selected: save.selectedChar == c.id,
                              onBuy: () =>
                                  save.purchaseChar(c.id, c.price),
                              onSelect: () => save.selectChar(c.id),
                            ))
                        .toList(),
                  ),
                  _ItemGrid(
                    items: _tiles
                        .map((t) => _ShopItem(
                              id: t.id,
                              label: t.label,
                              price: t.price,
                              owned: save.ownedTiles.contains(t.id),
                              selected: save.selectedTile == t.id,
                              onBuy: () =>
                                  save.purchaseTile(t.id, t.price),
                              onSelect: () => save.selectTile(t.id),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final int coins;
  const _ShopHeader({required this.coins});

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
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: AppTextStyles.body(size: 14, color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem {
  final int id;
  final String label;
  final int price;
  final bool owned;
  final bool selected;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  const _ShopItem({
    required this.id,
    required this.label,
    required this.price,
    required this.owned,
    required this.selected,
    required this.onBuy,
    required this.onSelect,
  });
}

class _ItemGrid extends StatelessWidget {
  final List<_ShopItem> items;
  const _ItemGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.owned ? item.onSelect : item.onBuy,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: item.selected
                    ? AppColors.accent
                    : AppColors.greyDark,
                width: item.selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: AppTextStyles.body(size: 28),
                ),
                const SizedBox(height: 8),
                if (item.selected)
                  const Icon(Icons.check,
                      color: AppColors.accent, size: 18)
                else if (item.owned)
                  Text(
                    'OWNED',
                    style: AppTextStyles.label(size: 10, color: AppColors.grey),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.accent, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${item.price}',
                        style: AppTextStyles.label(
                            size: 11, color: AppColors.greyLight),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
