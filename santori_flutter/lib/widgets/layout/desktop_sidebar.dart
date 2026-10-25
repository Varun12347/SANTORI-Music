import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/preset.dart';
import '../../theme/paper_tokens.dart';
import '../../theme/theme_provider.dart';

class DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onOpenDeskSettings;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onOpenDeskSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final shade = theme.currentShade;

    return Container(
      width: 230,
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 16),
      color: shade.desk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/images/santori_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Color(0xFF00FF66),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SANTORI',
                    style: GoogleFonts.fraunces(
                      color: shade.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'MUSIC APP',
                    style: GoogleFonts.karla(
                      color: shade.muted,
                      fontSize: 8.5,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Folder Tabs Navigation
          _buildNavTab(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            theme: theme,
          ),
          const SizedBox(height: 4),
          _buildNavTab(
            index: 1,
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: 'Search',
            theme: theme,
          ),
          const SizedBox(height: 4),
          _buildNavTab(
            index: 2,
            icon: Icons.library_music_outlined,
            activeIcon: Icons.library_music,
            label: 'Your library',
            theme: theme,
          ),

          const SizedBox(height: 28),

          // Listening Profiles Section
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.bookmark_outline, size: 14, color: shade.muted),
                const SizedBox(width: 6),
                Text(
                  'LISTENING PROFILES',
                  style: GoogleFonts.karla(
                    color: shade.muted,
                    fontSize: 9.5,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: listeningProfiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, idx) {
                final prof = listeningProfiles[idx];
                final isCurrent =
                    theme.shade == prof.shade && theme.ink == prof.ink;

                return InkWell(
                  onTap: () {
                    theme.applyPreset(
                      SavedLookPreset(
                        name: prof.name,
                        shade: prof.shade,
                        ink: prof.ink,
                        grain: prof.grain,
                        tilted: prof.tilted,
                        visualizer: prof.visualizer,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent ? shade.paper : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                      border: isCurrent
                          ? Border(
                              right: BorderSide(
                                color: theme.inkColor,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prof.name,
                          style: GoogleFonts.karla(
                            color: isCurrent ? theme.inkColor : shade.text,
                            fontSize: 12,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        Text(
                          prof.description,
                          style: GoogleFonts.karla(
                            color: shade.muted,
                            fontSize: 9.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Settings Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: onOpenDeskSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: shade.paper2,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: shade.rule.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 16, color: theme.inkColor),
                        const SizedBox(width: 8),
                        Text(
                          'Desk settings',
                          style: GoogleFonts.karla(
                            color: shade.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      theme.currentShade.name,
                      style: GoogleFonts.karla(
                        color: shade.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ThemeProvider theme,
  }) {
    final isSelected = currentIndex == index;
    final shade = theme.currentShade;

    return InkWell(
      onTap: () => onIndexChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? shade.paper : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: shade.isDark ? 0.35 : 0.08,
                    ),
                    offset: const Offset(-2, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
          border: isSelected
              ? Border(right: BorderSide(color: theme.inkColor, width: 2.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 18,
              color: isSelected ? theme.inkColor : shade.muted,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.karla(
                color: isSelected ? theme.inkColor : shade.text,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
