import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_backdrop.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _baseCtrl;
  late final TextEditingController _tokenCtrl;
  bool _obscure = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsService>();
    _baseCtrl = TextEditingController(text: s.baseUrl);
    _tokenCtrl = TextEditingController(text: s.apiToken);
  }

  @override
  void dispose() {
    _baseCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = context.read<SettingsService>();
    await settings.update(
      baseUrl: _baseCtrl.text,
      apiToken: _tokenCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    return AmbientBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('我的')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: [
            _sectionTitle('后端连接'),
            _card(
              children: [
                TextField(
                  controller: _baseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://example.hostc.app',
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _tokenCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'API Token (Bearer)',
                    hintText: '开发 Token，勿提交到公开仓库',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('保存设置'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('设备'),
            _card(
              children: [
                const Text(
                  '设备 ID',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  settings.deviceId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '安卓安装包为原生 APK；Windows 为原生桌面程序（.exe）。'
                  '真机联调请把 Base URL 改成能访问后端的地址，不要用对方电脑上的 127.0.0.1。',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    height: 1.45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
