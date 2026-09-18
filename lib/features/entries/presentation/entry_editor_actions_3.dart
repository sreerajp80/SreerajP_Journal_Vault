part of 'entry_editor_screen.dart';

/// Where the scan-text flow gets its photo from.
enum _ScanSource {
  /// The phone's own camera app. It applies the maker's processing (noise
  /// reduction, HDR, sharpening), so its photos read far better than frames
  /// from the camera plugin.
  phoneCamera,

  /// The camera built into this app. The photo never leaves the app.
  inAppCamera,

  /// A photo already on the device.
  gallery,
}

extension _EntryEditorScreenStatePart3 on _EntryEditorScreenState {
  /// Picks an image and puts it into the body of the entry.
  ///
  /// The picture is imported exactly like any other attachment — encrypted,
  /// with a row in `Attachments` — and the embed holds only that row's id. So
  /// an inline image is backed up, synced and exported by the paths that
  /// already exist, and the document JSON never carries image bytes.
  Future<void> _insertImage() async {
    if (_entryId == null) return;
    if (!await _ensureAttachmentPermission()) return;

    final picked = await ref
        .read(attachmentPickerServiceProvider)
        .pickAttachment();
    if (picked == null || !mounted) return;

    if (!picked.mimeType.startsWith('image/')) {
      _showMessage(AppLocalizations.of(context).bodyEntryNotAnImage);
      return;
    }

    final int attachmentId;
    try {
      attachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      // The import service has already removed the encrypted file it wrote, so
      // there is nothing left behind to clean up here.
      if (mounted) {
        _showMessage(AppLocalizations.of(context).errorEntryImageAdd);
      }
      return;
    }

    if (!mounted) return;

    final embed = VaultImageEmbed.create(
      attachmentId: attachmentId,
      fileName: picked.fileName,
    );
    final index = _quillController.selection.baseOffset;
    // Insert the embed, then a trailing newline — without it an image at the
    // end of the document has no editable line after it and the cursor gets
    // trapped, the same as for tables and callouts above.
    _quillController.replaceText(index, 0, embed, null);
    _quillController.replaceText(
      index + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 2),
    );

