import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Ayarlar ve hesap — satırlar yer tutucu; oturum / metinler sonra bağlanacak.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppPalette.charcoal,
      appBar: AppBar(
        backgroundColor: AppPalette.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ayarlar',
          style: tt.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            subtitle: 'Hatırlatıcılar ve özetler',
            onTap: () => _soon(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Gizlilik',
            subtitle: 'Veri ve görünürlük',
            onTap: () => _soon(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Gizlilik politikası',
            onTap: () => _soon(context),
          ),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            title: 'Kullanım koşulları',
            onTap: () => _soon(context),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Yardım ve destek',
            onTap: () => _soon(context),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Hakkında',
            subtitle: 'Sürüm 1.0 (önizleme)',
            onTap: () => _soon(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: () => _soon(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Çıkış yap'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: AppPalette.tealNav, size: 24),
      title: Text(
        title,
        style: tt.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: tt.bodySmall?.copyWith(color: AppPalette.mutedNav),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppPalette.mutedNav.withValues(alpha: 0.7),
      ),
      onTap: onTap,
    );
  }
}
