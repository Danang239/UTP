import 'package:flutter/material.dart';

// IMPORT PAGE USER
import '../home/home_view.dart';
import '../favorite/favorite_view.dart';
import '../pesan/pesan_view.dart';
import '../profile/profile_view.dart';

// =======================
// MAIN PAGE
// =======================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const HomeView(),
      const FavoriteView(),
      const PesanView(),
      ProfileView(
        onTapFavorite: () {
          setState(() => _selectedIndex = 1);
        },
      ),
    ];
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // =====================
      // BACKGROUND
      // =====================
      backgroundColor: theme.scaffoldBackgroundColor,

      // =====================
      // BODY (ANIMATED PAGE)
      // =====================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
        child: pages[_selectedIndex],
      ),

      // =====================
      // THEME-AWARE NAVBAR
      // =====================
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor ??
              theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ElasticNavItem(
              icon: Icons.search,
              label: "Home",
              index: 0,
              selectedIndex: _selectedIndex,
              color: theme.colorScheme.primary,
              onTap: _onTap,
            ),
            _ElasticNavItem(
              icon: Icons.favorite,
              label: "Favorit",
              index: 1,
              selectedIndex: _selectedIndex,
              color: theme.colorScheme.error,
              onTap: _onTap,
            ),
            _ElasticNavItem(
              icon: Icons.chat_bubble_outline,
              label: "Pesan",
              index: 2,
              selectedIndex: _selectedIndex,
              color: theme.colorScheme.secondary,
              onTap: _onTap,
            ),
            _ElasticNavItem(
              icon: Icons.person_outline,
              label: "Profil",
              index: 3,
              selectedIndex: _selectedIndex,
              color: theme.colorScheme.primary,
              onTap: _onTap,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// ELASTIC NAV ITEM (THEME AWARE)
// =======================================================
class _ElasticNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Color color;
  final Function(int) onTap;

  const _ElasticNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = index == selectedIndex;

    return InkResponse(
      onTap: () => onTap(index),
      radius: 32,
      splashColor: color.withOpacity(0.2),
      highlightShape: BoxShape.circle,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 1,
          end: isActive ? 1.45 : 1,
        ),
        duration: const Duration(milliseconds: 380),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? color
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? color
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  width: isActive ? 16 : 0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
