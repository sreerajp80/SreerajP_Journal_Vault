part of 'app.dart';

class _FirstLaunchSetupScreen extends ConsumerStatefulWidget {
  const _FirstLaunchSetupScreen();

  @override
  ConsumerState<_FirstLaunchSetupScreen> createState() =>
      _FirstLaunchSetupScreenState();
}

class _FirstLaunchSetupScreenState
    extends ConsumerState<_FirstLaunchSetupScreen> {
  AppLockMode _selected = AppLockMode.phoneLock;
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _error = null);

    if (_selected == AppLockMode.appLock) {
      if (_pin.text.length < 4) {
        setState(() => _error = AppLocalizations.of(context).errorLockPin);
        return;
      }
      if (_pin.text != _confirm.text) {
        setState(
          () => _error = AppLocalizations.of(context).bodyLockPinsDoNotMatch,
        );
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(appLockProvider.notifier)
          .completeFirstLaunchSetup(
            mode: _selected,
            pin: _selected == AppLockMode.appLock ? _pin.text : null,
          );
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(
            context,
          ).errorLockSetupSave(error.toString());
          _busy = false;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAppLock = _selected == AppLockMode.appLock;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleLockSetup)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bodyLockSetup),
            const SizedBox(height: 16),
            RadioGroup<AppLockMode>(
              groupValue: _selected,
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
              child: Column(
                children: [
                  RadioListTile<AppLockMode>(
                    key: const Key('first-launch-mode-phone'),
                    value: AppLockMode.phoneLock,
                    title: Text(l10n.labelLockModePhone),
                    subtitle: Text(l10n.descLockModePhone),
                  ),
                  RadioListTile<AppLockMode>(
                    key: const Key('first-launch-mode-app'),
                    value: AppLockMode.appLock,
                    title: Text(l10n.labelLockModeApp),
                    subtitle: Text(l10n.descLockModeApp),
                  ),
                ],
              ),
            ),
            if (isAppLock) ...[
              const SizedBox(height: 8),
              TextField(
                key: const Key('first-launch-pin-field'),
                controller: _pin,
                obscureText: true,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(labelText: l10n.labelLockPin),
              ),
              TextField(
                key: const Key('first-launch-pin-confirm-field'),
                controller: _confirm,
                obscureText: true,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  labelText: l10n.labelLockConfirmPin,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('first-launch-continue-button'),
              onPressed: _busy ? null : _continue,
              child: Text(
                _busy ? l10n.bodyLockSettingUp : l10n.actionCommonContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Force-set PIN when app_lock has no credential ───────────────────────

class _AppLockPinSetupScreen extends ConsumerStatefulWidget {
  const _AppLockPinSetupScreen();

  @override
  ConsumerState<_AppLockPinSetupScreen> createState() =>
      _AppLockPinSetupScreenState();
}

class _AppLockPinSetupScreenState
    extends ConsumerState<_AppLockPinSetupScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_pin.text.length < 4) {
      setState(() => _error = AppLocalizations.of(context).errorLockPin);
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(
        () => _error = AppLocalizations.of(context).bodyLockPinsDoNotMatch,
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(appLockProvider.notifier).setPin(_pin.text);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(
            context,
          ).errorLockPinSave(error.toString());
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleLockPinSetup)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bodyLockPinSetup),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pin-setup-field'),
              controller: _pin,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.labelLockPin),
            ),
            TextField(
              key: const Key('pin-setup-confirm-field'),
              controller: _confirm,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.labelLockConfirmPin),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('pin-setup-save-button'),
              onPressed: _busy ? null : _save,
              child: Text(
                _busy ? l10n.bodyCommonSaving : l10n.actionCommonSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lock gate ────────────────────────────────────────────────────────────

class _LockGateScreen extends ConsumerStatefulWidget {
  const _LockGateScreen();

  @override
  ConsumerState<_LockGateScreen> createState() => _LockGateScreenState();
}

class _LockGateScreenState extends ConsumerState<_LockGateScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _pinVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlockBiometric() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(appLockProvider.notifier)
        .unlockWithBiometric();
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case BiometricAuthResult.success:
          _error = null;
          break;
        case BiometricAuthResult.failed:
          _error = AppLocalizations.of(context).errorLockAuth;
          break;
        case BiometricAuthResult.unavailable:
          _error = AppLocalizations.of(context).bodyLockAuthUnavailable;
          break;
      }
    });
  }

  Future<void> _unlockPin() async {
    if (_busy) return;
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).bodyLockEnterPin);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref.read(appLockProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) {
        _error = AppLocalizations.of(context).bodyLockIncorrectPin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lockState = ref.watch(appLockProvider);
    final isAppLock = lockState.mode == AppLockMode.appLock;
    final modeLabel = isAppLock
        ? l10n.labelLockModeApp
        : l10n.labelLockModePhone;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                colors.primary.withValues(alpha: 0.10),
                colors.surface,
              ),
              colors.surface,
              Color.alphaBlend(
                colors.primary.withValues(alpha: 0.06),
                colors.surfaceContainerHighest,
              ),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _LockGateEntrance(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LockBadge(),
                        const SizedBox(height: 28),
                        Text(
                          l10n.labelLockGateHeadline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.descLockGate,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          child: _LockModeChip(
                            label: modeLabel,
                            icon: isAppLock
                                ? Icons.pin_rounded
                                : Icons.phonelink_lock_rounded,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _LockCard(
                          child: isAppLock
                              ? _buildAppLockControls(context, l10n)
                              : _buildPhoneLockControls(context, l10n),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _error == null
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _LockErrorPill(message: _error!),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLockControls(BuildContext context, AppLocalizations l10n) {
    return _LockActionButton(
      buttonKey: const Key('phone-lock-unlock-button'),
      icon: Icons.fingerprint_rounded,
      label: l10n.actionLockUnlockWithPhone,
      busy: _busy,
      onPressed: _unlockBiometric,
    );
  }

  Widget _buildAppLockControls(BuildContext context, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('app-lock-pin-field'),
          controller: _pinController,
          obscureText: !_pinVisible,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            letterSpacing: _pinVisible ? 6 : 10,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: l10n.labelLockPin,
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            suffixIcon: IconButton(
              tooltip: _pinVisible
                  ? l10n.tooltipLockGateHidePin
                  : l10n.tooltipLockGateShowPin,
              icon: Icon(
                _pinVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () => setState(() => _pinVisible = !_pinVisible),
            ),
          ),
          onSubmitted: (_) => _unlockPin(),
        ),
        const SizedBox(height: 16),
        _LockActionButton(
          buttonKey: const Key('app-lock-unlock-button'),
          icon: Icons.lock_open_rounded,
          label: l10n.actionCommonUnlock,
          busy: _busy,
          onPressed: _unlockPin,
        ),
      ],
    );
  }
}
