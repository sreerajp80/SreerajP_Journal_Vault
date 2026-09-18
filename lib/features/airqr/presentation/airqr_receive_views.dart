part of 'airqr_receive_screen.dart';

extension _AirqrReceiveScreenStatePart1 on _AirqrReceiveScreenState {
  Future<void> _applyPayload(AirqrPayload payload) async {
    // Captured before the first await so no stale context is touched later.
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    _rebuild(() {
      _isImporting = true;
    });

    try {
      if (payload.kind == AirqrConstants.kindSettings) {
        await ref.read(airqrSettingsServiceProvider).applySettings(payload);
        if (!mounted) return;
        _rebuild(() {
          _isImporting = false;
          _importSuccessMessage = l10n.bodyAirqrSettingsApplied;
        });
      } else if (payload.kind == AirqrConstants.kindEntry) {
        final db = ref.read(appDatabaseProvider);
        final journals = await db.journalsDao.getAllJournals();
        final journalId = journals.isNotEmpty ? journals.first.id : 1;
        final title =
            payload.data['title'] as String? ??
            l10n.descAirqrImportedEntryTitle;
        final contentJson = payload.data['contentJson'] as String? ?? '';
        final plainText = payload.data['plainText'] as String? ?? '';
        final mood = payload.data['mood'] as String?;

        final entryId = await db.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journalId,
            title: Value(title),
            contentJson: Value(contentJson),
            plainText: Value(plainText),
          ),
        );

        if (mood != null && mood.isNotEmpty) {
          final moodInt = int.tryParse(mood);
          if (moodInt != null && moodInt >= 1 && moodInt <= 5) {
            await db.entryMoodsDao.upsertMood(
              EntryMoodsCompanion.insert(entryId: entryId, mood: moodInt),
            );
          }
        }

        if (!mounted) return;
        _rebuild(() {
          _isImporting = false;
          _importSuccessMessage = l10n.bodyAirqrEntryImported;
        });
      } else if (payload.kind == AirqrConstants.kindJournal) {
        final db = ref.read(appDatabaseProvider);
        final title =
            payload.data['title'] as String? ??
            l10n.descAirqrImportedJournalTitle;
        final desc = payload.data['description'] as String?;
        final journalId = await db.journalsDao.createJournal(
          JournalsCompanion.insert(title: title, description: Value(desc)),
        );

        final entries = payload.data['entries'] as List<dynamic>? ?? [];
        for (final e in entries) {
          if (e is Map<String, dynamic>) {
            await db.entriesDao.createEntry(
              EntriesCompanion.insert(
                journalId: journalId,
                title: Value(
                  e['title'] as String? ?? l10n.descAirqrImportedEntryTitle,
                ),
                contentJson: Value(e['contentJson'] as String? ?? ''),
                plainText: Value(e['plainText'] as String? ?? ''),
              ),
            );
          }
        }

        if (!mounted) return;
        _rebuild(() {
          _isImporting = false;
          _importSuccessMessage = l10n.bodyAirqrJournalImported;
        });
      }
    } catch (e) {
      AppLogger.warning(
        'airqr: import of a received payload failed',
        error: AppLogger.redact(e),
      );
      if (!mounted) return;
      _rebuild(() {
        _isImporting = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorAirqrImport)));
    }
  }

  Widget _buildScanningView(
    AirqrReceiveController controller,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Camera scanner
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final raw = barcode.rawValue;
                    if (raw != null && raw.isNotEmpty) {
                      controller.onScan(raw);
                    }
                  }
                },
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.flash_on_rounded),
                      tooltip: l10n.tooltipToggleTorch,
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.cameraswitch_rounded),
                      tooltip: l10n.tooltipSwitchCamera,
                      onPressed: () => _scannerController.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live Frame Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.totalFrames != null
                        ? l10n.bodyAirqrFramesReceived(
                            controller.receivedCount,
                            controller.totalFrames!,
                          )
                        : l10n.bodyAirqrAlignCamera,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(controller.progress * 100).toInt()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 8,
                ),
              ),
              if (controller.missingFrames.isNotEmpty &&
                  controller.missingFrames.length <= 10) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.bodyAirqrMissingFrames(
                    controller.missingFrames.join(', '),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeedCodeView(
    AirqrReceiveController controller,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.key_rounded,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.titleAirqrEnterCode,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.descAirqrEnterCode,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeTextController,
              decoration: InputDecoration(
                labelText: l10n.labelSyncPairingCode,
                hintText: l10n.labelSyncPairingCodeHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                final text = _codeTextController.text.trim();
                if (text.isNotEmpty) {
                  controller.submitCode(AirqrCodec.normalizeCode(text));
                }
              },
              child: Text(l10n.actionAirqrDecrypt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(
    AirqrPayload payload,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (_importSuccessMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                _importSuccessMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCommonDone),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.green,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.titleAirqrVerified,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Payload Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payload.titleIn(l10n),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.descAirqrPayloadType(payload.kindLabelIn(l10n))),
                if (payload.kind == AirqrConstants.kindSettings) ...[
                  const Divider(height: 16),
                  Text(
                    l10n.descAirqrPayloadTheme('${payload.data['themeMode']}'),
                  ),
                  if (payload.data['accentColorArgb'] != null)
                    Text(
                      l10n.descAirqrPayloadAccent(
                        '#${(payload.data['accentColorArgb'] as int).toRadixString(16).padLeft(8, '0').toUpperCase()}',
                      ),
                    ),
                  Text(
                    l10n.descAirqrPayloadTemplates(
                      (payload.data['templates'] as List?)?.length ?? 0,
                    ),
                  ),
                  Text(
                    l10n.descAirqrPayloadTags(
                      (payload.data['tags'] as List?)?.length ?? 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: _isImporting ? null : () => _applyPayload(payload),
          icon: _isImporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_done_rounded),
          label: Text(
            payload.kind == AirqrConstants.kindSettings
                ? l10n.actionAirqrApplySettings
                : l10n.actionAirqrImport,
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
