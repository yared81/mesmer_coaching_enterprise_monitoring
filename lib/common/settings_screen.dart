import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/router/app_routes.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/theme/settings_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/core/theme/theme_provider.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeProvider);
    final systemSettings = ref.watch(systemSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with user info
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.role.toString().split('.').last.toUpperCase() ?? '',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'Account Management',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ),
                  _buildSettingsGroup(context, isDark, [
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.person_outline_rounded,
                      title: 'My Profile',
                      subtitle: 'View your personal information',
                      onTap: () {
                        context.push(AppRoutes.profile);
                      },
                    ),
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your account security',
                      showDivider: false,
                      onTap: () {
                        context.push(AppRoutes.changePassword);
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'System & Display',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ),
                  _buildSettingsGroup(context, isDark, [
                    _buildThemeTile(context, ref, themeMode, isDark),
                    _buildTextSizeTile(context, ref, systemSettings.textSize, isDark),
                    _buildHighContrastTile(context, ref, systemSettings.highContrast, isDark),
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.info_outline_rounded,
                      title: 'About App',
                      subtitle: 'Version 1.0.0',
                      showTrailing: false,
                      showDivider: false,
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out of your account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          ref.read(authProvider.notifier).logout();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref, ThemeMode currentTheme, bool isDark) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              currentTheme == ThemeMode.light ? Icons.light_mode_rounded :
              currentTheme == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.brightness_auto_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Text(
            'Adjust app appearance',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13),
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: currentTheme,
              icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
              dropdownColor: Theme.of(context).cardColor,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                }
              },
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          indent: 64,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildTextSizeTile(BuildContext context, WidgetRef ref, String currentSize, bool isDark) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.format_size_rounded, color: isDark ? Colors.white : Colors.black87),
          ),
          title: const Text('Text Size', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Text(
            'Adjust interface font size',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13),
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentSize,
              icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
              dropdownColor: Theme.of(context).cardColor,
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'large', child: Text('Large')),
                DropdownMenuItem(value: 'xlarge', child: Text('Extra Large')),
              ],
              onChanged: (String? size) {
                if (size != null) {
                  ref.read(systemSettingsProvider.notifier).setTextSize(size);
                }
              },
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          indent: 64,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildHighContrastTile(BuildContext context, WidgetRef ref, bool isHighContrast, bool isDark) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          value: isHighContrast,
          onChanged: (bool value) {
            ref.read(systemSettingsProvider.notifier).setHighContrast(value);
          },
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.contrast_rounded, color: isDark ? Colors.white : Colors.black87),
          ),
          title: const Text('High Contrast', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Text(
            'Increase color separation',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13),
          ),
          activeColor: Theme.of(context).primaryColor,
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          indent: 64,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
    bool showTrailing = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13),
                )
              : null,
          trailing: showTrailing
              ? Icon(Icons.chevron_right_rounded, color: isDark ? Colors.grey[600] : Colors.grey[400])
              : null,
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            indent: 64,
            endIndent: 20,
          ),
      ],
    );
  }
}