    // The picture is also a normal attachment, so the tray below has to know.
    _rebuild(() => _attachmentRefreshToken++);
  }

  /// Opens the drawing canvas, saves the sketch as an encrypted attachment,
  /// and embeds it into the entry.
  Future<void> _insertDrawing() async {
    if (_entryId == null) return;

    final result = await Navigator.of(context).push<DrawingCanvasResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const DrawingCanvasScreen(),
      ),
    );

    if (result == null || !mounted) return;

    final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    final picked = PickedAttachmentData(
      fileName: fileName,
      bytes: result.pngBytes,
      mimeType: 'image/png',
    );

    final int attachmentId;
    try {
      attachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).errorDrawingSave);
      }
      return;
    }

    if (!mounted) return;

    final embed = DrawingEmbed.create(
      attachmentId: attachmentId,
      fileName: fileName,
      strokeJson: result.strokeJson,
    );

    final index = _quillController.selection.baseOffset;
    _quillController.replaceText(index, 0, embed, null);
    _quillController.replaceText(
      index + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 2),
    );

    _rebuild(() {
      _attachmentRefreshToken++;
      _isDirty = true;
    });
  }

  /// Re-opens an existing drawing in the canvas screen to edit its vector strokes.
  Future<void> _editDrawing(DrawingEmbedData data, int documentOffset) async {
    if (_entryId == null) return;

    final result = await Navigator.of(context).push<DrawingCanvasResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DrawingCanvasScreen(initialStrokeJson: data.strokeJson),
      ),
    );

    if (result == null || !mounted) return;

    final fileName = data.fileName.isNotEmpty
        ? data.fileName
        : 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';

    final picked = PickedAttachmentData(
      fileName: fileName,
      bytes: result.pngBytes,
      mimeType: 'image/png',
    );

    final int newAttachmentId;
    try {
      newAttachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).errorDrawingSave);
      }
      return;
    }

    if (!mounted) return;

    final newEmbed = DrawingEmbed.create(
      attachmentId: newAttachmentId,
      fileName: fileName,
      widthFactor: data.widthFactor,
      strokeJson: result.strokeJson,
    );

    _quillController.replaceText(
      documentOffset,
      1,
      newEmbed,
      null,
      ignoreFocus: true,
    );

    // Clean up old attachment row and file if different
    if (data.attachmentId > 0 && data.attachmentId != newAttachmentId) {
      try {
        final db = ref.read(appDatabaseProvider);
        final oldAttachment = await db.attachmentsDao.getAttachmentById(
          data.attachmentId,
        );
        await db.attachmentsDao.deleteAttachmentById(data.attachmentId);
        final crypto = ref.read(attachmentCryptoStorageProvider);
        await crypto.deleteStoredFile(oldAttachment.encryptedPath);
      } catch (_) {}
    }

    _rebuild(() {
      _attachmentRefreshToken++;
      _isDirty = true;
    });
  }

  /// Takes the photo with the phone's own camera app, then opens the enhance
  /// screen on it. Returns the recognised text, or `null` when cancelled.
  ///
  /// Falls back to the in-app camera when the camera app cannot be opened —
  /// for example no camera app is installed, or camera access was refused.
  Future<String?> _scanWithPhoneCamera(AppLocalizations l10n) async {
    XFile? photo;
    try {
      // No size limits: the full photo is what makes small print readable.
      photo = await ImagePicker().pickImage(source: ImageSource.camera);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: phone camera unavailable, using in-app camera',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return null;
      _showMessage(l10n.errorOcrPhoneCameraUnavailable);
      return Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const OcrCameraScreen()),
      );
    }

    if (photo == null || !mounted) return null;

    try {
      return await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => OcrEnhanceScreen(imagePath: photo!.path),
        ),
      );
    } finally {
      // The camera app wrote this copy into our cache for us; it is not
      // needed once the text has been read.
      try {
        final file = File(photo.path);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    }
  }

  Future<void> _scanTextFromPhoto() async {
    final l10n = AppLocalizations.of(context);
    final scanSource = await showModalBottomSheet<_ScanSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('entry-ocr-source-phone-camera'),
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.labelEntryEditorScanSourceCamera),
              onTap: () => Navigator.pop(sheetContext, _ScanSource.phoneCamera),
            ),
            ListTile(
              key: const Key('entry-ocr-source-in-app-camera'),
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(l10n.actionOcrInAppCamera),
              onTap: () => Navigator.pop(sheetContext, _ScanSource.inAppCamera),
            ),
            ListTile(
              key: const Key('entry-ocr-source-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.labelEntryEditorScanSourceGallery),
              onTap: () => Navigator.pop(sheetContext, _ScanSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (scanSource == null || !mounted) return;

    final String? pickedResult;
    if (scanSource == _ScanSource.inAppCamera && widget.imagePicker == null) {
      pickedResult = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const OcrCameraScreen()),
      );
    } else if (scanSource != _ScanSource.gallery) {
      if (widget.imagePicker != null) {
        // Preserves test fake injection when testing EntryEditorScreen
        try {
          final picked = await widget.imagePicker!.pickImage(
            source: ImageSource.camera,
          );
          pickedResult = picked?.path;
        } catch (e, stackTrace) {
          AppLogger.error(
            'EntryEditorScreen: image pick failed',
            error: e,
            stackTrace: stackTrace,
          );
          if (mounted) _showMessage(l10n.errorEntryEditorOcr);
          return;
        }
      } else {
        pickedResult = await _scanWithPhoneCamera(l10n);
      }
    } else {
      final picker = widget.imagePicker ?? ImagePicker();
      try {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null && widget.imagePicker == null) {
          if (!mounted) return;
          pickedResult = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) => OcrEnhanceScreen(imagePath: picked.path),
            ),
          );
        } else {
          pickedResult = picked?.path;
        }
      } catch (e, stackTrace) {
        AppLogger.error(
          'EntryEditorScreen: gallery image pick failed',
          error: e,
          stackTrace: stackTrace,
        );
        if (mounted) _showMessage(l10n.errorEntryEditorOcr);
        return;
      }
    }

    if (pickedResult == null || !mounted) return;

    // If pickedResult is recognized text returned directly from OcrEnhanceScreen
    if (!File(pickedResult).existsSync()) {
      if (pickedResult.trim().isEmpty) {
        _showMessage(l10n.descEntryEditorOcrNoTextFound);
      } else {
        _insertExtractedText(pickedResult);
      }
      return;
    }

    final pickedPath = pickedResult;

    // --- Crop & rotate step ---
    final theme = Theme.of(context);
    String? croppedPath;
    try {
      final imageEditService = ref.read(imageEditServiceProvider);
      croppedPath = await imageEditService.cropAndRotate(
        sourcePath: pickedPath,
        toolbarTitle: l10n.titleEntryEditorCropImage,
        toolbarColor: theme.colorScheme.surface,
        toolbarWidgetColor: theme.colorScheme.onSurface,
        statusBarBrightness: theme.brightness,
        activeControlColor: theme.colorScheme.primary,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: image crop failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(l10n.errorEntryEditorCropImage);
      // Clean up the picked file before returning.
      try {
        File(pickedPath).deleteSync();
      } catch (_) {}
      return;
    }

    if (croppedPath == null || !mounted) {
      // User cancelled the cropper — clean up and stop.
      try {
        File(pickedPath).deleteSync();
      } catch (_) {}
      return;
    }

    // The path to send to OCR: the cropped file if different, else the original.
    final ocrImagePath = croppedPath;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.descEntryEditorOcrScanning),
          duration: const Duration(seconds: 2),
        ),
      );

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final extractedText = await ocrService.extractTextFromImage(ocrImagePath);
      if (!mounted) return;

      if (extractedText.isEmpty) {
        _showMessage(l10n.descEntryEditorOcrNoTextFound);
        return;
      }

      _insertExtractedText(extractedText);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: OCR extraction failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(l10n.errorEntryEditorOcr);
    } finally {
      // Clean up temporary image files.
      for (final path in {pickedPath, ocrImagePath}) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (_) {}
      }
    }
  }

  /// Opens the dictation sheet and puts the spoken text at the caret.
  Future<void> _dictate() async {
    final text = await showDictationSheet(context);
    if (text == null || !mounted) return;
    _insertExtractedText(_withLeadingSpace(text));
  }

  /// Adds a space before [text] when the caret sits right after a word, so
  /// dictated text does not run into what was already typed.
  String _withLeadingSpace(String text) {
    final selection = _quillController.selection;
    if (!selection.isValid || selection.start <= 0) return text;
    final plain = _quillController.document.toPlainText();
    if (selection.start > plain.length) return text;
    final before = plain[selection.start - 1];
    return before.trim().isEmpty ? text : ' $text';
  }

  void _insertExtractedText(String extractedText) {
    if (extractedText.isEmpty) return;
    final selection = _quillController.selection;
    final int index;
    final int length;
    if (selection.isValid && selection.baseOffset >= 0) {
      index = selection.baseOffset;
      length = selection.isCollapsed
          ? 0
          : (selection.extentOffset - selection.baseOffset).abs();
    } else {
      index = _quillController.document.length - 1;
      length = 0;
    }

    _quillController.replaceText(
      index,
      length,
      extractedText,
      TextSelection.collapsed(offset: index + extractedText.length),
    );

    _rebuild(() => _isDirty = true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
