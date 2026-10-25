import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../theme/paper_tokens.dart';
import '../../theme/theme_provider.dart';
import '../paper/tactile_button.dart';

class DeskSettingsDrawer extends StatefulWidget {
  const DeskSettingsDrawer({super.key});

  @override
  State<DeskSettingsDrawer> createState() => _DeskSettingsDrawerState();
}

class _DeskSettingsDrawerState extends State<DeskSettingsDrawer> {
  final TextEditingController _presetNameCtrl = TextEditingController();
  final TextEditingController _importCtrl = TextEditingController();
  final TextEditingController _serverUrlCtrl = TextEditingController();
  String? _importMessage;
  String? _serverMessage;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _serverUrlCtrl.text = ApiService.baseUrl;
  }

  @override
  void dispose() {
    _presetNameCtrl.dispose();
    _importCtrl.dispose();
    _serverUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final shade = theme.currentShade;

    return Drawer(
      backgroundColor: shade.paper,
      width: 360,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: theme.inkColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Desk settings',
                        style: GoogleFonts.fraunces(
                          color: shade.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: shade.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: shade.rule, height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Paper Shade Swatches
                  _buildSectionTitle('PAPER SHADE', shade),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PaperShade.values.map((s) {
                      final token = PaperTokens.shades[s]!;
                      final isSelected = theme.shade == s;
                      return InkWell(
                        onTap: () => theme.setShade(s),
                        child: Container(
                          width: 96,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: token.paper,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isSelected ? theme.inkColor : shade.rule,
                              width: isSelected ? 2.0 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: token.desk,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  token.name,
                                  style: GoogleFonts.karla(
                                    color: token.text,
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Ink Color Swatches
                  _buildSectionTitle('INK COLOUR', shade),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: InkColor.values.map((i) {
                      final token = PaperTokens.inks[i]!;
                      final isSelected = theme.ink == i;
                      final val = shade.isDark
                          ? token.darkValue
                          : token.lightValue;
                      return InkWell(
                        onTap: () => theme.setInk(i),
                        child: Container(
                          width: 96,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: shade.paper2,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isSelected ? theme.inkColor : shade.rule,
                              width: isSelected ? 2.0 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: val,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  token.name,
                                  style: GoogleFonts.karla(
                                    color: shade.text,
                                    fontSize: 10.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Paper Grain Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('PAPER GRAIN', shade),
                      Text(
                        '${(theme.grain * 100).round()}%',
                        style: GoogleFonts.karla(
                          color: shade.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    min: 0.0,
                    max: 0.7,
                    divisions: 14,
                    value: theme.grain,
                    activeColor: theme.inkColor,
                    inactiveColor: shade.rule.withValues(alpha: 0.5),
                    onChanged: (v) => theme.setGrain(v),
                  ),

                  const SizedBox(height: 16),

                  // Layout & Visualizer
                  Row(
                    children: [
                      // Tilt toggle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('SHEET LAYOUT', shade),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildTogglePill(
                                  'Tilted',
                                  theme.tilted,
                                  () => theme.setTilt(true),
                                  theme,
                                  shade,
                                ),
                                const SizedBox(width: 4),
                                _buildTogglePill(
                                  'Straight',
                                  !theme.tilted,
                                  () => theme.setTilt(false),
                                  theme,
                                  shade,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Visualizer Style
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('VISUALIZER', shade),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<VisualizerStyle>(
                              initialValue: theme.visualizer,
                              dropdownColor: shade.paper,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: shade.rule),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                isDense: true,
                              ),
                              items: VisualizerStyle.values.map((v) {
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v.name.toUpperCase(),
                                    style: GoogleFonts.karla(
                                      fontSize: 11,
                                      color: shade.text,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) theme.setVisualizer(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Auto shade by time of day
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shade.paper2,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: shade.rule.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Auto shade by time of day',
                              style: GoogleFonts.karla(
                                color: shade.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch.adaptive(
                              value: theme.autoShade,
                              activeTrackColor: theme.inkColor,
                              onChanged: (v) => theme.setAutoShade(v),
                            ),
                          ],
                        ),
                        Text(
                          'Uses device clock only: Stone before 17:00, Slate 17:00–21:00, Charcoal after 21:00.',
                          style: GoogleFonts.karla(
                            color: shade.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Sleep Timer
                  _buildSectionTitle('SLEEP TIMER', shade),
                  const SizedBox(height: 8),
                  Row(
                    children: [null, 15, 30, 60].map((mins) {
                      final isSelected = theme.sleepTimerMinutes == mins;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () => theme.setSleepTimer(mins),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.inkColor
                                    : shade.paper2,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.inkColor
                                      : shade.rule,
                                ),
                              ),
                              child: Text(
                                mins == null ? 'Off' : '${mins}m',
                                style: GoogleFonts.karla(
                                  color: isSelected ? shade.paper : shade.text,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Presets Section
                  _buildSectionTitle(
                    'MY PRESETS (${theme.presets.length}/8)',
                    shade,
                  ),
                  const SizedBox(height: 8),
                  ...theme.presets.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: shade.paper2,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: shade.rule.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => theme.applyPreset(p),
                              child: Text(
                                p.name,
                                style: GoogleFonts.karla(
                                  color: shade.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  p.shade.name,
                                  style: GoogleFonts.karla(
                                    color: shade.muted,
                                    fontSize: 10,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 14,
                                    color: shade.muted,
                                  ),
                                  onPressed: () => theme.deletePreset(p.name),
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (theme.presets.length < 8)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _presetNameCtrl,
                            style: GoogleFonts.karla(
                              fontSize: 11,
                              color: shade.text,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Save current look...',
                              hintStyle: GoogleFonts.karla(
                                color: shade.muted,
                                fontSize: 11,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: shade.rule),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TactileButton(
                          label: 'Save',
                          onPressed: () {
                            if (_presetNameCtrl.text.isNotEmpty) {
                              theme.savePreset(_presetNameCtrl.text);
                              _presetNameCtrl.clear();
                            }
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 22),

                  // Share or Import Look
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shade.paper2,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: shade.rule.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share or import look',
                              style: GoogleFonts.karla(
                                color: shade.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TactileButton(
                              label: _copied ? 'Copied' : 'Copy mine',
                              icon: _copied ? Icons.check : Icons.copy,
                              onPressed: () {
                                final code = theme.exportLookCode();
                                Clipboard.setData(ClipboardData(text: code));
                                setState(() => _copied = true);
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) setState(() => _copied = false);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _importCtrl,
                                style: GoogleFonts.karla(
                                  fontSize: 11,
                                  color: shade.text,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Paste base64 code...',
                                  hintStyle: GoogleFonts.karla(
                                    color: shade.muted,
                                    fontSize: 11,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 7,
                                  ),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: shade.rule),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            TactileButton(
                              label: 'Import',
                              onPressed: () {
                                final err = theme.importLookCode(
                                  _importCtrl.text,
                                );
                                setState(() {
                                  _importMessage =
                                      err ?? 'Look imported successfully.';
                                });
                                if (err == null) _importCtrl.clear();
                              },
                            ),
                          ],
                        ),
                        if (_importMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _importMessage!,
                              style: GoogleFonts.karla(
                                color: _importMessage!.contains('successfully')
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Backend Server URL Configuration
                  _buildSectionTitle('BACKEND SERVER URL', shade),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shade.paper2,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: shade.rule.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure the FastAPI backend address (local LAN IP or deployed URL).',
                          style: GoogleFonts.karla(
                            color: shade.muted,
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _serverUrlCtrl,
                                style: GoogleFonts.karla(
                                  fontSize: 11,
                                  color: shade.text,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'http://192.168.1.X:8000',
                                  hintStyle: GoogleFonts.karla(
                                    color: shade.muted,
                                    fontSize: 11,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 7,
                                  ),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: shade.rule),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            TactileButton(
                              label: 'Save',
                              icon: Icons.save,
                              onPressed: () async {
                                final url = _serverUrlCtrl.text.trim();
                                await ApiService.setCustomBaseUrl(url);
                                setState(() {
                                  _serverMessage = 'Server URL saved: $url';
                                });
                                Future.delayed(const Duration(seconds: 3), () {
                                  if (mounted) setState(() => _serverMessage = null);
                                });
                              },
                            ),
                          ],
                        ),
                        if (_serverMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _serverMessage!,
                              style: GoogleFonts.karla(
                                color: Colors.green,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Restore Defaults
                  Center(
                    child: TextButton.icon(
                      icon: Icon(Icons.refresh, size: 14, color: shade.muted),
                      label: Text(
                        'Restore defaults',
                        style: GoogleFonts.karla(
                          color: shade.muted,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: theme.restoreDefaults,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ShadeTokens shade) {
    return Text(
      title,
      style: GoogleFonts.karla(
        color: shade.muted,
        fontSize: 9.5,
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTogglePill(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ThemeProvider theme,
    ShadeTokens shade,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.inkColor : shade.paper2,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: isSelected ? theme.inkColor : shade.rule),
          ),
          child: Text(
            label,
            style: GoogleFonts.karla(
              color: isSelected ? shade.paper : shade.text,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
