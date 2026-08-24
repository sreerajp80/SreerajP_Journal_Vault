import 'dart:async';
import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';

/// Phase in a breathing cycle.
enum BreathPhase { inhale, holdInhale, exhale, holdExhale }

extension BreathPhaseExt on BreathPhase {
  String get label {
    switch (this) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.holdInhale:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.holdExhale:
        return 'Hold & Rest';
    }
  }

  String get guidanceText {
    switch (this) {
      case BreathPhase.inhale:
        return 'Breathe in slowly through your nose...';
      case BreathPhase.holdInhale:
        return 'Hold gently at the top...';
      case BreathPhase.exhale:
        return 'Release slowly and completely...';
      case BreathPhase.holdExhale:
        return 'Rest in quiet stillness...';
    }
  }
}

/// An animated, calming visual breathing circle widget with phase guidance and timer.
class BreathingOrbWidget extends StatefulWidget {
  const BreathingOrbWidget({
    super.key,
    required this.technique,
    this.cycles = 2,
    this.onComplete,
  });

  final BreathTechnique technique;
  final int cycles;
  final VoidCallback? onComplete;

  @override
  State<BreathingOrbWidget> createState() => _BreathingOrbWidgetState();
}

class _BreathingOrbWidgetState extends State<BreathingOrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _phaseTimer;

  int _currentCycle = 1;
  BreathPhase _currentPhase = BreathPhase.inhale;
  int _secondsRemaining = 4;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.technique.inhaleSeconds),
    );
    _startCurrentPhase();
  }

  @override
  void didUpdateWidget(covariant BreathingOrbWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.technique != widget.technique ||
        oldWidget.cycles != widget.cycles) {
      _reset();
    }
  }

  void _reset() {
    _phaseTimer?.cancel();
    _currentCycle = 1;
    _isFinished = false;
    _currentPhase = BreathPhase.inhale;
    _animController.duration = Duration(
      seconds: widget.technique.inhaleSeconds,
    );
    _animController.reset();
    _startCurrentPhase();
  }

  void _startCurrentPhase() {
    int durationSeconds = 4;
    switch (_currentPhase) {
      case BreathPhase.inhale:
        durationSeconds = widget.technique.inhaleSeconds;
        _animController.duration = Duration(seconds: durationSeconds);
        _animController.forward(from: 0.0);
        break;
      case BreathPhase.holdInhale:
        durationSeconds = widget.technique.holdInhaleSeconds;
        _animController.value = 1.0;
        break;
      case BreathPhase.exhale:
        durationSeconds = widget.technique.exhaleSeconds;
        _animController.duration = Duration(seconds: durationSeconds);
        _animController.reverse(from: 1.0);
        break;
      case BreathPhase.holdExhale:
        durationSeconds = widget.technique.holdExhaleSeconds;
        _animController.value = 0.0;
        break;
    }

    if (durationSeconds <= 0) {
      _advancePhase();
      return;
    }

    setState(() {
      _secondsRemaining = durationSeconds;
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    if (!mounted) return;

    switch (_currentPhase) {
      case BreathPhase.inhale:
        if (widget.technique.holdInhaleSeconds > 0) {
          _currentPhase = BreathPhase.holdInhale;
        } else {
          _currentPhase = BreathPhase.exhale;
        }
        break;
      case BreathPhase.holdInhale:
        _currentPhase = BreathPhase.exhale;
        break;
      case BreathPhase.exhale:
        if (widget.technique.holdExhaleSeconds > 0) {
          _currentPhase = BreathPhase.holdExhale;
        } else {
          _finishOrNextCycle();
          return;
        }
        break;
      case BreathPhase.holdExhale:
        _finishOrNextCycle();
        return;
    }

    _startCurrentPhase();
  }

  void _finishOrNextCycle() {
    if (_currentCycle < widget.cycles) {
      _currentCycle++;
      _currentPhase = BreathPhase.inhale;
      _startCurrentPhase();
    } else {
      setState(() {
        _isFinished = true;
      });
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isFinished) {
      return Semantics(
        label: 'Breathing practice completed',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Grounded & Present',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = _animController.value;
        final scale = 0.7 + (progress * 0.3); // Scales from 0.7 to 1.0

        return Semantics(
          label: '${_currentPhase.label}, $_secondsRemaining seconds remaining',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cycle $_currentCycle of ${widget.cycles}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer subtle glowing aura
                    Container(
                      width: 220 * scale,
                      height: 220 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(
                          alpha: 0.08 * scale,
                        ),
                      ),
                    ),
                    // Middle pulsing ring
                    Container(
                      width: 180 * scale,
                      height: 180 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.35 * scale,
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Core orb with timer and label
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHighest,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPhase.label.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_secondsRemaining',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _currentPhase.guidanceText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
