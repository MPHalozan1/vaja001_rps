import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../widgets/notification_bell.dart';
import 'billing_dashboard_screen.dart';
import 'customer_dashboard_screen.dart';
import 'item_catalog_screen.dart';
import 'management_dashboard_screen.dart';
import 'sign_in_screen.dart';

/// Glavno ogrodje aplikacije z gladkimi animiranimi prehodi med stranmi,
/// preklopnikom za Light/Dark temo ter hitrim preklopnikom uporabnikov za lokalno testiranje.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;
  final _dataService = DataService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final user = _dataService.currentUser;
        if (user == null) {
          return const SignInScreen();
        }

        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Seznam strani glede na vlogo prijavljenega uporabnika
        final pages = <_NavPage>[
          const _NavPage(
            title: 'Store Catalog',
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront_rounded,
            screen: ItemCatalogScreen(key: ValueKey('page_catalog')),
          ),
          const _NavPage(
            title: 'My Rentals & Tickets',
            icon: Icons.confirmation_number_outlined,
            selectedIcon: Icons.confirmation_number_rounded,
            screen: CustomerDashboardScreen(key: ValueKey('page_customer')),
          ),
          const _NavPage(
            title: 'Billing & Invoices',
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            screen: BillingDashboardScreen(key: ValueKey('page_billing')),
          ),
          if (user.isStaff)
            _NavPage(
              title: user.isAdmin ? 'Admin & ROI Hub' : 'Employee Operations',
              icon: user.isAdmin
                  ? Icons.analytics_outlined
                  : Icons.assignment_turned_in_outlined,
              selectedIcon: user.isAdmin
                  ? Icons.analytics_rounded
                  : Icons.assignment_turned_in_rounded,
              badgeCount: _dataService.pendingTickets.length,
              screen:
                  const ManagementDashboardScreen(key: ValueKey('page_staff')),
            ),
        ];

        final safeIndex = _selectedIndex >= pages.length ? 0 : _selectedIndex;
        final isWide = MediaQuery.of(context).size.width >= 880;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(color: cs.outlineVariant, height: 1),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.layers_rounded,
                    color: cs.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pages[safeIndex].title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              // 1. Hiter preklop med uporabniki (Customer <-> Employee <-> Admin)
              _buildQuickUserSwitcher(context, user, cs),
              const SizedBox(width: 8),
              // 2. Gumb za preklop Light / Dark teme
              IconButton(
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: _dataService.toggleThemeMode,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                  ),
                ),
              ),
              // 3. Zvonček z obvestili
              const NotificationBell(),
              const SizedBox(width: 4),
              // 4. Odjava
              IconButton(
                tooltip: 'Sign Out',
                onPressed: () {
                  _dataService.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Row(
            children: [
              if (isWide)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  child: NavigationRail(
                    backgroundColor: cs.surface,
                    selectedIndex: safeIndex,
                    extended: MediaQuery.of(context).size.width >= 1200,
                    onDestinationSelected: (idx) =>
                        setState(() => _selectedIndex = idx),
                    destinations: pages.map((p) {
                      return NavigationRailDestination(
                        icon: _buildBadgedIcon(p.icon, p.badgeCount),
                        selectedIcon:
                            _buildBadgedIcon(p.selectedIcon, p.badgeCount),
                        label: Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              // Gladko animirano preklapljanje med vsemi zasloni (Fade + Slide)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.015, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: pages[safeIndex].screen,
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: safeIndex,
                  onDestinationSelected: (idx) =>
                      setState(() => _selectedIndex = idx),
                  destinations: pages.map((p) {
                    return NavigationDestination(
                      icon: _buildBadgedIcon(p.icon, p.badgeCount),
                      selectedIcon:
                          _buildBadgedIcon(p.selectedIcon, p.badgeCount),
                      label: p.title,
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildBadgedIcon(IconData icon, int? badgeCount) {
    if (badgeCount == null || badgeCount <= 0) {
      return Icon(icon);
    }
    return Badge(
      backgroundColor: const Color(0xFFF59E0B),
      textColor: Colors.black,
      label: Text(
        '$badgeCount',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Icon(icon),
    );
  }

  Widget _buildQuickUserSwitcher(
      BuildContext context, User currentUser, ColorScheme cs) {
    final roleColor = currentUser.isAdmin
        ? const Color(0xFFE11D48)
        : currentUser.isEmployee
            ? const Color(0xFF0284C7)
            : const Color(0xFF059669);

    return PopupMenuButton<User>(
      tooltip: 'Quick Switch Active User (Local Testing)',
      color: cs.surface,
      offset: const Offset(0, 46),
      onSelected: (User selectedUser) {
        _dataService.quickSignIn(selectedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Switched active session to ${selectedUser.name} (${selectedUser.roleLabel})',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      itemBuilder: (context) {
        return _dataService.users.map((u) {
          final isCurrent = u.id == currentUser.id;
          return PopupMenuItem<User>(
            value: u,
            child: Row(
              children: [
                Icon(
                  isCurrent
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    u.name,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.normal,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    u.role.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: roleColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: roleColor.withValues(alpha: 0.16),
              child: Icon(
                currentUser.isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : currentUser.isEmployee
                        ? Icons.support_agent_rounded
                        : Icons.person_rounded,
                size: 14,
                color: roleColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${currentUser.name} • ${currentUser.role.name.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPage {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
  final Widget screen;

  const _NavPage({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
    this.badgeCount,
  });
}