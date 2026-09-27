part of 'entry_editor_screen.dart';

/// Where the scan-text flow gets its photo from.
enum _ScanSource {
  /// The phone's own camera app. It applies the maker's processing (noise
  /// reduction, HDR, sharpening), so its photos read far better than frames
  /// from the camera plugin.
  phoneCamera,

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
          .read(entryEditorServiceProvider)
          .addAttachment(_entryId!, picked);
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

  /// Takes the pictures of a just-deleted attachment out of the text, so no
  /// broken image is left behind. The change is auto-saved like any other edit.
  void _removeAttachmentEmbeds(int attachmentId) {
    final offsets = attachmentEmbedOffsets(
      _quillController.document,
      attachmentId,
    );
    if (offsets.isEmpty) return;
    // The caret moves back by one for every picture removed before it, so it
    // never points into a line that no longer exists.
    final caret = _quillController.selection.isValid
        ? _quillController.selection.baseOffset
        : 0;
    final removedBefore = offsets.where((offset) => offset < caret).length;
    // From the end, so the earlier offsets stay valid.
    for (final offset in offsets.reversed) {
      _quillController.replaceText(offset, 1, '', null, ignoreFocus: true);
    }
    final maxOffset = _quillController.document.length - 1;
    _quillController.updateSelection(
      TextSelection.collapsed(
        offset: (caret - removedBefore).clamp(0, maxOffset),
      ),
      ChangeSource.local,
    );
    _rebuild(() => _isDirty = true);
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
          .read(entryEditorServiceProvider)
          .addAttachment(_entryId!, picked);
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
          .read(entryEditorServiceProvider)
          .addAttachment(_entryId!, picked);
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

    // The old drawing is not deleted yet: Undo can put it back. It is
    // removed when the screen closes, if the saved entry no longer shows it.
    if (data.attachmentId > 0 && data.attachmentId != newAttachmentId) {
      _supersededDrawingIds.add(data.attachmentId);
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
      photo = await ExternalHandoffGuard.instance.run(
        () => ImagePicker().pickImage(source: ImageSource.camera),
      );
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

    final sweeper = ref.read(ocrTempFileSweeperProvider);
    try {
      return await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => OcrEnhanceScreen(imagePath: photo!.path),
        ),
      );
    } finally {
      // The camera app wrote this copy into our cache for us; it is not
      // needed once the text has been read.
      unawaited(sweeper.deleteNow(photo.path));
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

    // Clear photos an earlier scan left behind when the app was closed part
    // way. They are plain, unencrypted copies of private pages.
    unawaited(ref.read(ocrTempFileSweeperProvider).sweepStale());

    // The Settings switch decides which camera "Take photo" opens. Off — the
    // default — is the phone's own camera app, which takes the better picture;
    // on keeps every scan inside the app.
    final useInAppCamera =
        widget.imagePicker == null &&
        await ref.read(ocrCameraSourceStoreProvider).read();
    if (!mounted) return;

    final String? pickedResult;
    if (scanSource == _ScanSource.phoneCamera && useInAppCamera) {
      pickedResult = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const OcrCameraScreen()),
      );
    } else if (scanSource != _ScanSource.gallery) {
      if (widget.imagePicker != null) {
        // Preserves test fake injection when testing EntryEditorScreen
        try {
          final picked = await ExternalHandoffGuard.instance.run(
            () => widget.imagePicker!.pickImage(source: ImageSource.camera),
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
        final picked = await ExternalHandoffGuard.instance.run(
          () => picker.pickImage(source: ImageSource.gallery),
        );
        if (picked != null && widget.imagePicker == null) {
          if (!mounted) return;
          final sweeper = ref.read(ocrTempFileSweeperProvider);
          try {
            pickedResult = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => OcrEnhanceScreen(imagePath: picked.path),
              ),
            );
          } finally {
            // The picker's private copy; the user's photo stays in the gallery.
            unawaited(sweeper.deleteNow(picked.path));
          }
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
