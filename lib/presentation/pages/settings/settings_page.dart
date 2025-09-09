import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_setup_bottom_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPinEnabled = false;
  bool _biometricEnabled = false;
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoBackup = false;
  String _currentPin = '';
  bool _isLoggedIn = false; // Track login status

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPinEnabled = prefs.getBool('pin_enabled') ?? false;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _currentPin = prefs.getString('app_pin') ?? '';
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', _isPinEnabled);
    await prefs.setBool('biometric_enabled', _biometricEnabled);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('auto_backup', _autoBackup);
  }

  void _showPinSetupDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinSetupBottomSheet(
        currentPin: _currentPin,
        onPinSet: (pin) {
          setState(() {
            _currentPin = pin;
            _isPinEnabled = pin.isNotEmpty;
          });
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('app_pin', pin);
            prefs.setBool('pin_enabled', pin.isNotEmpty);
          });
        },
      ),
    );
  }

  void _showLoginOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(CupertinoIcons.cloud, size: 60, color: Colors.blue.shade400),
            const SizedBox(height: 16),
            const Text(
              "Sync Your Data",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Login or sign up to backup your data online and sync across devices",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _handleLogin();
                },
                icon: const Icon(CupertinoIcons.person_add),
                label: const Text("Sign Up"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _handleLogin();
                },
                icon: const Icon(CupertinoIcons.person),
                label: const Text("Login"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade400,
                  side: BorderSide(color: Colors.blue.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Maybe Later",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login/Signup feature will be available soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showConfirmationDialog(
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required Widget child,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, isFirst ? 0 : 0, 16, isLast ? 0 : 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    bool showArrow = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (iconColor ?? CupertinoColors.systemBlue).withValues(
            alpha: 0.15,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? CupertinoColors.systemBlue,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1C1C1E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
            )
          : null,
      trailing:
          trailing ??
          (showArrow
              ? const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFD1D1D6),
                  size: 16,
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return _buildSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: CupertinoColors.systemBlue,
      ),
      onTap: () => onChanged(!value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // PROFILE SECTION - Moved to top
          _buildSectionHeader("PROFILE"),
          _buildSettingCard(
            isFirst: true,
            isLast: true,
            child: _buildSettingTile(
              icon: _isLoggedIn
                  ? CupertinoIcons.person_fill
                  : CupertinoIcons.person,
              title: _isLoggedIn ? "Manage Profile" : "Login & Sync",
              subtitle: _isLoggedIn
                  ? "View and edit your profile"
                  : "Login and sync to backup your data online",
              iconColor: _isLoggedIn
                  ? CupertinoColors.systemIndigo
                  : CupertinoColors.systemBlue,
              showArrow: true,
              onTap: _isLoggedIn
                  ? () => Navigator.pushNamed(context, '/profile')
                  : _showLoginOptions,
            ),
          ),

          _buildSectionHeader("SECURITY"),
          _buildSettingCard(
            isFirst: true,
            child: _buildToggleTile(
              icon: CupertinoIcons.lock_shield,
              title: "App PIN",
              subtitle: _isPinEnabled
                  ? "PIN protection enabled"
                  : "Set up PIN protection",
              value: _isPinEnabled,
              iconColor: CupertinoColors.systemOrange,
              onChanged: (value) {
                if (value) {
                  _showPinSetupDialog();
                } else {
                  _showConfirmationDialog(
                    "Disable PIN",
                    "Are you sure you want to disable PIN protection?",
                    () async {
                      setState(() {
                        _isPinEnabled = false;
                        _currentPin = '';
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('app_pin');
                      await prefs.setBool('pin_enabled', false);
                    },
                  );
                }
              },
            ),
          ),
          _buildSettingCard(
            child: _buildToggleTile(
              icon: CupertinoIcons.lock,
              title: "Biometric Authentication",
              subtitle: "Use fingerprint or face ID",
              value: _biometricEnabled,
              iconColor: CupertinoColors.systemGreen,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
                _saveSettings();
              },
            ),
          ),
          _buildSettingCard(
            isLast: true,
            child: _buildSettingTile(
              icon: CupertinoIcons.lock_rotation,
              title: "Change PIN",
              subtitle: "Update your security PIN",
              iconColor: CupertinoColors.systemIndigo,
              showArrow: true,
              onTap: _isPinEnabled ? _showPinSetupDialog : null,
            ),
          ),

          _buildSectionHeader("DATA & STORAGE"),
          _buildSettingCard(
            isFirst: true,
            child: _buildSettingTile(
              icon: CupertinoIcons.square_arrow_up,
              title: "Import Data",
              subtitle: "Import data from files",
              iconColor: CupertinoColors.systemBlue,
              showArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Import feature coming soon")),
                );
              },
            ),
          ),
          _buildSettingCard(
            child: _buildSettingTile(
              icon: CupertinoIcons.square_arrow_down,
              title: "Export Data",
              subtitle: "Export your projects",
              iconColor: CupertinoColors.systemGreen,
              showArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Export feature coming soon")),
                );
              },
            ),
          ),
          _buildSettingCard(
            isLast: true,
            child: _buildToggleTile(
              icon: CupertinoIcons.cloud_upload,
              title: "Auto Backup",
              subtitle: "Automatically backup to cloud",
              value: _autoBackup,
              iconColor: CupertinoColors.systemTeal,
              onChanged: (value) {
                setState(() => _autoBackup = value);
                _saveSettings();
              },
            ),
          ),

          _buildSectionHeader("APPEARANCE"),
          _buildSettingCard(
            isFirst: true,
            isLast: true,
            child: _buildToggleTile(
              icon: CupertinoIcons.moon,
              title: "Dark Mode",
              subtitle: "Use dark appearance",
              value: _darkMode,
              iconColor: CupertinoColors.systemPurple,
              onChanged: (value) {
                setState(() => _darkMode = value);
                _saveSettings();
              },
            ),
          ),

          _buildSectionHeader("NOTIFICATIONS"),
          _buildSettingCard(
            isFirst: true,
            isLast: true,
            child: _buildToggleTile(
              icon: CupertinoIcons.bell,
              title: "Push Notifications",
              subtitle: "Receive app notifications",
              value: _notifications,
              iconColor: CupertinoColors.systemOrange,
              onChanged: (value) {
                setState(() => _notifications = value);
                _saveSettings();
              },
            ),
          ),

          _buildSectionHeader("SUPPORT"),
          _buildSettingCard(
            isFirst: true,
            child: _buildSettingTile(
              icon: CupertinoIcons.info_circle,
              title: "About",
              subtitle: "App version and info",
              iconColor: CupertinoColors.systemBlue,
              showArrow: true,
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ),
          _buildSettingCard(
            isLast: true,
            child: _buildSettingTile(
              icon: CupertinoIcons.shield,
              title: "Privacy Policy",
              subtitle: "Learn about data privacy",
              iconColor: CupertinoColors.systemGreen,
              showArrow: true,
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
