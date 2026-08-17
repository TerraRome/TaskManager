import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _emailDigest = false;
  bool _taskReminders = true;
  bool _weeklyReport = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  static const _languages = ['English', 'Bahasa Indonesia', 'Español', '日本語'];
  static const _themes = ['System', 'Light', 'Dark'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = ThemeProvider.isDark(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildSectionTitle('Appearance', cs),
                  _buildCard(cs, [
                    _buildSwitchTile(
                      cs: cs,
                      icon: Icons.dark_mode_outlined,
                      iconColor: AppColors.taskPurple,
                      title: 'Dark Mode',
                      subtitle: 'Switch to dark theme',
                      value: isDark,
                      onChanged: (v) =>
                          ThemeProvider.of(context).setDark(v),
                      isFirst: true,
                      isLast: false,
                    ),
                    _buildDropdownTile(
                      cs: cs,
                      icon: Icons.palette_outlined,
                      iconColor: AppColors.taskBlue,
                      title: 'Theme',
                      value: _selectedTheme,
                      options: _themes,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedTheme = v);
                        final brightness =
                            MediaQuery.of(context).platformBrightness;
                        switch (v) {
                          case 'Light':
                            ThemeProvider.of(context).setDark(false);
                            break;
                          case 'Dark':
                            ThemeProvider.of(context).setDark(true);
                            break;
                          default: // System
                            ThemeProvider.of(context)
                                .setDark(brightness == Brightness.dark);
                        }
                      },
                      isFirst: false,
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Notifications', cs),
                  _buildCard(cs, [
                    _buildSwitchTile(
                      cs: cs,
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.taskOrange,
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts on your device',
                      value: _notifications,
                      onChanged: (v) =>
                          setState(() => _notifications = v),
                      isFirst: true,
                      isLast: false,
                    ),
                    _buildSwitchTile(
                      cs: cs,
                      icon: Icons.alarm_outlined,
                      iconColor: AppColors.taskRed,
                      title: 'Task Reminders',
                      subtitle: 'Get reminded before deadlines',
                      value: _taskReminders,
                      onChanged: (v) =>
                          setState(() => _taskReminders = v),
                      isFirst: false,
                      isLast: false,
                    ),
                    _buildSwitchTile(
                      cs: cs,
                      icon: Icons.email_outlined,
                      iconColor: AppColors.taskGreen,
                      title: 'Email Digest',
                      subtitle: 'Daily summary in your inbox',
                      value: _emailDigest,
                      onChanged: (v) =>
                          setState(() => _emailDigest = v),
                      isFirst: false,
                      isLast: false,
                    ),
                    _buildSwitchTile(
                      cs: cs,
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.taskBlue,
                      title: 'Weekly Report',
                      subtitle: 'Get a weekly productivity summary',
                      value: _weeklyReport,
                      onChanged: (v) =>
                          setState(() => _weeklyReport = v),
                      isFirst: false,
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Language & Region', cs),
                  _buildCard(cs, [
                    _buildDropdownTile(
                      cs: cs,
                      icon: Icons.language_rounded,
                      iconColor: AppColors.taskGreen,
                      title: 'Language',
                      value: _selectedLanguage,
                      options: _languages,
                      onChanged: (v) =>
                          setState(() => _selectedLanguage = v ?? _selectedLanguage),
                      isFirst: true,
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Account', cs),
                  _buildCard(cs, [
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppColors.taskBlue,
                      title: 'Change Password',
                      isFirst: true,
                      isLast: false,
                      onTap: () {},
                    ),
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.taskGreen,
                      title: 'Privacy & Security',
                      isFirst: false,
                      isLast: false,
                      onTap: () {},
                    ),
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.taskOrange,
                      title: 'Help & Support',
                      isFirst: false,
                      isLast: false,
                      onTap: () {},
                    ),
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textSecondary,
                      title: 'About TaskFlow',
                      subtitle: 'Version 1.0.0',
                      isFirst: false,
                      isLast: true,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Danger zone
                  _buildCard(cs, [
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.taskRed,
                      title: 'Log Out',
                      titleColor: AppColors.taskRed,
                      isFirst: true,
                      isLast: false,
                      onTap: () => _showLogoutDialog(context),
                    ),
                    _buildNavTile(
                      cs: cs,
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.taskRed,
                      title: 'Delete Account',
                      titleColor: AppColors.taskRed,
                      isFirst: false,
                      isLast: true,
                      onTap: () {},
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: cs.onSurface),
            ),
          ),
          const Spacer(),
          Text('Settings', style: AppTextStyles.heading2),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: AppTextStyles.label
            .copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildCard(ColorScheme cs, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required ColorScheme cs,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMedium),
                    if (subtitle != null)
                      Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.primary,
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary.withValues(alpha: 0.4);
                  }
                  return null;
                }),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            color: cs.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required ColorScheme cs,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
              DropdownButton<String>(
                value: value,
                underline: const SizedBox(),
                style: AppTextStyles.body.copyWith(color: cs.onSurface),
                dropdownColor: cs.surface,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: cs.onSurface.withValues(alpha: 0.4)),
                items: options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            color: cs.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }

  Widget _buildNavTile({
    required ColorScheme cs,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: titleColor ?? cs.onSurface,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            color: cs.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Log Out', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.body
              .copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/splash');
            },
            child: Text('Log Out',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.taskRed)),
          ),
        ],
      ),
    );
  }
}
