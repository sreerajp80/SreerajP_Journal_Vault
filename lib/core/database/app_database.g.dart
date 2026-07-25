// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$JournalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  JournalsDaoManager get managers => JournalsDaoManager(this);
}

class JournalsDaoManager {
  final _$JournalsDaoMixin _db;
  JournalsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
}

mixin _$EntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  EntriesDaoManager get managers => EntriesDaoManager(this);
}

class EntriesDaoManager {
  final _$EntriesDaoMixin _db;
  EntriesDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
}

mixin _$TagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $EntryTagsTable get entryTags => attachedDatabase.entryTags;
  TagsDaoManager get managers => TagsDaoManager(this);
}

class TagsDaoManager {
  final _$TagsDaoMixin _db;
  TagsDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$EntryTagsTableTableManager get entryTags =>
      $$EntryTagsTableTableManager(_db.attachedDatabase, _db.entryTags);
}

mixin _$AttachmentTextsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  $AttachmentTextsTable get attachmentTexts => attachedDatabase.attachmentTexts;
  AttachmentTextsDaoManager get managers => AttachmentTextsDaoManager(this);
}

class AttachmentTextsDaoManager {
  final _$AttachmentTextsDaoMixin _db;
  AttachmentTextsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
  $$AttachmentTextsTableTableManager get attachmentTexts =>
      $$AttachmentTextsTableTableManager(
        _db.attachedDatabase,
        _db.attachmentTexts,
      );
}

mixin _$BacklinksDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $BacklinksTable get backlinks => attachedDatabase.backlinks;
  BacklinksDaoManager get managers => BacklinksDaoManager(this);
}

class BacklinksDaoManager {
  final _$BacklinksDaoMixin _db;
  BacklinksDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$BacklinksTableTableManager get backlinks =>
      $$BacklinksTableTableManager(_db.attachedDatabase, _db.backlinks);
}

mixin _$EntryRevisionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $EntryRevisionsTable get entryRevisions => attachedDatabase.entryRevisions;
  EntryRevisionsDaoManager get managers => EntryRevisionsDaoManager(this);
}

class EntryRevisionsDaoManager {
  final _$EntryRevisionsDaoMixin _db;
  EntryRevisionsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$EntryRevisionsTableTableManager get entryRevisions =>
      $$EntryRevisionsTableTableManager(
        _db.attachedDatabase,
        _db.entryRevisions,
      );
}

mixin _$VoiceNotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $VoiceNotesTable get voiceNotes => attachedDatabase.voiceNotes;
  VoiceNotesDaoManager get managers => VoiceNotesDaoManager(this);
}

class VoiceNotesDaoManager {
  final _$VoiceNotesDaoMixin _db;
  VoiceNotesDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$VoiceNotesTableTableManager get voiceNotes =>
      $$VoiceNotesTableTableManager(_db.attachedDatabase, _db.voiceNotes);
}

mixin _$BackupLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BackupLogsTable get backupLogs => attachedDatabase.backupLogs;
  BackupLogsDaoManager get managers => BackupLogsDaoManager(this);
}

class BackupLogsDaoManager {
  final _$BackupLogsDaoMixin _db;
  BackupLogsDaoManager(this._db);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db.attachedDatabase, _db.backupLogs);
}

mixin _$SearchPresetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SearchPresetsTable get searchPresets => attachedDatabase.searchPresets;
  SearchPresetsDaoManager get managers => SearchPresetsDaoManager(this);
}

class SearchPresetsDaoManager {
  final _$SearchPresetsDaoMixin _db;
  SearchPresetsDaoManager(this._db);
  $$SearchPresetsTableTableManager get searchPresets =>
      $$SearchPresetsTableTableManager(_db.attachedDatabase, _db.searchPresets);
}

mixin _$AttachmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  AttachmentsDaoManager get managers => AttachmentsDaoManager(this);
}

class AttachmentsDaoManager {
  final _$AttachmentsDaoMixin _db;
  AttachmentsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
}

mixin _$AppSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  AppSettingsDaoManager get managers => AppSettingsDaoManager(this);
}

class AppSettingsDaoManager {
  final _$AppSettingsDaoMixin _db;
  AppSettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}

mixin _$AppSecurityDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSecurityTable get appSecurity => attachedDatabase.appSecurity;
  AppSecurityDaoManager get managers => AppSecurityDaoManager(this);
}

class AppSecurityDaoManager {
  final _$AppSecurityDaoMixin _db;
  AppSecurityDaoManager(this._db);
  $$AppSecurityTableTableManager get appSecurity =>
      $$AppSecurityTableTableManager(_db.attachedDatabase, _db.appSecurity);
}

mixin _$JournalTagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $TagsTable get tags => attachedDatabase.tags;
  $JournalTagsTable get journalTags => attachedDatabase.journalTags;
  JournalTagsDaoManager get managers => JournalTagsDaoManager(this);
}

class JournalTagsDaoManager {
  final _$JournalTagsDaoMixin _db;
  JournalTagsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$JournalTagsTableTableManager get journalTags =>
      $$JournalTagsTableTableManager(_db.attachedDatabase, _db.journalTags);
}

mixin _$SyncMetadataDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncMetadataTable get syncMetadata => attachedDatabase.syncMetadata;
  SyncMetadataDaoManager get managers => SyncMetadataDaoManager(this);
}

class SyncMetadataDaoManager {
  final _$SyncMetadataDaoMixin _db;
  SyncMetadataDaoManager(this._db);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db.attachedDatabase, _db.syncMetadata);
}

mixin _$SyncConflictsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncConflictsTable get syncConflicts => attachedDatabase.syncConflicts;
  SyncConflictsDaoManager get managers => SyncConflictsDaoManager(this);
}

class SyncConflictsDaoManager {
  final _$SyncConflictsDaoMixin _db;
  SyncConflictsDaoManager(this._db);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db.attachedDatabase, _db.syncConflicts);
}

mixin _$SyncLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncLogsTable get syncLogs => attachedDatabase.syncLogs;
  SyncLogsDaoManager get managers => SyncLogsDaoManager(this);
}

class SyncLogsDaoManager {
  final _$SyncLogsDaoMixin _db;
  SyncLogsDaoManager(this._db);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db.attachedDatabase, _db.syncLogs);
}

mixin _$AutoLockProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $AutoLockProfilesTable get autoLockProfiles =>
      attachedDatabase.autoLockProfiles;
  AutoLockProfilesDaoManager get managers => AutoLockProfilesDaoManager(this);
}

class AutoLockProfilesDaoManager {
  final _$AutoLockProfilesDaoMixin _db;
  AutoLockProfilesDaoManager(this._db);
  $$AutoLockProfilesTableTableManager get autoLockProfiles =>
      $$AutoLockProfilesTableTableManager(
        _db.attachedDatabase,
        _db.autoLockProfiles,
      );
}

mixin _$AttachmentLocksDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  $AttachmentLocksTable get attachmentLocks => attachedDatabase.attachmentLocks;
  AttachmentLocksDaoManager get managers => AttachmentLocksDaoManager(this);
}

class AttachmentLocksDaoManager {
  final _$AttachmentLocksDaoMixin _db;
  AttachmentLocksDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
  $$AttachmentLocksTableTableManager get attachmentLocks =>
      $$AttachmentLocksTableTableManager(
        _db.attachedDatabase,
        _db.attachmentLocks,
      );
}

mixin _$SecurityEventsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SecurityEventsTable get securityEvents => attachedDatabase.securityEvents;
  SecurityEventsDaoManager get managers => SecurityEventsDaoManager(this);
}

class SecurityEventsDaoManager {
  final _$SecurityEventsDaoMixin _db;
  SecurityEventsDaoManager(this._db);
  $$SecurityEventsTableTableManager get securityEvents =>
      $$SecurityEventsTableTableManager(
        _db.attachedDatabase,
        _db.securityEvents,
      );
}

mixin _$EntryMoodsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $EntriesTable get entries => attachedDatabase.entries;
  $EntryMoodsTable get entryMoods => attachedDatabase.entryMoods;
  EntryMoodsDaoManager get managers => EntryMoodsDaoManager(this);
}

class EntryMoodsDaoManager {
  final _$EntryMoodsDaoMixin _db;
  EntryMoodsDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$EntryMoodsTableTableManager get entryMoods =>
      $$EntryMoodsTableTableManager(_db.attachedDatabase, _db.entryMoods);
}

class $JournalsTable extends Journals with TableInfo<$JournalsTable, Journal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _credentialReferenceMeta =
      const VerificationMeta('credentialReference');
  @override
  late final GeneratedColumn<String> credentialReference =
      GeneratedColumn<String>(
        'credential_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _passwordSaltBase64Meta =
      const VerificationMeta('passwordSaltBase64');
  @override
  late final GeneratedColumn<String> passwordSaltBase64 =
      GeneratedColumn<String>(
        'password_salt_base64',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _passwordVerifierBase64Meta =
      const VerificationMeta('passwordVerifierBase64');
  @override
  late final GeneratedColumn<String> passwordVerifierBase64 =
      GeneratedColumn<String>(
        'password_verifier_base64',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _passwordIterationsMeta =
      const VerificationMeta('passwordIterations');
  @override
  late final GeneratedColumn<int> passwordIterations = GeneratedColumn<int>(
    'password_iterations',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    isLocked,
    credentialReference,
    passwordSaltBase64,
    passwordVerifierBase64,
    passwordIterations,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Journal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('credential_reference')) {
      context.handle(
        _credentialReferenceMeta,
        credentialReference.isAcceptableOrUnknown(
          data['credential_reference']!,
          _credentialReferenceMeta,
        ),
      );
    }
    if (data.containsKey('password_salt_base64')) {
      context.handle(
        _passwordSaltBase64Meta,
        passwordSaltBase64.isAcceptableOrUnknown(
          data['password_salt_base64']!,
          _passwordSaltBase64Meta,
        ),
      );
    }
    if (data.containsKey('password_verifier_base64')) {
      context.handle(
        _passwordVerifierBase64Meta,
        passwordVerifierBase64.isAcceptableOrUnknown(
          data['password_verifier_base64']!,
          _passwordVerifierBase64Meta,
        ),
      );
    }
    if (data.containsKey('password_iterations')) {
      context.handle(
        _passwordIterationsMeta,
        passwordIterations.isAcceptableOrUnknown(
          data['password_iterations']!,
          _passwordIterationsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Journal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Journal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      credentialReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_reference'],
      ),
      passwordSaltBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt_base64'],
      ),
      passwordVerifierBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_verifier_base64'],
      ),
      passwordIterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}password_iterations'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JournalsTable createAlias(String alias) {
    return $JournalsTable(attachedDatabase, alias);
  }
}

class Journal extends DataClass implements Insertable<Journal> {
  final int id;
  final String title;
  final String? description;
  final bool isLocked;
  final String? credentialReference;
  final String? passwordSaltBase64;
  final String? passwordVerifierBase64;
  final int? passwordIterations;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Journal({
    required this.id,
    required this.title,
    this.description,
    required this.isLocked,
    this.credentialReference,
    this.passwordSaltBase64,
    this.passwordVerifierBase64,
    this.passwordIterations,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || credentialReference != null) {
      map['credential_reference'] = Variable<String>(credentialReference);
    }
    if (!nullToAbsent || passwordSaltBase64 != null) {
      map['password_salt_base64'] = Variable<String>(passwordSaltBase64);
    }
    if (!nullToAbsent || passwordVerifierBase64 != null) {
      map['password_verifier_base64'] = Variable<String>(
        passwordVerifierBase64,
      );
    }
    if (!nullToAbsent || passwordIterations != null) {
      map['password_iterations'] = Variable<int>(passwordIterations);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalsCompanion toCompanion(bool nullToAbsent) {
    return JournalsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isLocked: Value(isLocked),
      credentialReference: credentialReference == null && nullToAbsent
          ? const Value.absent()
          : Value(credentialReference),
      passwordSaltBase64: passwordSaltBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordSaltBase64),
      passwordVerifierBase64: passwordVerifierBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordVerifierBase64),
      passwordIterations: passwordIterations == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordIterations),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Journal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Journal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      credentialReference: serializer.fromJson<String?>(
        json['credentialReference'],
      ),
      passwordSaltBase64: serializer.fromJson<String?>(
        json['passwordSaltBase64'],
      ),
      passwordVerifierBase64: serializer.fromJson<String?>(
        json['passwordVerifierBase64'],
      ),
      passwordIterations: serializer.fromJson<int?>(json['passwordIterations']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isLocked': serializer.toJson<bool>(isLocked),
      'credentialReference': serializer.toJson<String?>(credentialReference),
      'passwordSaltBase64': serializer.toJson<String?>(passwordSaltBase64),
      'passwordVerifierBase64': serializer.toJson<String?>(
        passwordVerifierBase64,
      ),
      'passwordIterations': serializer.toJson<int?>(passwordIterations),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Journal copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? isLocked,
    Value<String?> credentialReference = const Value.absent(),
    Value<String?> passwordSaltBase64 = const Value.absent(),
    Value<String?> passwordVerifierBase64 = const Value.absent(),
    Value<int?> passwordIterations = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Journal(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isLocked: isLocked ?? this.isLocked,
    credentialReference: credentialReference.present
        ? credentialReference.value
        : this.credentialReference,
    passwordSaltBase64: passwordSaltBase64.present
        ? passwordSaltBase64.value
        : this.passwordSaltBase64,
    passwordVerifierBase64: passwordVerifierBase64.present
        ? passwordVerifierBase64.value
        : this.passwordVerifierBase64,
    passwordIterations: passwordIterations.present
        ? passwordIterations.value
        : this.passwordIterations,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Journal copyWithCompanion(JournalsCompanion data) {
    return Journal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      credentialReference: data.credentialReference.present
          ? data.credentialReference.value
          : this.credentialReference,
      passwordSaltBase64: data.passwordSaltBase64.present
          ? data.passwordSaltBase64.value
          : this.passwordSaltBase64,
      passwordVerifierBase64: data.passwordVerifierBase64.present
          ? data.passwordVerifierBase64.value
          : this.passwordVerifierBase64,
      passwordIterations: data.passwordIterations.present
          ? data.passwordIterations.value
          : this.passwordIterations,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Journal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isLocked: $isLocked, ')
          ..write('credentialReference: $credentialReference, ')
          ..write('passwordSaltBase64: $passwordSaltBase64, ')
          ..write('passwordVerifierBase64: $passwordVerifierBase64, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    isLocked,
    credentialReference,
    passwordSaltBase64,
    passwordVerifierBase64,
    passwordIterations,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Journal &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isLocked == this.isLocked &&
          other.credentialReference == this.credentialReference &&
          other.passwordSaltBase64 == this.passwordSaltBase64 &&
          other.passwordVerifierBase64 == this.passwordVerifierBase64 &&
          other.passwordIterations == this.passwordIterations &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalsCompanion extends UpdateCompanion<Journal> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isLocked;
  final Value<String?> credentialReference;
  final Value<String?> passwordSaltBase64;
  final Value<String?> passwordVerifierBase64;
  final Value<int?> passwordIterations;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JournalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.credentialReference = const Value.absent(),
    this.passwordSaltBase64 = const Value.absent(),
    this.passwordVerifierBase64 = const Value.absent(),
    this.passwordIterations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JournalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.credentialReference = const Value.absent(),
    this.passwordSaltBase64 = const Value.absent(),
    this.passwordVerifierBase64 = const Value.absent(),
    this.passwordIterations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Journal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isLocked,
    Expression<String>? credentialReference,
    Expression<String>? passwordSaltBase64,
    Expression<String>? passwordVerifierBase64,
    Expression<int>? passwordIterations,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isLocked != null) 'is_locked': isLocked,
      if (credentialReference != null)
        'credential_reference': credentialReference,
      if (passwordSaltBase64 != null)
        'password_salt_base64': passwordSaltBase64,
      if (passwordVerifierBase64 != null)
        'password_verifier_base64': passwordVerifierBase64,
      if (passwordIterations != null) 'password_iterations': passwordIterations,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JournalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? isLocked,
    Value<String?>? credentialReference,
    Value<String?>? passwordSaltBase64,
    Value<String?>? passwordVerifierBase64,
    Value<int?>? passwordIterations,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return JournalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isLocked: isLocked ?? this.isLocked,
      credentialReference: credentialReference ?? this.credentialReference,
      passwordSaltBase64: passwordSaltBase64 ?? this.passwordSaltBase64,
      passwordVerifierBase64:
          passwordVerifierBase64 ?? this.passwordVerifierBase64,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (credentialReference.present) {
      map['credential_reference'] = Variable<String>(credentialReference.value);
    }
    if (passwordSaltBase64.present) {
      map['password_salt_base64'] = Variable<String>(passwordSaltBase64.value);
    }
    if (passwordVerifierBase64.present) {
      map['password_verifier_base64'] = Variable<String>(
        passwordVerifierBase64.value,
      );
    }
    if (passwordIterations.present) {
      map['password_iterations'] = Variable<int>(passwordIterations.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isLocked: $isLocked, ')
          ..write('credentialReference: $credentialReference, ')
          ..write('passwordSaltBase64: $passwordSaltBase64, ')
          ..write('passwordVerifierBase64: $passwordVerifierBase64, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _journalIdMeta = const VerificationMeta(
    'journalId',
  );
  @override
  late final GeneratedColumn<int> journalId = GeneratedColumn<int>(
    'journal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journals (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    journalId,
    title,
    contentJson,
    plainText,
    entryDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('journal_id')) {
      context.handle(
        _journalIdMeta,
        journalId.isAcceptableOrUnknown(data['journal_id']!, _journalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_journalIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      journalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}journal_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      ),
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;
  final int journalId;
  final String? title;
  final String? contentJson;
  final String? plainText;
  final DateTime? entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Entry({
    required this.id,
    required this.journalId,
    this.title,
    this.contentJson,
    this.plainText,
    this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['journal_id'] = Variable<int>(journalId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || contentJson != null) {
      map['content_json'] = Variable<String>(contentJson);
    }
    if (!nullToAbsent || plainText != null) {
      map['plain_text'] = Variable<String>(plainText);
    }
    if (!nullToAbsent || entryDate != null) {
      map['entry_date'] = Variable<DateTime>(entryDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      journalId: Value(journalId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      contentJson: contentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contentJson),
      plainText: plainText == null && nullToAbsent
          ? const Value.absent()
          : Value(plainText),
      entryDate: entryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(entryDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      journalId: serializer.fromJson<int>(json['journalId']),
      title: serializer.fromJson<String?>(json['title']),
      contentJson: serializer.fromJson<String?>(json['contentJson']),
      plainText: serializer.fromJson<String?>(json['plainText']),
      entryDate: serializer.fromJson<DateTime?>(json['entryDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'journalId': serializer.toJson<int>(journalId),
      'title': serializer.toJson<String?>(title),
      'contentJson': serializer.toJson<String?>(contentJson),
      'plainText': serializer.toJson<String?>(plainText),
      'entryDate': serializer.toJson<DateTime?>(entryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Entry copyWith({
    int? id,
    int? journalId,
    Value<String?> title = const Value.absent(),
    Value<String?> contentJson = const Value.absent(),
    Value<String?> plainText = const Value.absent(),
    Value<DateTime?> entryDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    journalId: journalId ?? this.journalId,
    title: title.present ? title.value : this.title,
    contentJson: contentJson.present ? contentJson.value : this.contentJson,
    plainText: plainText.present ? plainText.value : this.plainText,
    entryDate: entryDate.present ? entryDate.value : this.entryDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      journalId: data.journalId.present ? data.journalId.value : this.journalId,
      title: data.title.present ? data.title.value : this.title,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('entryDate: $entryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    journalId,
    title,
    contentJson,
    plainText,
    entryDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.journalId == this.journalId &&
          other.title == this.title &&
          other.contentJson == this.contentJson &&
          other.plainText == this.plainText &&
          other.entryDate == this.entryDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<int> journalId;
  final Value<String?> title;
  final Value<String?> contentJson;
  final Value<String?> plainText;
  final Value<DateTime?> entryDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.journalId = const Value.absent(),
    this.title = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.plainText = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int journalId,
    this.title = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.plainText = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : journalId = Value(journalId);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<int>? journalId,
    Expression<String>? title,
    Expression<String>? contentJson,
    Expression<String>? plainText,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalId != null) 'journal_id': journalId,
      if (title != null) 'title': title,
      if (contentJson != null) 'content_json': contentJson,
      if (plainText != null) 'plain_text': plainText,
      if (entryDate != null) 'entry_date': entryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? journalId,
    Value<String?>? title,
    Value<String?>? contentJson,
    Value<String?>? plainText,
    Value<DateTime?>? entryDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      plainText: plainText ?? this.plainText,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journalId.present) {
      map['journal_id'] = Variable<int>(journalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('entryDate: $entryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JournalTagsTable extends JournalTags
    with TableInfo<$JournalTagsTable, JournalTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _journalIdMeta = const VerificationMeta(
    'journalId',
  );
  @override
  late final GeneratedColumn<int> journalId = GeneratedColumn<int>(
    'journal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journals (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, journalId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('journal_id')) {
      context.handle(
        _journalIdMeta,
        journalId.isAcceptableOrUnknown(data['journal_id']!, _journalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_journalIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      journalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}journal_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $JournalTagsTable createAlias(String alias) {
    return $JournalTagsTable(attachedDatabase, alias);
  }
}

class JournalTag extends DataClass implements Insertable<JournalTag> {
  final int id;
  final int journalId;
  final int tagId;
  const JournalTag({
    required this.id,
    required this.journalId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['journal_id'] = Variable<int>(journalId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  JournalTagsCompanion toCompanion(bool nullToAbsent) {
    return JournalTagsCompanion(
      id: Value(id),
      journalId: Value(journalId),
      tagId: Value(tagId),
    );
  }

  factory JournalTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalTag(
      id: serializer.fromJson<int>(json['id']),
      journalId: serializer.fromJson<int>(json['journalId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'journalId': serializer.toJson<int>(journalId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  JournalTag copyWith({int? id, int? journalId, int? tagId}) => JournalTag(
    id: id ?? this.id,
    journalId: journalId ?? this.journalId,
    tagId: tagId ?? this.tagId,
  );
  JournalTag copyWithCompanion(JournalTagsCompanion data) {
    return JournalTag(
      id: data.id.present ? data.id.value : this.id,
      journalId: data.journalId.present ? data.journalId.value : this.journalId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalTag(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, journalId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalTag &&
          other.id == this.id &&
          other.journalId == this.journalId &&
          other.tagId == this.tagId);
}

class JournalTagsCompanion extends UpdateCompanion<JournalTag> {
  final Value<int> id;
  final Value<int> journalId;
  final Value<int> tagId;
  const JournalTagsCompanion({
    this.id = const Value.absent(),
    this.journalId = const Value.absent(),
    this.tagId = const Value.absent(),
  });
  JournalTagsCompanion.insert({
    this.id = const Value.absent(),
    required int journalId,
    required int tagId,
  }) : journalId = Value(journalId),
       tagId = Value(tagId);
  static Insertable<JournalTag> custom({
    Expression<int>? id,
    Expression<int>? journalId,
    Expression<int>? tagId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalId != null) 'journal_id': journalId,
      if (tagId != null) 'tag_id': tagId,
    });
  }

  JournalTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? journalId,
    Value<int>? tagId,
  }) {
    return JournalTagsCompanion(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      tagId: tagId ?? this.tagId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journalId.present) {
      map['journal_id'] = Variable<int>(journalId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalTagsCompanion(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }
}

class $EntryTagsTable extends EntryTags
    with TableInfo<$EntryTagsTable, EntryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entryId, tagId},
  ];
  @override
  EntryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EntryTagsTable createAlias(String alias) {
    return $EntryTagsTable(attachedDatabase, alias);
  }
}

class EntryTag extends DataClass implements Insertable<EntryTag> {
  final int id;
  final int entryId;
  final int tagId;
  const EntryTag({
    required this.id,
    required this.entryId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  EntryTagsCompanion toCompanion(bool nullToAbsent) {
    return EntryTagsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      tagId: Value(tagId),
    );
  }

  factory EntryTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryTag(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  EntryTag copyWith({int? id, int? entryId, int? tagId}) => EntryTag(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    tagId: tagId ?? this.tagId,
  );
  EntryTag copyWithCompanion(EntryTagsCompanion data) {
    return EntryTag(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryTag(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryTag &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.tagId == this.tagId);
}

class EntryTagsCompanion extends UpdateCompanion<EntryTag> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<int> tagId;
  const EntryTagsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.tagId = const Value.absent(),
  });
  EntryTagsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required int tagId,
  }) : entryId = Value(entryId),
       tagId = Value(tagId);
  static Insertable<EntryTag> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<int>? tagId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (tagId != null) 'tag_id': tagId,
    });
  }

  EntryTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<int>? tagId,
  }) {
    return EntryTagsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      tagId: tagId ?? this.tagId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryTagsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id)',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedPathMeta = const VerificationMeta(
    'encryptedPath',
  );
  @override
  late final GeneratedColumn<String> encryptedPath = GeneratedColumn<String>(
    'encrypted_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nonceBase64Meta = const VerificationMeta(
    'nonceBase64',
  );
  @override
  late final GeneratedColumn<String> nonceBase64 = GeneratedColumn<String>(
    'nonce_base64',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyReferenceMeta = const VerificationMeta(
    'keyReference',
  );
  @override
  late final GeneratedColumn<String> keyReference = GeneratedColumn<String>(
    'key_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    fileName,
    mimeType,
    encryptedPath,
    nonceBase64,
    keyReference,
    sizeBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('encrypted_path')) {
      context.handle(
        _encryptedPathMeta,
        encryptedPath.isAcceptableOrUnknown(
          data['encrypted_path']!,
          _encryptedPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPathMeta);
    }
    if (data.containsKey('nonce_base64')) {
      context.handle(
        _nonceBase64Meta,
        nonceBase64.isAcceptableOrUnknown(
          data['nonce_base64']!,
          _nonceBase64Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nonceBase64Meta);
    }
    if (data.containsKey('key_reference')) {
      context.handle(
        _keyReferenceMeta,
        keyReference.isAcceptableOrUnknown(
          data['key_reference']!,
          _keyReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_keyReferenceMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      encryptedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_path'],
      )!,
      nonceBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nonce_base64'],
      )!,
      keyReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_reference'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int entryId;
  final String fileName;
  final String? mimeType;
  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
  final int sizeBytes;
  final DateTime createdAt;
  const Attachment({
    required this.id,
    required this.entryId,
    required this.fileName,
    this.mimeType,
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
    required this.sizeBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['encrypted_path'] = Variable<String>(encryptedPath);
    map['nonce_base64'] = Variable<String>(nonceBase64);
    map['key_reference'] = Variable<String>(keyReference);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      fileName: Value(fileName),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      encryptedPath: Value(encryptedPath),
      nonceBase64: Value(nonceBase64),
      keyReference: Value(keyReference),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      encryptedPath: serializer.fromJson<String>(json['encryptedPath']),
      nonceBase64: serializer.fromJson<String>(json['nonceBase64']),
      keyReference: serializer.fromJson<String>(json['keyReference']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'encryptedPath': serializer.toJson<String>(encryptedPath),
      'nonceBase64': serializer.toJson<String>(nonceBase64),
      'keyReference': serializer.toJson<String>(keyReference),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith({
    int? id,
    int? entryId,
    String? fileName,
    Value<String?> mimeType = const Value.absent(),
    String? encryptedPath,
    String? nonceBase64,
    String? keyReference,
    int? sizeBytes,
    DateTime? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    encryptedPath: encryptedPath ?? this.encryptedPath,
    nonceBase64: nonceBase64 ?? this.nonceBase64,
    keyReference: keyReference ?? this.keyReference,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      encryptedPath: data.encryptedPath.present
          ? data.encryptedPath.value
          : this.encryptedPath,
      nonceBase64: data.nonceBase64.present
          ? data.nonceBase64.value
          : this.nonceBase64,
      keyReference: data.keyReference.present
          ? data.keyReference.value
          : this.keyReference,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('nonceBase64: $nonceBase64, ')
          ..write('keyReference: $keyReference, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    fileName,
    mimeType,
    encryptedPath,
    nonceBase64,
    keyReference,
    sizeBytes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.encryptedPath == this.encryptedPath &&
          other.nonceBase64 == this.nonceBase64 &&
          other.keyReference == this.keyReference &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> fileName;
  final Value<String?> mimeType;
  final Value<String> encryptedPath;
  final Value<String> nonceBase64;
  final Value<String> keyReference;
  final Value<int> sizeBytes;
  final Value<DateTime> createdAt;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.encryptedPath = const Value.absent(),
    this.nonceBase64 = const Value.absent(),
    this.keyReference = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String fileName,
    this.mimeType = const Value.absent(),
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required int sizeBytes,
    this.createdAt = const Value.absent(),
  }) : entryId = Value(entryId),
       fileName = Value(fileName),
       encryptedPath = Value(encryptedPath),
       nonceBase64 = Value(nonceBase64),
       keyReference = Value(keyReference),
       sizeBytes = Value(sizeBytes);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<String>? encryptedPath,
    Expression<String>? nonceBase64,
    Expression<String>? keyReference,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (encryptedPath != null) 'encrypted_path': encryptedPath,
      if (nonceBase64 != null) 'nonce_base64': nonceBase64,
      if (keyReference != null) 'key_reference': keyReference,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? fileName,
    Value<String?>? mimeType,
    Value<String>? encryptedPath,
    Value<String>? nonceBase64,
    Value<String>? keyReference,
    Value<int>? sizeBytes,
    Value<DateTime>? createdAt,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      nonceBase64: nonceBase64 ?? this.nonceBase64,
      keyReference: keyReference ?? this.keyReference,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (encryptedPath.present) {
      map['encrypted_path'] = Variable<String>(encryptedPath.value);
    }
    if (nonceBase64.present) {
      map['nonce_base64'] = Variable<String>(nonceBase64.value);
    }
    if (keyReference.present) {
      map['key_reference'] = Variable<String>(keyReference.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('nonceBase64: $nonceBase64, ')
          ..write('keyReference: $keyReference, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentTextsTable extends AttachmentTexts
    with TableInfo<$AttachmentTextsTable, AttachmentText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<int> attachmentId = GeneratedColumn<int>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attachments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _extractedTextMeta = const VerificationMeta(
    'extractedText',
  );
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
    'extracted_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attachmentId,
    extractedText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentText> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('extracted_text')) {
      context.handle(
        _extractedTextMeta,
        extractedText.isAcceptableOrUnknown(
          data['extracted_text']!,
          _extractedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extractedTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentText(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_id'],
      )!,
      extractedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentTextsTable createAlias(String alias) {
    return $AttachmentTextsTable(attachedDatabase, alias);
  }
}

class AttachmentText extends DataClass implements Insertable<AttachmentText> {
  final int id;
  final int attachmentId;
  final String extractedText;
  final DateTime createdAt;
  const AttachmentText({
    required this.id,
    required this.attachmentId,
    required this.extractedText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attachment_id'] = Variable<int>(attachmentId);
    map['extracted_text'] = Variable<String>(extractedText);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentTextsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentTextsCompanion(
      id: Value(id),
      attachmentId: Value(attachmentId),
      extractedText: Value(extractedText),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentText(
      id: serializer.fromJson<int>(json['id']),
      attachmentId: serializer.fromJson<int>(json['attachmentId']),
      extractedText: serializer.fromJson<String>(json['extractedText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attachmentId': serializer.toJson<int>(attachmentId),
      'extractedText': serializer.toJson<String>(extractedText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentText copyWith({
    int? id,
    int? attachmentId,
    String? extractedText,
    DateTime? createdAt,
  }) => AttachmentText(
    id: id ?? this.id,
    attachmentId: attachmentId ?? this.attachmentId,
    extractedText: extractedText ?? this.extractedText,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentText copyWithCompanion(AttachmentTextsCompanion data) {
    return AttachmentText(
      id: data.id.present ? data.id.value : this.id,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      extractedText: data.extractedText.present
          ? data.extractedText.value
          : this.extractedText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentText(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('extractedText: $extractedText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attachmentId, extractedText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentText &&
          other.id == this.id &&
          other.attachmentId == this.attachmentId &&
          other.extractedText == this.extractedText &&
          other.createdAt == this.createdAt);
}

class AttachmentTextsCompanion extends UpdateCompanion<AttachmentText> {
  final Value<int> id;
  final Value<int> attachmentId;
  final Value<String> extractedText;
  final Value<DateTime> createdAt;
  const AttachmentTextsCompanion({
    this.id = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttachmentTextsCompanion.insert({
    this.id = const Value.absent(),
    required int attachmentId,
    required String extractedText,
    this.createdAt = const Value.absent(),
  }) : attachmentId = Value(attachmentId),
       extractedText = Value(extractedText);
  static Insertable<AttachmentText> custom({
    Expression<int>? id,
    Expression<int>? attachmentId,
    Expression<String>? extractedText,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (extractedText != null) 'extracted_text': extractedText,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttachmentTextsCompanion copyWith({
    Value<int>? id,
    Value<int>? attachmentId,
    Value<String>? extractedText,
    Value<DateTime>? createdAt,
  }) {
    return AttachmentTextsCompanion(
      id: id ?? this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<int>(attachmentId.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentTextsCompanion(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('extractedText: $extractedText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BacklinksTable extends Backlinks
    with TableInfo<$BacklinksTable, Backlink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BacklinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceEntryIdMeta = const VerificationMeta(
    'sourceEntryId',
  );
  @override
  late final GeneratedColumn<int> sourceEntryId = GeneratedColumn<int>(
    'source_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceEntryId,
    targetType,
    targetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backlinks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Backlink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_entry_id')) {
      context.handle(
        _sourceEntryIdMeta,
        sourceEntryId.isAcceptableOrUnknown(
          data['source_entry_id']!,
          _sourceEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEntryIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Backlink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Backlink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_entry_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
    );
  }

  @override
  $BacklinksTable createAlias(String alias) {
    return $BacklinksTable(attachedDatabase, alias);
  }
}

class Backlink extends DataClass implements Insertable<Backlink> {
  final int id;
  final int sourceEntryId;
  final String targetType;
  final int targetId;
  const Backlink({
    required this.id,
    required this.sourceEntryId,
    required this.targetType,
    required this.targetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_entry_id'] = Variable<int>(sourceEntryId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<int>(targetId);
    return map;
  }

  BacklinksCompanion toCompanion(bool nullToAbsent) {
    return BacklinksCompanion(
      id: Value(id),
      sourceEntryId: Value(sourceEntryId),
      targetType: Value(targetType),
      targetId: Value(targetId),
    );
  }

  factory Backlink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Backlink(
      id: serializer.fromJson<int>(json['id']),
      sourceEntryId: serializer.fromJson<int>(json['sourceEntryId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<int>(json['targetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceEntryId': serializer.toJson<int>(sourceEntryId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<int>(targetId),
    };
  }

  Backlink copyWith({
    int? id,
    int? sourceEntryId,
    String? targetType,
    int? targetId,
  }) => Backlink(
    id: id ?? this.id,
    sourceEntryId: sourceEntryId ?? this.sourceEntryId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
  );
  Backlink copyWithCompanion(BacklinksCompanion data) {
    return Backlink(
      id: data.id.present ? data.id.value : this.id,
      sourceEntryId: data.sourceEntryId.present
          ? data.sourceEntryId.value
          : this.sourceEntryId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Backlink(')
          ..write('id: $id, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceEntryId, targetType, targetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Backlink &&
          other.id == this.id &&
          other.sourceEntryId == this.sourceEntryId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId);
}

class BacklinksCompanion extends UpdateCompanion<Backlink> {
  final Value<int> id;
  final Value<int> sourceEntryId;
  final Value<String> targetType;
  final Value<int> targetId;
  const BacklinksCompanion({
    this.id = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
  });
  BacklinksCompanion.insert({
    this.id = const Value.absent(),
    required int sourceEntryId,
    required String targetType,
    required int targetId,
  }) : sourceEntryId = Value(sourceEntryId),
       targetType = Value(targetType),
       targetId = Value(targetId);
  static Insertable<Backlink> custom({
    Expression<int>? id,
    Expression<int>? sourceEntryId,
    Expression<String>? targetType,
    Expression<int>? targetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceEntryId != null) 'source_entry_id': sourceEntryId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
    });
  }

  BacklinksCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceEntryId,
    Value<String>? targetType,
    Value<int>? targetId,
  }) {
    return BacklinksCompanion(
      id: id ?? this.id,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceEntryId.present) {
      map['source_entry_id'] = Variable<int>(sourceEntryId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BacklinksCompanion(')
          ..write('id: $id, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId')
          ..write(')'))
        .toString();
  }
}

class $SearchPresetsTable extends SearchPresets
    with TableInfo<$SearchPresetsTable, SearchPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultTypeMeta = const VerificationMeta(
    'resultType',
  );
  @override
  late final GeneratedColumn<String> resultType = GeneratedColumn<String>(
    'result_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    query,
    resultType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('result_type')) {
      context.handle(
        _resultTypeMeta,
        resultType.isAcceptableOrUnknown(data['result_type']!, _resultTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      resultType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SearchPresetsTable createAlias(String alias) {
    return $SearchPresetsTable(attachedDatabase, alias);
  }
}

class SearchPreset extends DataClass implements Insertable<SearchPreset> {
  final int id;
  final String name;
  final String query;
  final String? resultType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SearchPreset({
    required this.id,
    required this.name,
    required this.query,
    this.resultType,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['query'] = Variable<String>(query);
    if (!nullToAbsent || resultType != null) {
      map['result_type'] = Variable<String>(resultType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SearchPresetsCompanion toCompanion(bool nullToAbsent) {
    return SearchPresetsCompanion(
      id: Value(id),
      name: Value(name),
      query: Value(query),
      resultType: resultType == null && nullToAbsent
          ? const Value.absent()
          : Value(resultType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SearchPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      query: serializer.fromJson<String>(json['query']),
      resultType: serializer.fromJson<String?>(json['resultType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'query': serializer.toJson<String>(query),
      'resultType': serializer.toJson<String?>(resultType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SearchPreset copyWith({
    int? id,
    String? name,
    String? query,
    Value<String?> resultType = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SearchPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    query: query ?? this.query,
    resultType: resultType.present ? resultType.value : this.resultType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SearchPreset copyWithCompanion(SearchPresetsCompanion data) {
    return SearchPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      query: data.query.present ? data.query.value : this.query,
      resultType: data.resultType.present
          ? data.resultType.value
          : this.resultType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('query: $query, ')
          ..write('resultType: $resultType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, query, resultType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.query == this.query &&
          other.resultType == this.resultType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SearchPresetsCompanion extends UpdateCompanion<SearchPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> query;
  final Value<String?> resultType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SearchPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.query = const Value.absent(),
    this.resultType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SearchPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String query,
    this.resultType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       query = Value(query);
  static Insertable<SearchPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? query,
    Expression<String>? resultType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (query != null) 'query': query,
      if (resultType != null) 'result_type': resultType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SearchPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? query,
    Value<String?>? resultType,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SearchPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      query: query ?? this.query,
      resultType: resultType ?? this.resultType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (resultType.present) {
      map['result_type'] = Variable<String>(resultType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('query: $query, ')
          ..write('resultType: $resultType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _attachmentStorageLocationMeta =
      const VerificationMeta('attachmentStorageLocation');
  @override
  late final GeneratedColumn<String> attachmentStorageLocation =
      GeneratedColumn<String>(
        'attachment_storage_location',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('app_private'),
      );
  static const VerificationMeta _attachmentStorageTreeUriMeta =
      const VerificationMeta('attachmentStorageTreeUri');
  @override
  late final GeneratedColumn<String> attachmentStorageTreeUri =
      GeneratedColumn<String>(
        'attachment_storage_tree_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attachmentStorageTreeLabelMeta =
      const VerificationMeta('attachmentStorageTreeLabel');
  @override
  late final GeneratedColumn<String> attachmentStorageTreeLabel =
      GeneratedColumn<String>(
        'attachment_storage_tree_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attachmentMigrationStatusMeta =
      const VerificationMeta('attachmentMigrationStatus');
  @override
  late final GeneratedColumn<String> attachmentMigrationStatus =
      GeneratedColumn<String>(
        'attachment_migration_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('idle'),
      );
  static const VerificationMeta _attachmentMigrationTargetMeta =
      const VerificationMeta('attachmentMigrationTarget');
  @override
  late final GeneratedColumn<String> attachmentMigrationTarget =
      GeneratedColumn<String>(
        'attachment_migration_target',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attachmentMigrationFailureMeta =
      const VerificationMeta('attachmentMigrationFailure');
  @override
  late final GeneratedColumn<String> attachmentMigrationFailure =
      GeneratedColumn<String>(
        'attachment_migration_failure',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attachmentMigrationProcessedCountMeta =
      const VerificationMeta('attachmentMigrationProcessedCount');
  @override
  late final GeneratedColumn<int> attachmentMigrationProcessedCount =
      GeneratedColumn<int>(
        'attachment_migration_processed_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _attachmentMigrationTotalCountMeta =
      const VerificationMeta('attachmentMigrationTotalCount');
  @override
  late final GeneratedColumn<int> attachmentMigrationTotalCount =
      GeneratedColumn<int>(
        'attachment_migration_total_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attachmentStorageLocation,
    attachmentStorageTreeUri,
    attachmentStorageTreeLabel,
    attachmentMigrationStatus,
    attachmentMigrationTarget,
    attachmentMigrationFailure,
    attachmentMigrationProcessedCount,
    attachmentMigrationTotalCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attachment_storage_location')) {
      context.handle(
        _attachmentStorageLocationMeta,
        attachmentStorageLocation.isAcceptableOrUnknown(
          data['attachment_storage_location']!,
          _attachmentStorageLocationMeta,
        ),
      );
    }
    if (data.containsKey('attachment_storage_tree_uri')) {
      context.handle(
        _attachmentStorageTreeUriMeta,
        attachmentStorageTreeUri.isAcceptableOrUnknown(
          data['attachment_storage_tree_uri']!,
          _attachmentStorageTreeUriMeta,
        ),
      );
    }
    if (data.containsKey('attachment_storage_tree_label')) {
      context.handle(
        _attachmentStorageTreeLabelMeta,
        attachmentStorageTreeLabel.isAcceptableOrUnknown(
          data['attachment_storage_tree_label']!,
          _attachmentStorageTreeLabelMeta,
        ),
      );
    }
    if (data.containsKey('attachment_migration_status')) {
      context.handle(
        _attachmentMigrationStatusMeta,
        attachmentMigrationStatus.isAcceptableOrUnknown(
          data['attachment_migration_status']!,
          _attachmentMigrationStatusMeta,
        ),
      );
    }
    if (data.containsKey('attachment_migration_target')) {
      context.handle(
        _attachmentMigrationTargetMeta,
        attachmentMigrationTarget.isAcceptableOrUnknown(
          data['attachment_migration_target']!,
          _attachmentMigrationTargetMeta,
        ),
      );
    }
    if (data.containsKey('attachment_migration_failure')) {
      context.handle(
        _attachmentMigrationFailureMeta,
        attachmentMigrationFailure.isAcceptableOrUnknown(
          data['attachment_migration_failure']!,
          _attachmentMigrationFailureMeta,
        ),
      );
    }
    if (data.containsKey('attachment_migration_processed_count')) {
      context.handle(
        _attachmentMigrationProcessedCountMeta,
        attachmentMigrationProcessedCount.isAcceptableOrUnknown(
          data['attachment_migration_processed_count']!,
          _attachmentMigrationProcessedCountMeta,
        ),
      );
    }
    if (data.containsKey('attachment_migration_total_count')) {
      context.handle(
        _attachmentMigrationTotalCountMeta,
        attachmentMigrationTotalCount.isAcceptableOrUnknown(
          data['attachment_migration_total_count']!,
          _attachmentMigrationTotalCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attachmentStorageLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_storage_location'],
      )!,
      attachmentStorageTreeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_storage_tree_uri'],
      ),
      attachmentStorageTreeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_storage_tree_label'],
      ),
      attachmentMigrationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_migration_status'],
      )!,
      attachmentMigrationTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_migration_target'],
      ),
      attachmentMigrationFailure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_migration_failure'],
      ),
      attachmentMigrationProcessedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_migration_processed_count'],
      )!,
      attachmentMigrationTotalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_migration_total_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String attachmentStorageLocation;
  final String? attachmentStorageTreeUri;
  final String? attachmentStorageTreeLabel;
  final String attachmentMigrationStatus;
  final String? attachmentMigrationTarget;
  final String? attachmentMigrationFailure;
  final int attachmentMigrationProcessedCount;
  final int attachmentMigrationTotalCount;
  final DateTime updatedAt;
  const AppSetting({
    required this.id,
    required this.attachmentStorageLocation,
    this.attachmentStorageTreeUri,
    this.attachmentStorageTreeLabel,
    required this.attachmentMigrationStatus,
    this.attachmentMigrationTarget,
    this.attachmentMigrationFailure,
    required this.attachmentMigrationProcessedCount,
    required this.attachmentMigrationTotalCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attachment_storage_location'] = Variable<String>(
      attachmentStorageLocation,
    );
    if (!nullToAbsent || attachmentStorageTreeUri != null) {
      map['attachment_storage_tree_uri'] = Variable<String>(
        attachmentStorageTreeUri,
      );
    }
    if (!nullToAbsent || attachmentStorageTreeLabel != null) {
      map['attachment_storage_tree_label'] = Variable<String>(
        attachmentStorageTreeLabel,
      );
    }
    map['attachment_migration_status'] = Variable<String>(
      attachmentMigrationStatus,
    );
    if (!nullToAbsent || attachmentMigrationTarget != null) {
      map['attachment_migration_target'] = Variable<String>(
        attachmentMigrationTarget,
      );
    }
    if (!nullToAbsent || attachmentMigrationFailure != null) {
      map['attachment_migration_failure'] = Variable<String>(
        attachmentMigrationFailure,
      );
    }
    map['attachment_migration_processed_count'] = Variable<int>(
      attachmentMigrationProcessedCount,
    );
    map['attachment_migration_total_count'] = Variable<int>(
      attachmentMigrationTotalCount,
    );
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      attachmentStorageLocation: Value(attachmentStorageLocation),
      attachmentStorageTreeUri: attachmentStorageTreeUri == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentStorageTreeUri),
      attachmentStorageTreeLabel:
          attachmentStorageTreeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentStorageTreeLabel),
      attachmentMigrationStatus: Value(attachmentMigrationStatus),
      attachmentMigrationTarget:
          attachmentMigrationTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentMigrationTarget),
      attachmentMigrationFailure:
          attachmentMigrationFailure == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentMigrationFailure),
      attachmentMigrationProcessedCount: Value(
        attachmentMigrationProcessedCount,
      ),
      attachmentMigrationTotalCount: Value(attachmentMigrationTotalCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      attachmentStorageLocation: serializer.fromJson<String>(
        json['attachmentStorageLocation'],
      ),
      attachmentStorageTreeUri: serializer.fromJson<String?>(
        json['attachmentStorageTreeUri'],
      ),
      attachmentStorageTreeLabel: serializer.fromJson<String?>(
        json['attachmentStorageTreeLabel'],
      ),
      attachmentMigrationStatus: serializer.fromJson<String>(
        json['attachmentMigrationStatus'],
      ),
      attachmentMigrationTarget: serializer.fromJson<String?>(
        json['attachmentMigrationTarget'],
      ),
      attachmentMigrationFailure: serializer.fromJson<String?>(
        json['attachmentMigrationFailure'],
      ),
      attachmentMigrationProcessedCount: serializer.fromJson<int>(
        json['attachmentMigrationProcessedCount'],
      ),
      attachmentMigrationTotalCount: serializer.fromJson<int>(
        json['attachmentMigrationTotalCount'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attachmentStorageLocation': serializer.toJson<String>(
        attachmentStorageLocation,
      ),
      'attachmentStorageTreeUri': serializer.toJson<String?>(
        attachmentStorageTreeUri,
      ),
      'attachmentStorageTreeLabel': serializer.toJson<String?>(
        attachmentStorageTreeLabel,
      ),
      'attachmentMigrationStatus': serializer.toJson<String>(
        attachmentMigrationStatus,
      ),
      'attachmentMigrationTarget': serializer.toJson<String?>(
        attachmentMigrationTarget,
      ),
      'attachmentMigrationFailure': serializer.toJson<String?>(
        attachmentMigrationFailure,
      ),
      'attachmentMigrationProcessedCount': serializer.toJson<int>(
        attachmentMigrationProcessedCount,
      ),
      'attachmentMigrationTotalCount': serializer.toJson<int>(
        attachmentMigrationTotalCount,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    int? id,
    String? attachmentStorageLocation,
    Value<String?> attachmentStorageTreeUri = const Value.absent(),
    Value<String?> attachmentStorageTreeLabel = const Value.absent(),
    String? attachmentMigrationStatus,
    Value<String?> attachmentMigrationTarget = const Value.absent(),
    Value<String?> attachmentMigrationFailure = const Value.absent(),
    int? attachmentMigrationProcessedCount,
    int? attachmentMigrationTotalCount,
    DateTime? updatedAt,
  }) => AppSetting(
    id: id ?? this.id,
    attachmentStorageLocation:
        attachmentStorageLocation ?? this.attachmentStorageLocation,
    attachmentStorageTreeUri: attachmentStorageTreeUri.present
        ? attachmentStorageTreeUri.value
        : this.attachmentStorageTreeUri,
    attachmentStorageTreeLabel: attachmentStorageTreeLabel.present
        ? attachmentStorageTreeLabel.value
        : this.attachmentStorageTreeLabel,
    attachmentMigrationStatus:
        attachmentMigrationStatus ?? this.attachmentMigrationStatus,
    attachmentMigrationTarget: attachmentMigrationTarget.present
        ? attachmentMigrationTarget.value
        : this.attachmentMigrationTarget,
    attachmentMigrationFailure: attachmentMigrationFailure.present
        ? attachmentMigrationFailure.value
        : this.attachmentMigrationFailure,
    attachmentMigrationProcessedCount:
        attachmentMigrationProcessedCount ??
        this.attachmentMigrationProcessedCount,
    attachmentMigrationTotalCount:
        attachmentMigrationTotalCount ?? this.attachmentMigrationTotalCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      attachmentStorageLocation: data.attachmentStorageLocation.present
          ? data.attachmentStorageLocation.value
          : this.attachmentStorageLocation,
      attachmentStorageTreeUri: data.attachmentStorageTreeUri.present
          ? data.attachmentStorageTreeUri.value
          : this.attachmentStorageTreeUri,
      attachmentStorageTreeLabel: data.attachmentStorageTreeLabel.present
          ? data.attachmentStorageTreeLabel.value
          : this.attachmentStorageTreeLabel,
      attachmentMigrationStatus: data.attachmentMigrationStatus.present
          ? data.attachmentMigrationStatus.value
          : this.attachmentMigrationStatus,
      attachmentMigrationTarget: data.attachmentMigrationTarget.present
          ? data.attachmentMigrationTarget.value
          : this.attachmentMigrationTarget,
      attachmentMigrationFailure: data.attachmentMigrationFailure.present
          ? data.attachmentMigrationFailure.value
          : this.attachmentMigrationFailure,
      attachmentMigrationProcessedCount:
          data.attachmentMigrationProcessedCount.present
          ? data.attachmentMigrationProcessedCount.value
          : this.attachmentMigrationProcessedCount,
      attachmentMigrationTotalCount: data.attachmentMigrationTotalCount.present
          ? data.attachmentMigrationTotalCount.value
          : this.attachmentMigrationTotalCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('attachmentStorageLocation: $attachmentStorageLocation, ')
          ..write('attachmentStorageTreeUri: $attachmentStorageTreeUri, ')
          ..write('attachmentStorageTreeLabel: $attachmentStorageTreeLabel, ')
          ..write('attachmentMigrationStatus: $attachmentMigrationStatus, ')
          ..write('attachmentMigrationTarget: $attachmentMigrationTarget, ')
          ..write('attachmentMigrationFailure: $attachmentMigrationFailure, ')
          ..write(
            'attachmentMigrationProcessedCount: $attachmentMigrationProcessedCount, ',
          )
          ..write(
            'attachmentMigrationTotalCount: $attachmentMigrationTotalCount, ',
          )
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attachmentStorageLocation,
    attachmentStorageTreeUri,
    attachmentStorageTreeLabel,
    attachmentMigrationStatus,
    attachmentMigrationTarget,
    attachmentMigrationFailure,
    attachmentMigrationProcessedCount,
    attachmentMigrationTotalCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.attachmentStorageLocation == this.attachmentStorageLocation &&
          other.attachmentStorageTreeUri == this.attachmentStorageTreeUri &&
          other.attachmentStorageTreeLabel == this.attachmentStorageTreeLabel &&
          other.attachmentMigrationStatus == this.attachmentMigrationStatus &&
          other.attachmentMigrationTarget == this.attachmentMigrationTarget &&
          other.attachmentMigrationFailure == this.attachmentMigrationFailure &&
          other.attachmentMigrationProcessedCount ==
              this.attachmentMigrationProcessedCount &&
          other.attachmentMigrationTotalCount ==
              this.attachmentMigrationTotalCount &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> attachmentStorageLocation;
  final Value<String?> attachmentStorageTreeUri;
  final Value<String?> attachmentStorageTreeLabel;
  final Value<String> attachmentMigrationStatus;
  final Value<String?> attachmentMigrationTarget;
  final Value<String?> attachmentMigrationFailure;
  final Value<int> attachmentMigrationProcessedCount;
  final Value<int> attachmentMigrationTotalCount;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.attachmentStorageLocation = const Value.absent(),
    this.attachmentStorageTreeUri = const Value.absent(),
    this.attachmentStorageTreeLabel = const Value.absent(),
    this.attachmentMigrationStatus = const Value.absent(),
    this.attachmentMigrationTarget = const Value.absent(),
    this.attachmentMigrationFailure = const Value.absent(),
    this.attachmentMigrationProcessedCount = const Value.absent(),
    this.attachmentMigrationTotalCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.attachmentStorageLocation = const Value.absent(),
    this.attachmentStorageTreeUri = const Value.absent(),
    this.attachmentStorageTreeLabel = const Value.absent(),
    this.attachmentMigrationStatus = const Value.absent(),
    this.attachmentMigrationTarget = const Value.absent(),
    this.attachmentMigrationFailure = const Value.absent(),
    this.attachmentMigrationProcessedCount = const Value.absent(),
    this.attachmentMigrationTotalCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? attachmentStorageLocation,
    Expression<String>? attachmentStorageTreeUri,
    Expression<String>? attachmentStorageTreeLabel,
    Expression<String>? attachmentMigrationStatus,
    Expression<String>? attachmentMigrationTarget,
    Expression<String>? attachmentMigrationFailure,
    Expression<int>? attachmentMigrationProcessedCount,
    Expression<int>? attachmentMigrationTotalCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attachmentStorageLocation != null)
        'attachment_storage_location': attachmentStorageLocation,
      if (attachmentStorageTreeUri != null)
        'attachment_storage_tree_uri': attachmentStorageTreeUri,
      if (attachmentStorageTreeLabel != null)
        'attachment_storage_tree_label': attachmentStorageTreeLabel,
      if (attachmentMigrationStatus != null)
        'attachment_migration_status': attachmentMigrationStatus,
      if (attachmentMigrationTarget != null)
        'attachment_migration_target': attachmentMigrationTarget,
      if (attachmentMigrationFailure != null)
        'attachment_migration_failure': attachmentMigrationFailure,
      if (attachmentMigrationProcessedCount != null)
        'attachment_migration_processed_count':
            attachmentMigrationProcessedCount,
      if (attachmentMigrationTotalCount != null)
        'attachment_migration_total_count': attachmentMigrationTotalCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? attachmentStorageLocation,
    Value<String?>? attachmentStorageTreeUri,
    Value<String?>? attachmentStorageTreeLabel,
    Value<String>? attachmentMigrationStatus,
    Value<String?>? attachmentMigrationTarget,
    Value<String?>? attachmentMigrationFailure,
    Value<int>? attachmentMigrationProcessedCount,
    Value<int>? attachmentMigrationTotalCount,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      attachmentStorageLocation:
          attachmentStorageLocation ?? this.attachmentStorageLocation,
      attachmentStorageTreeUri:
          attachmentStorageTreeUri ?? this.attachmentStorageTreeUri,
      attachmentStorageTreeLabel:
          attachmentStorageTreeLabel ?? this.attachmentStorageTreeLabel,
      attachmentMigrationStatus:
          attachmentMigrationStatus ?? this.attachmentMigrationStatus,
      attachmentMigrationTarget:
          attachmentMigrationTarget ?? this.attachmentMigrationTarget,
      attachmentMigrationFailure:
          attachmentMigrationFailure ?? this.attachmentMigrationFailure,
      attachmentMigrationProcessedCount:
          attachmentMigrationProcessedCount ??
          this.attachmentMigrationProcessedCount,
      attachmentMigrationTotalCount:
          attachmentMigrationTotalCount ?? this.attachmentMigrationTotalCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attachmentStorageLocation.present) {
      map['attachment_storage_location'] = Variable<String>(
        attachmentStorageLocation.value,
      );
    }
    if (attachmentStorageTreeUri.present) {
      map['attachment_storage_tree_uri'] = Variable<String>(
        attachmentStorageTreeUri.value,
      );
    }
    if (attachmentStorageTreeLabel.present) {
      map['attachment_storage_tree_label'] = Variable<String>(
        attachmentStorageTreeLabel.value,
      );
    }
    if (attachmentMigrationStatus.present) {
      map['attachment_migration_status'] = Variable<String>(
        attachmentMigrationStatus.value,
      );
    }
    if (attachmentMigrationTarget.present) {
      map['attachment_migration_target'] = Variable<String>(
        attachmentMigrationTarget.value,
      );
    }
    if (attachmentMigrationFailure.present) {
      map['attachment_migration_failure'] = Variable<String>(
        attachmentMigrationFailure.value,
      );
    }
    if (attachmentMigrationProcessedCount.present) {
      map['attachment_migration_processed_count'] = Variable<int>(
        attachmentMigrationProcessedCount.value,
      );
    }
    if (attachmentMigrationTotalCount.present) {
      map['attachment_migration_total_count'] = Variable<int>(
        attachmentMigrationTotalCount.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('attachmentStorageLocation: $attachmentStorageLocation, ')
          ..write('attachmentStorageTreeUri: $attachmentStorageTreeUri, ')
          ..write('attachmentStorageTreeLabel: $attachmentStorageTreeLabel, ')
          ..write('attachmentMigrationStatus: $attachmentMigrationStatus, ')
          ..write('attachmentMigrationTarget: $attachmentMigrationTarget, ')
          ..write('attachmentMigrationFailure: $attachmentMigrationFailure, ')
          ..write(
            'attachmentMigrationProcessedCount: $attachmentMigrationProcessedCount, ',
          )
          ..write(
            'attachmentMigrationTotalCount: $attachmentMigrationTotalCount, ',
          )
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSecurityTable extends AppSecurity
    with TableInfo<$AppSecurityTable, AppSecurityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSecurityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lockModeMeta = const VerificationMeta(
    'lockMode',
  );
  @override
  late final GeneratedColumn<String> lockMode = GeneratedColumn<String>(
    'lock_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, lockMode, isLocked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_security';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSecurityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lock_mode')) {
      context.handle(
        _lockModeMeta,
        lockMode.isAcceptableOrUnknown(data['lock_mode']!, _lockModeMeta),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSecurityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSecurityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lockMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lock_mode'],
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $AppSecurityTable createAlias(String alias) {
    return $AppSecurityTable(attachedDatabase, alias);
  }
}

class AppSecurityData extends DataClass implements Insertable<AppSecurityData> {
  final int id;
  final String? lockMode;
  final bool isLocked;
  const AppSecurityData({
    required this.id,
    this.lockMode,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lockMode != null) {
      map['lock_mode'] = Variable<String>(lockMode);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  AppSecurityCompanion toCompanion(bool nullToAbsent) {
    return AppSecurityCompanion(
      id: Value(id),
      lockMode: lockMode == null && nullToAbsent
          ? const Value.absent()
          : Value(lockMode),
      isLocked: Value(isLocked),
    );
  }

  factory AppSecurityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSecurityData(
      id: serializer.fromJson<int>(json['id']),
      lockMode: serializer.fromJson<String?>(json['lockMode']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lockMode': serializer.toJson<String?>(lockMode),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  AppSecurityData copyWith({
    int? id,
    Value<String?> lockMode = const Value.absent(),
    bool? isLocked,
  }) => AppSecurityData(
    id: id ?? this.id,
    lockMode: lockMode.present ? lockMode.value : this.lockMode,
    isLocked: isLocked ?? this.isLocked,
  );
  AppSecurityData copyWithCompanion(AppSecurityCompanion data) {
    return AppSecurityData(
      id: data.id.present ? data.id.value : this.id,
      lockMode: data.lockMode.present ? data.lockMode.value : this.lockMode,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSecurityData(')
          ..write('id: $id, ')
          ..write('lockMode: $lockMode, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lockMode, isLocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSecurityData &&
          other.id == this.id &&
          other.lockMode == this.lockMode &&
          other.isLocked == this.isLocked);
}

class AppSecurityCompanion extends UpdateCompanion<AppSecurityData> {
  final Value<int> id;
  final Value<String?> lockMode;
  final Value<bool> isLocked;
  const AppSecurityCompanion({
    this.id = const Value.absent(),
    this.lockMode = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  AppSecurityCompanion.insert({
    this.id = const Value.absent(),
    this.lockMode = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  static Insertable<AppSecurityData> custom({
    Expression<int>? id,
    Expression<String>? lockMode,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lockMode != null) 'lock_mode': lockMode,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  AppSecurityCompanion copyWith({
    Value<int>? id,
    Value<String?>? lockMode,
    Value<bool>? isLocked,
  }) {
    return AppSecurityCompanion(
      id: id ?? this.id,
      lockMode: lockMode ?? this.lockMode,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lockMode.present) {
      map['lock_mode'] = Variable<String>(lockMode.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSecurityCompanion(')
          ..write('id: $id, ')
          ..write('lockMode: $lockMode, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $EntryRevisionsTable extends EntryRevisions
    with TableInfo<$EntryRevisionsTable, EntryRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    title,
    contentJson,
    plainText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      ),
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EntryRevisionsTable createAlias(String alias) {
    return $EntryRevisionsTable(attachedDatabase, alias);
  }
}

class EntryRevision extends DataClass implements Insertable<EntryRevision> {
  final int id;
  final int entryId;
  final String? title;
  final String? contentJson;
  final String? plainText;
  final DateTime createdAt;
  const EntryRevision({
    required this.id,
    required this.entryId,
    this.title,
    this.contentJson,
    this.plainText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || contentJson != null) {
      map['content_json'] = Variable<String>(contentJson);
    }
    if (!nullToAbsent || plainText != null) {
      map['plain_text'] = Variable<String>(plainText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntryRevisionsCompanion toCompanion(bool nullToAbsent) {
    return EntryRevisionsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      contentJson: contentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contentJson),
      plainText: plainText == null && nullToAbsent
          ? const Value.absent()
          : Value(plainText),
      createdAt: Value(createdAt),
    );
  }

  factory EntryRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRevision(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      title: serializer.fromJson<String?>(json['title']),
      contentJson: serializer.fromJson<String?>(json['contentJson']),
      plainText: serializer.fromJson<String?>(json['plainText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'title': serializer.toJson<String?>(title),
      'contentJson': serializer.toJson<String?>(contentJson),
      'plainText': serializer.toJson<String?>(plainText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EntryRevision copyWith({
    int? id,
    int? entryId,
    Value<String?> title = const Value.absent(),
    Value<String?> contentJson = const Value.absent(),
    Value<String?> plainText = const Value.absent(),
    DateTime? createdAt,
  }) => EntryRevision(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    title: title.present ? title.value : this.title,
    contentJson: contentJson.present ? contentJson.value : this.contentJson,
    plainText: plainText.present ? plainText.value : this.plainText,
    createdAt: createdAt ?? this.createdAt,
  );
  EntryRevision copyWithCompanion(EntryRevisionsCompanion data) {
    return EntryRevision(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      title: data.title.present ? data.title.value : this.title,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRevision(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, title, contentJson, plainText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRevision &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.title == this.title &&
          other.contentJson == this.contentJson &&
          other.plainText == this.plainText &&
          other.createdAt == this.createdAt);
}

class EntryRevisionsCompanion extends UpdateCompanion<EntryRevision> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String?> title;
  final Value<String?> contentJson;
  final Value<String?> plainText;
  final Value<DateTime> createdAt;
  const EntryRevisionsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.title = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.plainText = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EntryRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    this.title = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.plainText = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entryId = Value(entryId);
  static Insertable<EntryRevision> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? title,
    Expression<String>? contentJson,
    Expression<String>? plainText,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (title != null) 'title': title,
      if (contentJson != null) 'content_json': contentJson,
      if (plainText != null) 'plain_text': plainText,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EntryRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String?>? title,
    Value<String?>? contentJson,
    Value<String?>? plainText,
    Value<DateTime>? createdAt,
  }) {
    return EntryRevisionsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      plainText: plainText ?? this.plainText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('title: $title, ')
          ..write('contentJson: $contentJson, ')
          ..write('plainText: $plainText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VoiceNotesTable extends VoiceNotes
    with TableInfo<$VoiceNotesTable, VoiceNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPathMeta = const VerificationMeta(
    'encryptedPath',
  );
  @override
  late final GeneratedColumn<String> encryptedPath = GeneratedColumn<String>(
    'encrypted_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nonceBase64Meta = const VerificationMeta(
    'nonceBase64',
  );
  @override
  late final GeneratedColumn<String> nonceBase64 = GeneratedColumn<String>(
    'nonce_base64',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyReferenceMeta = const VerificationMeta(
    'keyReference',
  );
  @override
  late final GeneratedColumn<String> keyReference = GeneratedColumn<String>(
    'key_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    fileName,
    encryptedPath,
    nonceBase64,
    keyReference,
    durationMs,
    transcript,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('encrypted_path')) {
      context.handle(
        _encryptedPathMeta,
        encryptedPath.isAcceptableOrUnknown(
          data['encrypted_path']!,
          _encryptedPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPathMeta);
    }
    if (data.containsKey('nonce_base64')) {
      context.handle(
        _nonceBase64Meta,
        nonceBase64.isAcceptableOrUnknown(
          data['nonce_base64']!,
          _nonceBase64Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nonceBase64Meta);
    }
    if (data.containsKey('key_reference')) {
      context.handle(
        _keyReferenceMeta,
        keyReference.isAcceptableOrUnknown(
          data['key_reference']!,
          _keyReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_keyReferenceMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      encryptedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_path'],
      )!,
      nonceBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nonce_base64'],
      )!,
      keyReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_reference'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VoiceNotesTable createAlias(String alias) {
    return $VoiceNotesTable(attachedDatabase, alias);
  }
}

class VoiceNote extends DataClass implements Insertable<VoiceNote> {
  final int id;
  final int entryId;
  final String fileName;
  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
  final int durationMs;
  final String? transcript;
  final DateTime createdAt;
  const VoiceNote({
    required this.id,
    required this.entryId,
    required this.fileName,
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
    required this.durationMs,
    this.transcript,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['file_name'] = Variable<String>(fileName);
    map['encrypted_path'] = Variable<String>(encryptedPath);
    map['nonce_base64'] = Variable<String>(nonceBase64);
    map['key_reference'] = Variable<String>(keyReference);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoiceNotesCompanion toCompanion(bool nullToAbsent) {
    return VoiceNotesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      fileName: Value(fileName),
      encryptedPath: Value(encryptedPath),
      nonceBase64: Value(nonceBase64),
      keyReference: Value(keyReference),
      durationMs: Value(durationMs),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceNote(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      encryptedPath: serializer.fromJson<String>(json['encryptedPath']),
      nonceBase64: serializer.fromJson<String>(json['nonceBase64']),
      keyReference: serializer.fromJson<String>(json['keyReference']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'fileName': serializer.toJson<String>(fileName),
      'encryptedPath': serializer.toJson<String>(encryptedPath),
      'nonceBase64': serializer.toJson<String>(nonceBase64),
      'keyReference': serializer.toJson<String>(keyReference),
      'durationMs': serializer.toJson<int>(durationMs),
      'transcript': serializer.toJson<String?>(transcript),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoiceNote copyWith({
    int? id,
    int? entryId,
    String? fileName,
    String? encryptedPath,
    String? nonceBase64,
    String? keyReference,
    int? durationMs,
    Value<String?> transcript = const Value.absent(),
    DateTime? createdAt,
  }) => VoiceNote(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    fileName: fileName ?? this.fileName,
    encryptedPath: encryptedPath ?? this.encryptedPath,
    nonceBase64: nonceBase64 ?? this.nonceBase64,
    keyReference: keyReference ?? this.keyReference,
    durationMs: durationMs ?? this.durationMs,
    transcript: transcript.present ? transcript.value : this.transcript,
    createdAt: createdAt ?? this.createdAt,
  );
  VoiceNote copyWithCompanion(VoiceNotesCompanion data) {
    return VoiceNote(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      encryptedPath: data.encryptedPath.present
          ? data.encryptedPath.value
          : this.encryptedPath,
      nonceBase64: data.nonceBase64.present
          ? data.nonceBase64.value
          : this.nonceBase64,
      keyReference: data.keyReference.present
          ? data.keyReference.value
          : this.keyReference,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceNote(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('fileName: $fileName, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('nonceBase64: $nonceBase64, ')
          ..write('keyReference: $keyReference, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    fileName,
    encryptedPath,
    nonceBase64,
    keyReference,
    durationMs,
    transcript,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceNote &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.fileName == this.fileName &&
          other.encryptedPath == this.encryptedPath &&
          other.nonceBase64 == this.nonceBase64 &&
          other.keyReference == this.keyReference &&
          other.durationMs == this.durationMs &&
          other.transcript == this.transcript &&
          other.createdAt == this.createdAt);
}

class VoiceNotesCompanion extends UpdateCompanion<VoiceNote> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> fileName;
  final Value<String> encryptedPath;
  final Value<String> nonceBase64;
  final Value<String> keyReference;
  final Value<int> durationMs;
  final Value<String?> transcript;
  final Value<DateTime> createdAt;
  const VoiceNotesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.encryptedPath = const Value.absent(),
    this.nonceBase64 = const Value.absent(),
    this.keyReference = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.transcript = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VoiceNotesCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String fileName,
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required int durationMs,
    this.transcript = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entryId = Value(entryId),
       fileName = Value(fileName),
       encryptedPath = Value(encryptedPath),
       nonceBase64 = Value(nonceBase64),
       keyReference = Value(keyReference),
       durationMs = Value(durationMs);
  static Insertable<VoiceNote> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? fileName,
    Expression<String>? encryptedPath,
    Expression<String>? nonceBase64,
    Expression<String>? keyReference,
    Expression<int>? durationMs,
    Expression<String>? transcript,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (fileName != null) 'file_name': fileName,
      if (encryptedPath != null) 'encrypted_path': encryptedPath,
      if (nonceBase64 != null) 'nonce_base64': nonceBase64,
      if (keyReference != null) 'key_reference': keyReference,
      if (durationMs != null) 'duration_ms': durationMs,
      if (transcript != null) 'transcript': transcript,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VoiceNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? fileName,
    Value<String>? encryptedPath,
    Value<String>? nonceBase64,
    Value<String>? keyReference,
    Value<int>? durationMs,
    Value<String?>? transcript,
    Value<DateTime>? createdAt,
  }) {
    return VoiceNotesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      fileName: fileName ?? this.fileName,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      nonceBase64: nonceBase64 ?? this.nonceBase64,
      keyReference: keyReference ?? this.keyReference,
      durationMs: durationMs ?? this.durationMs,
      transcript: transcript ?? this.transcript,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (encryptedPath.present) {
      map['encrypted_path'] = Variable<String>(encryptedPath.value);
    }
    if (nonceBase64.present) {
      map['nonce_base64'] = Variable<String>(nonceBase64.value);
    }
    if (keyReference.present) {
      map['key_reference'] = Variable<String>(keyReference.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceNotesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('fileName: $fileName, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('nonceBase64: $nonceBase64, ')
          ..write('keyReference: $keyReference, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BackupLogsTable extends BackupLogs
    with TableInfo<$BackupLogsTable, BackupLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attachmentCountMeta = const VerificationMeta(
    'attachmentCount',
  );
  @override
  late final GeneratedColumn<int> attachmentCount = GeneratedColumn<int>(
    'attachment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    backupPath,
    sizeBytes,
    entryCount,
    attachmentCount,
    errorMessage,
    trigger,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    }
    if (data.containsKey('attachment_count')) {
      context.handle(
        _attachmentCountMeta,
        attachmentCount.isAcceptableOrUnknown(
          data['attachment_count']!,
          _attachmentCountMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      entryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_count'],
      )!,
      attachmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $BackupLogsTable createAlias(String alias) {
    return $BackupLogsTable(attachedDatabase, alias);
  }
}

class BackupLog extends DataClass implements Insertable<BackupLog> {
  final int id;
  final String status;
  final String? backupPath;
  final int? sizeBytes;
  final int entryCount;
  final int attachmentCount;
  final String? errorMessage;
  final String trigger;
  final DateTime startedAt;
  final DateTime? completedAt;
  const BackupLog({
    required this.id,
    required this.status,
    this.backupPath,
    this.sizeBytes,
    required this.entryCount,
    required this.attachmentCount,
    this.errorMessage,
    required this.trigger,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['entry_count'] = Variable<int>(entryCount);
    map['attachment_count'] = Variable<int>(attachmentCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['trigger'] = Variable<String>(trigger);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  BackupLogsCompanion toCompanion(bool nullToAbsent) {
    return BackupLogsCompanion(
      id: Value(id),
      status: Value(status),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      entryCount: Value(entryCount),
      attachmentCount: Value(attachmentCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      trigger: Value(trigger),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory BackupLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupLog(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      attachmentCount: serializer.fromJson<int>(json['attachmentCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      trigger: serializer.fromJson<String>(json['trigger']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'backupPath': serializer.toJson<String?>(backupPath),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'entryCount': serializer.toJson<int>(entryCount),
      'attachmentCount': serializer.toJson<int>(attachmentCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'trigger': serializer.toJson<String>(trigger),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  BackupLog copyWith({
    int? id,
    String? status,
    Value<String?> backupPath = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    int? entryCount,
    int? attachmentCount,
    Value<String?> errorMessage = const Value.absent(),
    String? trigger,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => BackupLog(
    id: id ?? this.id,
    status: status ?? this.status,
    backupPath: backupPath.present ? backupPath.value : this.backupPath,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    entryCount: entryCount ?? this.entryCount,
    attachmentCount: attachmentCount ?? this.attachmentCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    trigger: trigger ?? this.trigger,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  BackupLog copyWithCompanion(BackupLogsCompanion data) {
    return BackupLog(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      entryCount: data.entryCount.present
          ? data.entryCount.value
          : this.entryCount,
      attachmentCount: data.attachmentCount.present
          ? data.attachmentCount.value
          : this.attachmentCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupLog(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('backupPath: $backupPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('entryCount: $entryCount, ')
          ..write('attachmentCount: $attachmentCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    backupPath,
    sizeBytes,
    entryCount,
    attachmentCount,
    errorMessage,
    trigger,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupLog &&
          other.id == this.id &&
          other.status == this.status &&
          other.backupPath == this.backupPath &&
          other.sizeBytes == this.sizeBytes &&
          other.entryCount == this.entryCount &&
          other.attachmentCount == this.attachmentCount &&
          other.errorMessage == this.errorMessage &&
          other.trigger == this.trigger &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class BackupLogsCompanion extends UpdateCompanion<BackupLog> {
  final Value<int> id;
  final Value<String> status;
  final Value<String?> backupPath;
  final Value<int?> sizeBytes;
  final Value<int> entryCount;
  final Value<int> attachmentCount;
  final Value<String?> errorMessage;
  final Value<String> trigger;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  const BackupLogsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.attachmentCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.trigger = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  BackupLogsCompanion.insert({
    this.id = const Value.absent(),
    required String status,
    this.backupPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.attachmentCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.trigger = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : status = Value(status);
  static Insertable<BackupLog> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<String>? backupPath,
    Expression<int>? sizeBytes,
    Expression<int>? entryCount,
    Expression<int>? attachmentCount,
    Expression<String>? errorMessage,
    Expression<String>? trigger,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (backupPath != null) 'backup_path': backupPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (entryCount != null) 'entry_count': entryCount,
      if (attachmentCount != null) 'attachment_count': attachmentCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (trigger != null) 'trigger': trigger,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  BackupLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? status,
    Value<String?>? backupPath,
    Value<int?>? sizeBytes,
    Value<int>? entryCount,
    Value<int>? attachmentCount,
    Value<String?>? errorMessage,
    Value<String>? trigger,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
  }) {
    return BackupLogsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      backupPath: backupPath ?? this.backupPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      entryCount: entryCount ?? this.entryCount,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      errorMessage: errorMessage ?? this.errorMessage,
      trigger: trigger ?? this.trigger,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (attachmentCount.present) {
      map['attachment_count'] = Variable<int>(attachmentCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupLogsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('backupPath: $backupPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('entryCount: $entryCount, ')
          ..write('attachmentCount: $attachmentCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordTableMeta = const VerificationMeta(
    'recordTable',
  );
  @override
  late final GeneratedColumn<String> recordTable = GeneratedColumn<String>(
    'record_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordTable,
    localId,
    syncId,
    version,
    deviceId,
    isDeleted,
    lastSyncedAt,
    lastModifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_table')) {
      context.handle(
        _recordTableMeta,
        recordTable.isAcceptableOrUnknown(
          data['record_table']!,
          _recordTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordTableMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recordTable, localId},
    {syncId},
  ];
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_table'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final int id;
  final String recordTable;
  final int localId;
  final String syncId;
  final int version;
  final String deviceId;
  final bool isDeleted;
  final DateTime? lastSyncedAt;
  final DateTime lastModifiedAt;
  const SyncMetadataData({
    required this.id,
    required this.recordTable,
    required this.localId,
    required this.syncId,
    required this.version,
    required this.deviceId,
    required this.isDeleted,
    this.lastSyncedAt,
    required this.lastModifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_table'] = Variable<String>(recordTable);
    map['local_id'] = Variable<int>(localId);
    map['sync_id'] = Variable<String>(syncId);
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      recordTable: Value(recordTable),
      localId: Value(localId),
      syncId: Value(syncId),
      version: Value(version),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastModifiedAt: Value(lastModifiedAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      recordTable: serializer.fromJson<String>(json['recordTable']),
      localId: serializer.fromJson<int>(json['localId']),
      syncId: serializer.fromJson<String>(json['syncId']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastModifiedAt: serializer.fromJson<DateTime>(json['lastModifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordTable': serializer.toJson<String>(recordTable),
      'localId': serializer.toJson<int>(localId),
      'syncId': serializer.toJson<String>(syncId),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastModifiedAt': serializer.toJson<DateTime>(lastModifiedAt),
    };
  }

  SyncMetadataData copyWith({
    int? id,
    String? recordTable,
    int? localId,
    String? syncId,
    int? version,
    String? deviceId,
    bool? isDeleted,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? lastModifiedAt,
  }) => SyncMetadataData(
    id: id ?? this.id,
    recordTable: recordTable ?? this.recordTable,
    localId: localId ?? this.localId,
    syncId: syncId ?? this.syncId,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      recordTable: data.recordTable.present
          ? data.recordTable.value
          : this.recordTable,
      localId: data.localId.present ? data.localId.value : this.localId,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('recordTable: $recordTable, ')
          ..write('localId: $localId, ')
          ..write('syncId: $syncId, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastModifiedAt: $lastModifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordTable,
    localId,
    syncId,
    version,
    deviceId,
    isDeleted,
    lastSyncedAt,
    lastModifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.recordTable == this.recordTable &&
          other.localId == this.localId &&
          other.syncId == this.syncId &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastModifiedAt == this.lastModifiedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<int> id;
  final Value<String> recordTable;
  final Value<int> localId;
  final Value<String> syncId;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> lastModifiedAt;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.recordTable = const Value.absent(),
    this.localId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String recordTable,
    required int localId,
    required String syncId,
    this.version = const Value.absent(),
    required String deviceId,
    this.isDeleted = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
  }) : recordTable = Value(recordTable),
       localId = Value(localId),
       syncId = Value(syncId),
       deviceId = Value(deviceId);
  static Insertable<SyncMetadataData> custom({
    Expression<int>? id,
    Expression<String>? recordTable,
    Expression<int>? localId,
    Expression<String>? syncId,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? lastModifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordTable != null) 'record_table': recordTable,
      if (localId != null) 'local_id': localId,
      if (syncId != null) 'sync_id': syncId,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? recordTable,
    Value<int>? localId,
    Value<String>? syncId,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? lastModifiedAt,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      recordTable: recordTable ?? this.recordTable,
      localId: localId ?? this.localId,
      syncId: syncId ?? this.syncId,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordTable.present) {
      map['record_table'] = Variable<String>(recordTable.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('recordTable: $recordTable, ')
          ..write('localId: $localId, ')
          ..write('syncId: $syncId, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastModifiedAt: $lastModifiedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTableMeta = const VerificationMeta(
    'recordTable',
  );
  @override
  late final GeneratedColumn<String> recordTable = GeneratedColumn<String>(
    'record_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteVersionMeta = const VerificationMeta(
    'remoteVersion',
  );
  @override
  late final GeneratedColumn<int> remoteVersion = GeneratedColumn<int>(
    'remote_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDataJsonMeta = const VerificationMeta(
    'localDataJson',
  );
  @override
  late final GeneratedColumn<String> localDataJson = GeneratedColumn<String>(
    'local_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteDataJsonMeta = const VerificationMeta(
    'remoteDataJson',
  );
  @override
  late final GeneratedColumn<String> remoteDataJson = GeneratedColumn<String>(
    'remote_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    recordTable,
    localVersion,
    remoteVersion,
    localDataJson,
    remoteDataJson,
    status,
    resolution,
    detectedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('record_table')) {
      context.handle(
        _recordTableMeta,
        recordTable.isAcceptableOrUnknown(
          data['record_table']!,
          _recordTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordTableMeta);
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localVersionMeta);
    }
    if (data.containsKey('remote_version')) {
      context.handle(
        _remoteVersionMeta,
        remoteVersion.isAcceptableOrUnknown(
          data['remote_version']!,
          _remoteVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteVersionMeta);
    }
    if (data.containsKey('local_data_json')) {
      context.handle(
        _localDataJsonMeta,
        localDataJson.isAcceptableOrUnknown(
          data['local_data_json']!,
          _localDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localDataJsonMeta);
    }
    if (data.containsKey('remote_data_json')) {
      context.handle(
        _remoteDataJsonMeta,
        remoteDataJson.isAcceptableOrUnknown(
          data['remote_data_json']!,
          _remoteDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteDataJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      recordTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_table'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      remoteVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_version'],
      )!,
      localDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_data_json'],
      )!,
      remoteDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_data_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final int id;
  final String syncId;
  final String recordTable;
  final int localVersion;
  final int remoteVersion;
  final String localDataJson;
  final String remoteDataJson;
  final String status;
  final String? resolution;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  const SyncConflict({
    required this.id,
    required this.syncId,
    required this.recordTable,
    required this.localVersion,
    required this.remoteVersion,
    required this.localDataJson,
    required this.remoteDataJson,
    required this.status,
    this.resolution,
    required this.detectedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['record_table'] = Variable<String>(recordTable);
    map['local_version'] = Variable<int>(localVersion);
    map['remote_version'] = Variable<int>(remoteVersion);
    map['local_data_json'] = Variable<String>(localDataJson);
    map['remote_data_json'] = Variable<String>(remoteDataJson);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      recordTable: Value(recordTable),
      localVersion: Value(localVersion),
      remoteVersion: Value(remoteVersion),
      localDataJson: Value(localDataJson),
      remoteDataJson: Value(remoteDataJson),
      status: Value(status),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      recordTable: serializer.fromJson<String>(json['recordTable']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      remoteVersion: serializer.fromJson<int>(json['remoteVersion']),
      localDataJson: serializer.fromJson<String>(json['localDataJson']),
      remoteDataJson: serializer.fromJson<String>(json['remoteDataJson']),
      status: serializer.fromJson<String>(json['status']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'recordTable': serializer.toJson<String>(recordTable),
      'localVersion': serializer.toJson<int>(localVersion),
      'remoteVersion': serializer.toJson<int>(remoteVersion),
      'localDataJson': serializer.toJson<String>(localDataJson),
      'remoteDataJson': serializer.toJson<String>(remoteDataJson),
      'status': serializer.toJson<String>(status),
      'resolution': serializer.toJson<String?>(resolution),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflict copyWith({
    int? id,
    String? syncId,
    String? recordTable,
    int? localVersion,
    int? remoteVersion,
    String? localDataJson,
    String? remoteDataJson,
    String? status,
    Value<String?> resolution = const Value.absent(),
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    recordTable: recordTable ?? this.recordTable,
    localVersion: localVersion ?? this.localVersion,
    remoteVersion: remoteVersion ?? this.remoteVersion,
    localDataJson: localDataJson ?? this.localDataJson,
    remoteDataJson: remoteDataJson ?? this.remoteDataJson,
    status: status ?? this.status,
    resolution: resolution.present ? resolution.value : this.resolution,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      recordTable: data.recordTable.present
          ? data.recordTable.value
          : this.recordTable,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      remoteVersion: data.remoteVersion.present
          ? data.remoteVersion.value
          : this.remoteVersion,
      localDataJson: data.localDataJson.present
          ? data.localDataJson.value
          : this.localDataJson,
      remoteDataJson: data.remoteDataJson.present
          ? data.remoteDataJson.value
          : this.remoteDataJson,
      status: data.status.present ? data.status.value : this.status,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('recordTable: $recordTable, ')
          ..write('localVersion: $localVersion, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('localDataJson: $localDataJson, ')
          ..write('remoteDataJson: $remoteDataJson, ')
          ..write('status: $status, ')
          ..write('resolution: $resolution, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    recordTable,
    localVersion,
    remoteVersion,
    localDataJson,
    remoteDataJson,
    status,
    resolution,
    detectedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.recordTable == this.recordTable &&
          other.localVersion == this.localVersion &&
          other.remoteVersion == this.remoteVersion &&
          other.localDataJson == this.localDataJson &&
          other.remoteDataJson == this.remoteDataJson &&
          other.status == this.status &&
          other.resolution == this.resolution &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<String> recordTable;
  final Value<int> localVersion;
  final Value<int> remoteVersion;
  final Value<String> localDataJson;
  final Value<String> remoteDataJson;
  final Value<String> status;
  final Value<String?> resolution;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.recordTable = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.remoteVersion = const Value.absent(),
    this.localDataJson = const Value.absent(),
    this.remoteDataJson = const Value.absent(),
    this.status = const Value.absent(),
    this.resolution = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required String recordTable,
    required int localVersion,
    required int remoteVersion,
    required String localDataJson,
    required String remoteDataJson,
    this.status = const Value.absent(),
    this.resolution = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  }) : syncId = Value(syncId),
       recordTable = Value(recordTable),
       localVersion = Value(localVersion),
       remoteVersion = Value(remoteVersion),
       localDataJson = Value(localDataJson),
       remoteDataJson = Value(remoteDataJson);
  static Insertable<SyncConflict> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? recordTable,
    Expression<int>? localVersion,
    Expression<int>? remoteVersion,
    Expression<String>? localDataJson,
    Expression<String>? remoteDataJson,
    Expression<String>? status,
    Expression<String>? resolution,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (recordTable != null) 'record_table': recordTable,
      if (localVersion != null) 'local_version': localVersion,
      if (remoteVersion != null) 'remote_version': remoteVersion,
      if (localDataJson != null) 'local_data_json': localDataJson,
      if (remoteDataJson != null) 'remote_data_json': remoteDataJson,
      if (status != null) 'status': status,
      if (resolution != null) 'resolution': resolution,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<String>? recordTable,
    Value<int>? localVersion,
    Value<int>? remoteVersion,
    Value<String>? localDataJson,
    Value<String>? remoteDataJson,
    Value<String>? status,
    Value<String?>? resolution,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      recordTable: recordTable ?? this.recordTable,
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      localDataJson: localDataJson ?? this.localDataJson,
      remoteDataJson: remoteDataJson ?? this.remoteDataJson,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (recordTable.present) {
      map['record_table'] = Variable<String>(recordTable.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (remoteVersion.present) {
      map['remote_version'] = Variable<int>(remoteVersion.value);
    }
    if (localDataJson.present) {
      map['local_data_json'] = Variable<String>(localDataJson.value);
    }
    if (remoteDataJson.present) {
      map['remote_data_json'] = Variable<String>(remoteDataJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('recordTable: $recordTable, ')
          ..write('localVersion: $localVersion, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('localDataJson: $localDataJson, ')
          ..write('remoteDataJson: $remoteDataJson, ')
          ..write('status: $status, ')
          ..write('resolution: $resolution, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs with TableInfo<$SyncLogsTable, SyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bidirectional'),
  );
  static const VerificationMeta _recordsPushedMeta = const VerificationMeta(
    'recordsPushed',
  );
  @override
  late final GeneratedColumn<int> recordsPushed = GeneratedColumn<int>(
    'records_pushed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordsPulledMeta = const VerificationMeta(
    'recordsPulled',
  );
  @override
  late final GeneratedColumn<int> recordsPulled = GeneratedColumn<int>(
    'records_pulled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conflictsDetectedMeta = const VerificationMeta(
    'conflictsDetected',
  );
  @override
  late final GeneratedColumn<int> conflictsDetected = GeneratedColumn<int>(
    'conflicts_detected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    direction,
    recordsPushed,
    recordsPulled,
    conflictsDetected,
    errorMessage,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('records_pushed')) {
      context.handle(
        _recordsPushedMeta,
        recordsPushed.isAcceptableOrUnknown(
          data['records_pushed']!,
          _recordsPushedMeta,
        ),
      );
    }
    if (data.containsKey('records_pulled')) {
      context.handle(
        _recordsPulledMeta,
        recordsPulled.isAcceptableOrUnknown(
          data['records_pulled']!,
          _recordsPulledMeta,
        ),
      );
    }
    if (data.containsKey('conflicts_detected')) {
      context.handle(
        _conflictsDetectedMeta,
        conflictsDetected.isAcceptableOrUnknown(
          data['conflicts_detected']!,
          _conflictsDetectedMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      recordsPushed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_pushed'],
      )!,
      recordsPulled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}records_pulled'],
      )!,
      conflictsDetected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conflicts_detected'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class SyncLog extends DataClass implements Insertable<SyncLog> {
  final int id;
  final String status;
  final String direction;
  final int recordsPushed;
  final int recordsPulled;
  final int conflictsDetected;
  final String? errorMessage;
  final DateTime startedAt;
  final DateTime? completedAt;
  const SyncLog({
    required this.id,
    required this.status,
    required this.direction,
    required this.recordsPushed,
    required this.recordsPulled,
    required this.conflictsDetected,
    this.errorMessage,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    map['direction'] = Variable<String>(direction);
    map['records_pushed'] = Variable<int>(recordsPushed);
    map['records_pulled'] = Variable<int>(recordsPulled);
    map['conflicts_detected'] = Variable<int>(conflictsDetected);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      status: Value(status),
      direction: Value(direction),
      recordsPushed: Value(recordsPushed),
      recordsPulled: Value(recordsPulled),
      conflictsDetected: Value(conflictsDetected),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLog(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      direction: serializer.fromJson<String>(json['direction']),
      recordsPushed: serializer.fromJson<int>(json['recordsPushed']),
      recordsPulled: serializer.fromJson<int>(json['recordsPulled']),
      conflictsDetected: serializer.fromJson<int>(json['conflictsDetected']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'direction': serializer.toJson<String>(direction),
      'recordsPushed': serializer.toJson<int>(recordsPushed),
      'recordsPulled': serializer.toJson<int>(recordsPulled),
      'conflictsDetected': serializer.toJson<int>(conflictsDetected),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SyncLog copyWith({
    int? id,
    String? status,
    String? direction,
    int? recordsPushed,
    int? recordsPulled,
    int? conflictsDetected,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => SyncLog(
    id: id ?? this.id,
    status: status ?? this.status,
    direction: direction ?? this.direction,
    recordsPushed: recordsPushed ?? this.recordsPushed,
    recordsPulled: recordsPulled ?? this.recordsPulled,
    conflictsDetected: conflictsDetected ?? this.conflictsDetected,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SyncLog copyWithCompanion(SyncLogsCompanion data) {
    return SyncLog(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      direction: data.direction.present ? data.direction.value : this.direction,
      recordsPushed: data.recordsPushed.present
          ? data.recordsPushed.value
          : this.recordsPushed,
      recordsPulled: data.recordsPulled.present
          ? data.recordsPulled.value
          : this.recordsPulled,
      conflictsDetected: data.conflictsDetected.present
          ? data.conflictsDetected.value
          : this.conflictsDetected,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLog(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('direction: $direction, ')
          ..write('recordsPushed: $recordsPushed, ')
          ..write('recordsPulled: $recordsPulled, ')
          ..write('conflictsDetected: $conflictsDetected, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    direction,
    recordsPushed,
    recordsPulled,
    conflictsDetected,
    errorMessage,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLog &&
          other.id == this.id &&
          other.status == this.status &&
          other.direction == this.direction &&
          other.recordsPushed == this.recordsPushed &&
          other.recordsPulled == this.recordsPulled &&
          other.conflictsDetected == this.conflictsDetected &&
          other.errorMessage == this.errorMessage &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class SyncLogsCompanion extends UpdateCompanion<SyncLog> {
  final Value<int> id;
  final Value<String> status;
  final Value<String> direction;
  final Value<int> recordsPushed;
  final Value<int> recordsPulled;
  final Value<int> conflictsDetected;
  final Value<String?> errorMessage;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.direction = const Value.absent(),
    this.recordsPushed = const Value.absent(),
    this.recordsPulled = const Value.absent(),
    this.conflictsDetected = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    this.id = const Value.absent(),
    required String status,
    this.direction = const Value.absent(),
    this.recordsPushed = const Value.absent(),
    this.recordsPulled = const Value.absent(),
    this.conflictsDetected = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : status = Value(status);
  static Insertable<SyncLog> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<String>? direction,
    Expression<int>? recordsPushed,
    Expression<int>? recordsPulled,
    Expression<int>? conflictsDetected,
    Expression<String>? errorMessage,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (direction != null) 'direction': direction,
      if (recordsPushed != null) 'records_pushed': recordsPushed,
      if (recordsPulled != null) 'records_pulled': recordsPulled,
      if (conflictsDetected != null) 'conflicts_detected': conflictsDetected,
      if (errorMessage != null) 'error_message': errorMessage,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  SyncLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? status,
    Value<String>? direction,
    Value<int>? recordsPushed,
    Value<int>? recordsPulled,
    Value<int>? conflictsDetected,
    Value<String?>? errorMessage,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      recordsPushed: recordsPushed ?? this.recordsPushed,
      recordsPulled: recordsPulled ?? this.recordsPulled,
      conflictsDetected: conflictsDetected ?? this.conflictsDetected,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (recordsPushed.present) {
      map['records_pushed'] = Variable<int>(recordsPushed.value);
    }
    if (recordsPulled.present) {
      map['records_pulled'] = Variable<int>(recordsPulled.value);
    }
    if (conflictsDetected.present) {
      map['conflicts_detected'] = Variable<int>(conflictsDetected.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('direction: $direction, ')
          ..write('recordsPushed: $recordsPushed, ')
          ..write('recordsPulled: $recordsPulled, ')
          ..write('conflictsDetected: $conflictsDetected, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $AutoLockProfilesTable extends AutoLockProfiles
    with TableInfo<$AutoLockProfilesTable, AutoLockProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutoLockProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeoutSecondsMeta = const VerificationMeta(
    'timeoutSeconds',
  );
  @override
  late final GeneratedColumn<int> timeoutSeconds = GeneratedColumn<int>(
    'timeout_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(300),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lockOnMinimizeMeta = const VerificationMeta(
    'lockOnMinimize',
  );
  @override
  late final GeneratedColumn<bool> lockOnMinimize = GeneratedColumn<bool>(
    'lock_on_minimize',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lock_on_minimize" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _scheduleCronMeta = const VerificationMeta(
    'scheduleCron',
  );
  @override
  late final GeneratedColumn<String> scheduleCron = GeneratedColumn<String>(
    'schedule_cron',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    timeoutSeconds,
    isActive,
    lockOnMinimize,
    scheduleCron,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auto_lock_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AutoLockProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timeout_seconds')) {
      context.handle(
        _timeoutSecondsMeta,
        timeoutSeconds.isAcceptableOrUnknown(
          data['timeout_seconds']!,
          _timeoutSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('lock_on_minimize')) {
      context.handle(
        _lockOnMinimizeMeta,
        lockOnMinimize.isAcceptableOrUnknown(
          data['lock_on_minimize']!,
          _lockOnMinimizeMeta,
        ),
      );
    }
    if (data.containsKey('schedule_cron')) {
      context.handle(
        _scheduleCronMeta,
        scheduleCron.isAcceptableOrUnknown(
          data['schedule_cron']!,
          _scheduleCronMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutoLockProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutoLockProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeout_seconds'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lockOnMinimize: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lock_on_minimize'],
      )!,
      scheduleCron: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_cron'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AutoLockProfilesTable createAlias(String alias) {
    return $AutoLockProfilesTable(attachedDatabase, alias);
  }
}

class AutoLockProfile extends DataClass implements Insertable<AutoLockProfile> {
  final int id;
  final String name;
  final int timeoutSeconds;
  final bool isActive;
  final bool lockOnMinimize;
  final String? scheduleCron;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AutoLockProfile({
    required this.id,
    required this.name,
    required this.timeoutSeconds,
    required this.isActive,
    required this.lockOnMinimize,
    this.scheduleCron,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['timeout_seconds'] = Variable<int>(timeoutSeconds);
    map['is_active'] = Variable<bool>(isActive);
    map['lock_on_minimize'] = Variable<bool>(lockOnMinimize);
    if (!nullToAbsent || scheduleCron != null) {
      map['schedule_cron'] = Variable<String>(scheduleCron);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AutoLockProfilesCompanion toCompanion(bool nullToAbsent) {
    return AutoLockProfilesCompanion(
      id: Value(id),
      name: Value(name),
      timeoutSeconds: Value(timeoutSeconds),
      isActive: Value(isActive),
      lockOnMinimize: Value(lockOnMinimize),
      scheduleCron: scheduleCron == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleCron),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AutoLockProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutoLockProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timeoutSeconds: serializer.fromJson<int>(json['timeoutSeconds']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lockOnMinimize: serializer.fromJson<bool>(json['lockOnMinimize']),
      scheduleCron: serializer.fromJson<String?>(json['scheduleCron']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'timeoutSeconds': serializer.toJson<int>(timeoutSeconds),
      'isActive': serializer.toJson<bool>(isActive),
      'lockOnMinimize': serializer.toJson<bool>(lockOnMinimize),
      'scheduleCron': serializer.toJson<String?>(scheduleCron),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AutoLockProfile copyWith({
    int? id,
    String? name,
    int? timeoutSeconds,
    bool? isActive,
    bool? lockOnMinimize,
    Value<String?> scheduleCron = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AutoLockProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    isActive: isActive ?? this.isActive,
    lockOnMinimize: lockOnMinimize ?? this.lockOnMinimize,
    scheduleCron: scheduleCron.present ? scheduleCron.value : this.scheduleCron,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AutoLockProfile copyWithCompanion(AutoLockProfilesCompanion data) {
    return AutoLockProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      timeoutSeconds: data.timeoutSeconds.present
          ? data.timeoutSeconds.value
          : this.timeoutSeconds,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lockOnMinimize: data.lockOnMinimize.present
          ? data.lockOnMinimize.value
          : this.lockOnMinimize,
      scheduleCron: data.scheduleCron.present
          ? data.scheduleCron.value
          : this.scheduleCron,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutoLockProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('isActive: $isActive, ')
          ..write('lockOnMinimize: $lockOnMinimize, ')
          ..write('scheduleCron: $scheduleCron, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    timeoutSeconds,
    isActive,
    lockOnMinimize,
    scheduleCron,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutoLockProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.timeoutSeconds == this.timeoutSeconds &&
          other.isActive == this.isActive &&
          other.lockOnMinimize == this.lockOnMinimize &&
          other.scheduleCron == this.scheduleCron &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AutoLockProfilesCompanion extends UpdateCompanion<AutoLockProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> timeoutSeconds;
  final Value<bool> isActive;
  final Value<bool> lockOnMinimize;
  final Value<String?> scheduleCron;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AutoLockProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lockOnMinimize = const Value.absent(),
    this.scheduleCron = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AutoLockProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.timeoutSeconds = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lockOnMinimize = const Value.absent(),
    this.scheduleCron = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AutoLockProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? timeoutSeconds,
    Expression<bool>? isActive,
    Expression<bool>? lockOnMinimize,
    Expression<String>? scheduleCron,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
      if (isActive != null) 'is_active': isActive,
      if (lockOnMinimize != null) 'lock_on_minimize': lockOnMinimize,
      if (scheduleCron != null) 'schedule_cron': scheduleCron,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AutoLockProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? timeoutSeconds,
    Value<bool>? isActive,
    Value<bool>? lockOnMinimize,
    Value<String?>? scheduleCron,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AutoLockProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      isActive: isActive ?? this.isActive,
      lockOnMinimize: lockOnMinimize ?? this.lockOnMinimize,
      scheduleCron: scheduleCron ?? this.scheduleCron,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timeoutSeconds.present) {
      map['timeout_seconds'] = Variable<int>(timeoutSeconds.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lockOnMinimize.present) {
      map['lock_on_minimize'] = Variable<bool>(lockOnMinimize.value);
    }
    if (scheduleCron.present) {
      map['schedule_cron'] = Variable<String>(scheduleCron.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutoLockProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('isActive: $isActive, ')
          ..write('lockOnMinimize: $lockOnMinimize, ')
          ..write('scheduleCron: $scheduleCron, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentLocksTable extends AttachmentLocks
    with TableInfo<$AttachmentLocksTable, AttachmentLock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentLocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<int> attachmentId = GeneratedColumn<int>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attachments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _credentialReferenceMeta =
      const VerificationMeta('credentialReference');
  @override
  late final GeneratedColumn<String> credentialReference =
      GeneratedColumn<String>(
        'credential_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lockedAtMeta = const VerificationMeta(
    'lockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lockedAt = GeneratedColumn<DateTime>(
    'locked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attachmentId,
    isLocked,
    credentialReference,
    lockedAt,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_locks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentLock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('credential_reference')) {
      context.handle(
        _credentialReferenceMeta,
        credentialReference.isAcceptableOrUnknown(
          data['credential_reference']!,
          _credentialReferenceMeta,
        ),
      );
    }
    if (data.containsKey('locked_at')) {
      context.handle(
        _lockedAtMeta,
        lockedAt.isAcceptableOrUnknown(data['locked_at']!, _lockedAtMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {attachmentId},
  ];
  @override
  AttachmentLock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentLock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_id'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      credentialReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_reference'],
      ),
      lockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_at'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $AttachmentLocksTable createAlias(String alias) {
    return $AttachmentLocksTable(attachedDatabase, alias);
  }
}

class AttachmentLock extends DataClass implements Insertable<AttachmentLock> {
  final int id;
  final int attachmentId;
  final bool isLocked;
  final String? credentialReference;
  final DateTime lockedAt;
  final DateTime? unlockedAt;
  const AttachmentLock({
    required this.id,
    required this.attachmentId,
    required this.isLocked,
    this.credentialReference,
    required this.lockedAt,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attachment_id'] = Variable<int>(attachmentId);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || credentialReference != null) {
      map['credential_reference'] = Variable<String>(credentialReference);
    }
    map['locked_at'] = Variable<DateTime>(lockedAt);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  AttachmentLocksCompanion toCompanion(bool nullToAbsent) {
    return AttachmentLocksCompanion(
      id: Value(id),
      attachmentId: Value(attachmentId),
      isLocked: Value(isLocked),
      credentialReference: credentialReference == null && nullToAbsent
          ? const Value.absent()
          : Value(credentialReference),
      lockedAt: Value(lockedAt),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory AttachmentLock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentLock(
      id: serializer.fromJson<int>(json['id']),
      attachmentId: serializer.fromJson<int>(json['attachmentId']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      credentialReference: serializer.fromJson<String?>(
        json['credentialReference'],
      ),
      lockedAt: serializer.fromJson<DateTime>(json['lockedAt']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attachmentId': serializer.toJson<int>(attachmentId),
      'isLocked': serializer.toJson<bool>(isLocked),
      'credentialReference': serializer.toJson<String?>(credentialReference),
      'lockedAt': serializer.toJson<DateTime>(lockedAt),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  AttachmentLock copyWith({
    int? id,
    int? attachmentId,
    bool? isLocked,
    Value<String?> credentialReference = const Value.absent(),
    DateTime? lockedAt,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => AttachmentLock(
    id: id ?? this.id,
    attachmentId: attachmentId ?? this.attachmentId,
    isLocked: isLocked ?? this.isLocked,
    credentialReference: credentialReference.present
        ? credentialReference.value
        : this.credentialReference,
    lockedAt: lockedAt ?? this.lockedAt,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  AttachmentLock copyWithCompanion(AttachmentLocksCompanion data) {
    return AttachmentLock(
      id: data.id.present ? data.id.value : this.id,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      credentialReference: data.credentialReference.present
          ? data.credentialReference.value
          : this.credentialReference,
      lockedAt: data.lockedAt.present ? data.lockedAt.value : this.lockedAt,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentLock(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('isLocked: $isLocked, ')
          ..write('credentialReference: $credentialReference, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attachmentId,
    isLocked,
    credentialReference,
    lockedAt,
    unlockedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentLock &&
          other.id == this.id &&
          other.attachmentId == this.attachmentId &&
          other.isLocked == this.isLocked &&
          other.credentialReference == this.credentialReference &&
          other.lockedAt == this.lockedAt &&
          other.unlockedAt == this.unlockedAt);
}

class AttachmentLocksCompanion extends UpdateCompanion<AttachmentLock> {
  final Value<int> id;
  final Value<int> attachmentId;
  final Value<bool> isLocked;
  final Value<String?> credentialReference;
  final Value<DateTime> lockedAt;
  final Value<DateTime?> unlockedAt;
  const AttachmentLocksCompanion({
    this.id = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.credentialReference = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  AttachmentLocksCompanion.insert({
    this.id = const Value.absent(),
    required int attachmentId,
    this.isLocked = const Value.absent(),
    this.credentialReference = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  }) : attachmentId = Value(attachmentId);
  static Insertable<AttachmentLock> custom({
    Expression<int>? id,
    Expression<int>? attachmentId,
    Expression<bool>? isLocked,
    Expression<String>? credentialReference,
    Expression<DateTime>? lockedAt,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (isLocked != null) 'is_locked': isLocked,
      if (credentialReference != null)
        'credential_reference': credentialReference,
      if (lockedAt != null) 'locked_at': lockedAt,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  AttachmentLocksCompanion copyWith({
    Value<int>? id,
    Value<int>? attachmentId,
    Value<bool>? isLocked,
    Value<String?>? credentialReference,
    Value<DateTime>? lockedAt,
    Value<DateTime?>? unlockedAt,
  }) {
    return AttachmentLocksCompanion(
      id: id ?? this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      isLocked: isLocked ?? this.isLocked,
      credentialReference: credentialReference ?? this.credentialReference,
      lockedAt: lockedAt ?? this.lockedAt,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<int>(attachmentId.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (credentialReference.present) {
      map['credential_reference'] = Variable<String>(credentialReference.value);
    }
    if (lockedAt.present) {
      map['locked_at'] = Variable<DateTime>(lockedAt.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentLocksCompanion(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('isLocked: $isLocked, ')
          ..write('credentialReference: $credentialReference, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $SecurityEventsTable extends SecurityEvents
    with TableInfo<$SecurityEventsTable, SecurityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecurityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('info'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    severity,
    description,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'security_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecurityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SecurityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecurityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SecurityEventsTable createAlias(String alias) {
    return $SecurityEventsTable(attachedDatabase, alias);
  }
}

class SecurityEvent extends DataClass implements Insertable<SecurityEvent> {
  final int id;
  final String eventType;
  final String severity;
  final String description;
  final String? metadata;
  final DateTime createdAt;
  const SecurityEvent({
    required this.id,
    required this.eventType,
    required this.severity,
    required this.description,
    this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_type'] = Variable<String>(eventType);
    map['severity'] = Variable<String>(severity);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SecurityEventsCompanion toCompanion(bool nullToAbsent) {
    return SecurityEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      severity: Value(severity),
      description: Value(description),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory SecurityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecurityEvent(
      id: serializer.fromJson<int>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      severity: serializer.fromJson<String>(json['severity']),
      description: serializer.fromJson<String>(json['description']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(eventType),
      'severity': serializer.toJson<String>(severity),
      'description': serializer.toJson<String>(description),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SecurityEvent copyWith({
    int? id,
    String? eventType,
    String? severity,
    String? description,
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
  }) => SecurityEvent(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    severity: severity ?? this.severity,
    description: description ?? this.description,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  SecurityEvent copyWithCompanion(SecurityEventsCompanion data) {
    return SecurityEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      severity: data.severity.present ? data.severity.value : this.severity,
      description: data.description.present
          ? data.description.value
          : this.description,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecurityEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventType, severity, description, metadata, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecurityEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.severity == this.severity &&
          other.description == this.description &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class SecurityEventsCompanion extends UpdateCompanion<SecurityEvent> {
  final Value<int> id;
  final Value<String> eventType;
  final Value<String> severity;
  final Value<String> description;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  const SecurityEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SecurityEventsCompanion.insert({
    this.id = const Value.absent(),
    required String eventType,
    this.severity = const Value.absent(),
    required String description,
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : eventType = Value(eventType),
       description = Value(description);
  static Insertable<SecurityEvent> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<String>? severity,
    Expression<String>? description,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (severity != null) 'severity': severity,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SecurityEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventType,
    Value<String>? severity,
    Value<String>? description,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
  }) {
    return SecurityEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecurityEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EntryMoodsTable extends EntryMoods
    with TableInfo<$EntryMoodsTable, EntryMood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryMoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    mood,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_moods';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryMood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entryId},
  ];
  @override
  EntryMood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryMood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntryMoodsTable createAlias(String alias) {
    return $EntryMoodsTable(attachedDatabase, alias);
  }
}

class EntryMood extends DataClass implements Insertable<EntryMood> {
  final int id;
  final int entryId;
  final int mood;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryMood({
    required this.id,
    required this.entryId,
    required this.mood,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['mood'] = Variable<int>(mood);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntryMoodsCompanion toCompanion(bool nullToAbsent) {
    return EntryMoodsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      mood: Value(mood),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryMood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryMood(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      mood: serializer.fromJson<int>(json['mood']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'mood': serializer.toJson<int>(mood),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryMood copyWith({
    int? id,
    int? entryId,
    int? mood,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntryMood(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    mood: mood ?? this.mood,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntryMood copyWithCompanion(EntryMoodsCompanion data) {
    return EntryMood(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      mood: data.mood.present ? data.mood.value : this.mood,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryMood(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, mood, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryMood &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.mood == this.mood &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntryMoodsCompanion extends UpdateCompanion<EntryMood> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<int> mood;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntryMoodsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntryMoodsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required int mood,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : entryId = Value(entryId),
       mood = Value(mood);
  static Insertable<EntryMood> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<int>? mood,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (mood != null) 'mood': mood,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntryMoodsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<int>? mood,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntryMoodsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryMoodsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JournalsTable journals = $JournalsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $JournalTagsTable journalTags = $JournalTagsTable(this);
  late final $EntryTagsTable entryTags = $EntryTagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $AttachmentTextsTable attachmentTexts = $AttachmentTextsTable(
    this,
  );
  late final $BacklinksTable backlinks = $BacklinksTable(this);
  late final $SearchPresetsTable searchPresets = $SearchPresetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AppSecurityTable appSecurity = $AppSecurityTable(this);
  late final $EntryRevisionsTable entryRevisions = $EntryRevisionsTable(this);
  late final $VoiceNotesTable voiceNotes = $VoiceNotesTable(this);
  late final $BackupLogsTable backupLogs = $BackupLogsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $AutoLockProfilesTable autoLockProfiles = $AutoLockProfilesTable(
    this,
  );
  late final $AttachmentLocksTable attachmentLocks = $AttachmentLocksTable(
    this,
  );
  late final $SecurityEventsTable securityEvents = $SecurityEventsTable(this);
  late final $EntryMoodsTable entryMoods = $EntryMoodsTable(this);
  late final JournalsDao journalsDao = JournalsDao(this as AppDatabase);
  late final EntriesDao entriesDao = EntriesDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final AttachmentsDao attachmentsDao = AttachmentsDao(
    this as AppDatabase,
  );
  late final AttachmentTextsDao attachmentTextsDao = AttachmentTextsDao(
    this as AppDatabase,
  );
  late final BacklinksDao backlinksDao = BacklinksDao(this as AppDatabase);
  late final BackupLogsDao backupLogsDao = BackupLogsDao(this as AppDatabase);
  late final SearchPresetsDao searchPresetsDao = SearchPresetsDao(
    this as AppDatabase,
  );
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final AppSecurityDao appSecurityDao = AppSecurityDao(
    this as AppDatabase,
  );
  late final JournalTagsDao journalTagsDao = JournalTagsDao(
    this as AppDatabase,
  );
  late final EntryRevisionsDao entryRevisionsDao = EntryRevisionsDao(
    this as AppDatabase,
  );
  late final VoiceNotesDao voiceNotesDao = VoiceNotesDao(this as AppDatabase);
  late final SyncMetadataDao syncMetadataDao = SyncMetadataDao(
    this as AppDatabase,
  );
  late final SyncConflictsDao syncConflictsDao = SyncConflictsDao(
    this as AppDatabase,
  );
  late final SyncLogsDao syncLogsDao = SyncLogsDao(this as AppDatabase);
  late final AutoLockProfilesDao autoLockProfilesDao = AutoLockProfilesDao(
    this as AppDatabase,
  );
  late final AttachmentLocksDao attachmentLocksDao = AttachmentLocksDao(
    this as AppDatabase,
  );
  late final SecurityEventsDao securityEventsDao = SecurityEventsDao(
    this as AppDatabase,
  );
  late final EntryMoodsDao entryMoodsDao = EntryMoodsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journals,
    entries,
    tags,
    journalTags,
    entryTags,
    attachments,
    attachmentTexts,
    backlinks,
    searchPresets,
    appSettings,
    appSecurity,
    entryRevisions,
    voiceNotes,
    backupLogs,
    syncMetadata,
    syncConflicts,
    syncLogs,
    autoLockProfiles,
    attachmentLocks,
    securityEvents,
    entryMoods,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'attachments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachment_texts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('backlinks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_revisions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('voice_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'attachments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachment_locks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_moods', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JournalsTableCreateCompanionBuilder =
    JournalsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<bool> isLocked,
      Value<String?> credentialReference,
      Value<String?> passwordSaltBase64,
      Value<String?> passwordVerifierBase64,
      Value<int?> passwordIterations,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$JournalsTableUpdateCompanionBuilder =
    JournalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<bool> isLocked,
      Value<String?> credentialReference,
      Value<String?> passwordSaltBase64,
      Value<String?> passwordVerifierBase64,
      Value<int?> passwordIterations,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$JournalsTableReferences
    extends BaseReferences<_$AppDatabase, $JournalsTable, Journal> {
  $$JournalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.journals.id, db.entries.journalId),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.journalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JournalTagsTable, List<JournalTag>>
  _journalTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.journalTags,
    aliasName: $_aliasNameGenerator(db.journals.id, db.journalTags.journalId),
  );

  $$JournalTagsTableProcessedTableManager get journalTagsRefs {
    final manager = $$JournalTagsTableTableManager(
      $_db,
      $_db.journalTags,
    ).filter((f) => f.journalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JournalsTableFilterComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSaltBase64 => $composableBuilder(
    column: $table.passwordSaltBase64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordVerifierBase64 => $composableBuilder(
    column: $table.passwordVerifierBase64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.journalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> journalTagsRefs(
    Expression<bool> Function($$JournalTagsTableFilterComposer f) f,
  ) {
    final $$JournalTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalTags,
      getReferencedColumn: (t) => t.journalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalTagsTableFilterComposer(
            $db: $db,
            $table: $db.journalTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSaltBase64 => $composableBuilder(
    column: $table.passwordSaltBase64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordVerifierBase64 => $composableBuilder(
    column: $table.passwordVerifierBase64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalsTable> {
  $$JournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSaltBase64 => $composableBuilder(
    column: $table.passwordSaltBase64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordVerifierBase64 => $composableBuilder(
    column: $table.passwordVerifierBase64,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.journalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> journalTagsRefs<T extends Object>(
    Expression<T> Function($$JournalTagsTableAnnotationComposer a) f,
  ) {
    final $$JournalTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalTags,
      getReferencedColumn: (t) => t.journalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.journalTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalsTable,
          Journal,
          $$JournalsTableFilterComposer,
          $$JournalsTableOrderingComposer,
          $$JournalsTableAnnotationComposer,
          $$JournalsTableCreateCompanionBuilder,
          $$JournalsTableUpdateCompanionBuilder,
          (Journal, $$JournalsTableReferences),
          Journal,
          PrefetchHooks Function({bool entriesRefs, bool journalTagsRefs})
        > {
  $$JournalsTableTableManager(_$AppDatabase db, $JournalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String?> credentialReference = const Value.absent(),
                Value<String?> passwordSaltBase64 = const Value.absent(),
                Value<String?> passwordVerifierBase64 = const Value.absent(),
                Value<int?> passwordIterations = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JournalsCompanion(
                id: id,
                title: title,
                description: description,
                isLocked: isLocked,
                credentialReference: credentialReference,
                passwordSaltBase64: passwordSaltBase64,
                passwordVerifierBase64: passwordVerifierBase64,
                passwordIterations: passwordIterations,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String?> credentialReference = const Value.absent(),
                Value<String?> passwordSaltBase64 = const Value.absent(),
                Value<String?> passwordVerifierBase64 = const Value.absent(),
                Value<int?> passwordIterations = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JournalsCompanion.insert(
                id: id,
                title: title,
                description: description,
                isLocked: isLocked,
                credentialReference: credentialReference,
                passwordSaltBase64: passwordSaltBase64,
                passwordVerifierBase64: passwordVerifierBase64,
                passwordIterations: passwordIterations,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({entriesRefs = false, journalTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entriesRefs) db.entries,
                    if (journalTagsRefs) db.journalTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entriesRefs)
                        await $_getPrefetchedData<
                          Journal,
                          $JournalsTable,
                          Entry
                        >(
                          currentTable: table,
                          referencedTable: $$JournalsTableReferences
                              ._entriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.journalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (journalTagsRefs)
                        await $_getPrefetchedData<
                          Journal,
                          $JournalsTable,
                          JournalTag
                        >(
                          currentTable: table,
                          referencedTable: $$JournalsTableReferences
                              ._journalTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JournalsTableReferences(
                                db,
                                table,
                                p0,
                              ).journalTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.journalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JournalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalsTable,
      Journal,
      $$JournalsTableFilterComposer,
      $$JournalsTableOrderingComposer,
      $$JournalsTableAnnotationComposer,
      $$JournalsTableCreateCompanionBuilder,
      $$JournalsTableUpdateCompanionBuilder,
      (Journal, $$JournalsTableReferences),
      Journal,
      PrefetchHooks Function({bool entriesRefs, bool journalTagsRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required int journalId,
      Value<String?> title,
      Value<String?> contentJson,
      Value<String?> plainText,
      Value<DateTime?> entryDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<int> journalId,
      Value<String?> title,
      Value<String?> contentJson,
      Value<String?> plainText,
      Value<DateTime?> entryDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalsTable _journalIdTable(_$AppDatabase db) => db.journals
      .createAlias($_aliasNameGenerator(db.entries.journalId, db.journals.id));

  $$JournalsTableProcessedTableManager get journalId {
    final $_column = $_itemColumn<int>('journal_id')!;

    final manager = $$JournalsTableTableManager(
      $_db,
      $_db.journals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntryTagsTable, List<EntryTag>>
  _entryTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryTags,
    aliasName: $_aliasNameGenerator(db.entries.id, db.entryTags.entryId),
  );

  $$EntryTagsTableProcessedTableManager get entryTagsRefs {
    final manager = $$EntryTagsTableTableManager(
      $_db,
      $_db.entryTags,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: $_aliasNameGenerator(db.entries.id, db.attachments.entryId),
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BacklinksTable, List<Backlink>>
  _backlinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.backlinks,
    aliasName: $_aliasNameGenerator(db.entries.id, db.backlinks.sourceEntryId),
  );

  $$BacklinksTableProcessedTableManager get backlinksRefs {
    final manager = $$BacklinksTableTableManager(
      $_db,
      $_db.backlinks,
    ).filter((f) => f.sourceEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_backlinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryRevisionsTable, List<EntryRevision>>
  _entryRevisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryRevisions,
    aliasName: $_aliasNameGenerator(db.entries.id, db.entryRevisions.entryId),
  );

  $$EntryRevisionsTableProcessedTableManager get entryRevisionsRefs {
    final manager = $$EntryRevisionsTableTableManager(
      $_db,
      $_db.entryRevisions,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryRevisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VoiceNotesTable, List<VoiceNote>>
  _voiceNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.voiceNotes,
    aliasName: $_aliasNameGenerator(db.entries.id, db.voiceNotes.entryId),
  );

  $$VoiceNotesTableProcessedTableManager get voiceNotesRefs {
    final manager = $$VoiceNotesTableTableManager(
      $_db,
      $_db.voiceNotes,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_voiceNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryMoodsTable, List<EntryMood>>
  _entryMoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryMoods,
    aliasName: $_aliasNameGenerator(db.entries.id, db.entryMoods.entryId),
  );

  $$EntryMoodsTableProcessedTableManager get entryMoodsRefs {
    final manager = $$EntryMoodsTableTableManager(
      $_db,
      $_db.entryMoods,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryMoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalsTableFilterComposer get journalId {
    final $$JournalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableFilterComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entryTagsRefs(
    Expression<bool> Function($$EntryTagsTableFilterComposer f) f,
  ) {
    final $$EntryTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableFilterComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> backlinksRefs(
    Expression<bool> Function($$BacklinksTableFilterComposer f) f,
  ) {
    final $$BacklinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backlinks,
      getReferencedColumn: (t) => t.sourceEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacklinksTableFilterComposer(
            $db: $db,
            $table: $db.backlinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryRevisionsRefs(
    Expression<bool> Function($$EntryRevisionsTableFilterComposer f) f,
  ) {
    final $$EntryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryRevisions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.entryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> voiceNotesRefs(
    Expression<bool> Function($$VoiceNotesTableFilterComposer f) f,
  ) {
    final $$VoiceNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voiceNotes,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoiceNotesTableFilterComposer(
            $db: $db,
            $table: $db.voiceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryMoodsRefs(
    Expression<bool> Function($$EntryMoodsTableFilterComposer f) f,
  ) {
    final $$EntryMoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryMoods,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryMoodsTableFilterComposer(
            $db: $db,
            $table: $db.entryMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalsTableOrderingComposer get journalId {
    final $$JournalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableOrderingComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$JournalsTableAnnotationComposer get journalId {
    final $$JournalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableAnnotationComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entryTagsRefs<T extends Object>(
    Expression<T> Function($$EntryTagsTableAnnotationComposer a) f,
  ) {
    final $$EntryTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> backlinksRefs<T extends Object>(
    Expression<T> Function($$BacklinksTableAnnotationComposer a) f,
  ) {
    final $$BacklinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backlinks,
      getReferencedColumn: (t) => t.sourceEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BacklinksTableAnnotationComposer(
            $db: $db,
            $table: $db.backlinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entryRevisionsRefs<T extends Object>(
    Expression<T> Function($$EntryRevisionsTableAnnotationComposer a) f,
  ) {
    final $$EntryRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryRevisions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> voiceNotesRefs<T extends Object>(
    Expression<T> Function($$VoiceNotesTableAnnotationComposer a) f,
  ) {
    final $$VoiceNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.voiceNotes,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VoiceNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.voiceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entryMoodsRefs<T extends Object>(
    Expression<T> Function($$EntryMoodsTableAnnotationComposer a) f,
  ) {
    final $$EntryMoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryMoods,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryMoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({
            bool journalId,
            bool entryTagsRefs,
            bool attachmentsRefs,
            bool backlinksRefs,
            bool entryRevisionsRefs,
            bool voiceNotesRefs,
            bool entryMoodsRefs,
          })
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> journalId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                Value<DateTime?> entryDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                journalId: journalId,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                entryDate: entryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int journalId,
                Value<String?> title = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                Value<DateTime?> entryDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                journalId: journalId,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                entryDate: entryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                journalId = false,
                entryTagsRefs = false,
                attachmentsRefs = false,
                backlinksRefs = false,
                entryRevisionsRefs = false,
                voiceNotesRefs = false,
                entryMoodsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryTagsRefs) db.entryTags,
                    if (attachmentsRefs) db.attachments,
                    if (backlinksRefs) db.backlinks,
                    if (entryRevisionsRefs) db.entryRevisions,
                    if (voiceNotesRefs) db.voiceNotes,
                    if (entryMoodsRefs) db.entryMoods,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (journalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.journalId,
                                    referencedTable: $$EntriesTableReferences
                                        ._journalIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._journalIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryTagsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          EntryTag
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._entryTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (backlinksRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          Backlink
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._backlinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).backlinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryRevisionsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          EntryRevision
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._entryRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (voiceNotesRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          VoiceNote
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._voiceNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).voiceNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryMoodsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          EntryMood
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._entryMoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryMoodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({
        bool journalId,
        bool entryTagsRefs,
        bool attachmentsRefs,
        bool backlinksRefs,
        bool entryRevisionsRefs,
        bool voiceNotesRefs,
        bool entryMoodsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JournalTagsTable, List<JournalTag>>
  _journalTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.journalTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.journalTags.tagId),
  );

  $$JournalTagsTableProcessedTableManager get journalTagsRefs {
    final manager = $$JournalTagsTableTableManager(
      $_db,
      $_db.journalTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryTagsTable, List<EntryTag>>
  _entryTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.entryTags.tagId),
  );

  $$EntryTagsTableProcessedTableManager get entryTagsRefs {
    final manager = $$EntryTagsTableTableManager(
      $_db,
      $_db.entryTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> journalTagsRefs(
    Expression<bool> Function($$JournalTagsTableFilterComposer f) f,
  ) {
    final $$JournalTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalTagsTableFilterComposer(
            $db: $db,
            $table: $db.journalTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryTagsRefs(
    Expression<bool> Function($$EntryTagsTableFilterComposer f) f,
  ) {
    final $$EntryTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableFilterComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> journalTagsRefs<T extends Object>(
    Expression<T> Function($$JournalTagsTableAnnotationComposer a) f,
  ) {
    final $$JournalTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.journalTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entryTagsRefs<T extends Object>(
    Expression<T> Function($$EntryTagsTableAnnotationComposer a) f,
  ) {
    final $$EntryTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool journalTagsRefs, bool entryTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({journalTagsRefs = false, entryTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (journalTagsRefs) db.journalTags,
                    if (entryTagsRefs) db.entryTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (journalTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, JournalTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._journalTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).journalTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, EntryTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._entryTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).entryTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool journalTagsRefs, bool entryTagsRefs})
    >;
typedef $$JournalTagsTableCreateCompanionBuilder =
    JournalTagsCompanion Function({
      Value<int> id,
      required int journalId,
      required int tagId,
    });
typedef $$JournalTagsTableUpdateCompanionBuilder =
    JournalTagsCompanion Function({
      Value<int> id,
      Value<int> journalId,
      Value<int> tagId,
    });

final class $$JournalTagsTableReferences
    extends BaseReferences<_$AppDatabase, $JournalTagsTable, JournalTag> {
  $$JournalTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JournalsTable _journalIdTable(_$AppDatabase db) =>
      db.journals.createAlias(
        $_aliasNameGenerator(db.journalTags.journalId, db.journals.id),
      );

  $$JournalsTableProcessedTableManager get journalId {
    final $_column = $_itemColumn<int>('journal_id')!;

    final manager = $$JournalsTableTableManager(
      $_db,
      $_db.journals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.journalTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JournalTagsTableFilterComposer
    extends Composer<_$AppDatabase, $JournalTagsTable> {
  $$JournalTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalsTableFilterComposer get journalId {
    final $$JournalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableFilterComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalTagsTable> {
  $$JournalTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalsTableOrderingComposer get journalId {
    final $$JournalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableOrderingComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalTagsTable> {
  $$JournalTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$JournalsTableAnnotationComposer get journalId {
    final $$JournalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journalId,
      referencedTable: $db.journals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalsTableAnnotationComposer(
            $db: $db,
            $table: $db.journals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalTagsTable,
          JournalTag,
          $$JournalTagsTableFilterComposer,
          $$JournalTagsTableOrderingComposer,
          $$JournalTagsTableAnnotationComposer,
          $$JournalTagsTableCreateCompanionBuilder,
          $$JournalTagsTableUpdateCompanionBuilder,
          (JournalTag, $$JournalTagsTableReferences),
          JournalTag,
          PrefetchHooks Function({bool journalId, bool tagId})
        > {
  $$JournalTagsTableTableManager(_$AppDatabase db, $JournalTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> journalId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
              }) => JournalTagsCompanion(
                id: id,
                journalId: journalId,
                tagId: tagId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int journalId,
                required int tagId,
              }) => JournalTagsCompanion.insert(
                id: id,
                journalId: journalId,
                tagId: tagId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({journalId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (journalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.journalId,
                                referencedTable: $$JournalTagsTableReferences
                                    ._journalIdTable(db),
                                referencedColumn: $$JournalTagsTableReferences
                                    ._journalIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$JournalTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$JournalTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JournalTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalTagsTable,
      JournalTag,
      $$JournalTagsTableFilterComposer,
      $$JournalTagsTableOrderingComposer,
      $$JournalTagsTableAnnotationComposer,
      $$JournalTagsTableCreateCompanionBuilder,
      $$JournalTagsTableUpdateCompanionBuilder,
      (JournalTag, $$JournalTagsTableReferences),
      JournalTag,
      PrefetchHooks Function({bool journalId, bool tagId})
    >;
typedef $$EntryTagsTableCreateCompanionBuilder =
    EntryTagsCompanion Function({
      Value<int> id,
      required int entryId,
      required int tagId,
    });
typedef $$EntryTagsTableUpdateCompanionBuilder =
    EntryTagsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<int> tagId,
    });

final class $$EntryTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryTagsTable, EntryTag> {
  $$EntryTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) => db.entries
      .createAlias($_aliasNameGenerator(db.entryTags.entryId, db.entries.id));

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.entryTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryTagsTable,
          EntryTag,
          $$EntryTagsTableFilterComposer,
          $$EntryTagsTableOrderingComposer,
          $$EntryTagsTableAnnotationComposer,
          $$EntryTagsTableCreateCompanionBuilder,
          $$EntryTagsTableUpdateCompanionBuilder,
          (EntryTag, $$EntryTagsTableReferences),
          EntryTag,
          PrefetchHooks Function({bool entryId, bool tagId})
        > {
  $$EntryTagsTableTableManager(_$AppDatabase db, $EntryTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
              }) => EntryTagsCompanion(id: id, entryId: entryId, tagId: tagId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required int tagId,
              }) => EntryTagsCompanion.insert(
                id: id,
                entryId: entryId,
                tagId: tagId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryTagsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntryTagsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EntryTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EntryTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryTagsTable,
      EntryTag,
      $$EntryTagsTableFilterComposer,
      $$EntryTagsTableOrderingComposer,
      $$EntryTagsTableAnnotationComposer,
      $$EntryTagsTableCreateCompanionBuilder,
      $$EntryTagsTableUpdateCompanionBuilder,
      (EntryTag, $$EntryTagsTableReferences),
      EntryTag,
      PrefetchHooks Function({bool entryId, bool tagId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      required int entryId,
      required String fileName,
      Value<String?> mimeType,
      required String encryptedPath,
      required String nonceBase64,
      required String keyReference,
      required int sizeBytes,
      Value<DateTime> createdAt,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> fileName,
      Value<String?> mimeType,
      Value<String> encryptedPath,
      Value<String> nonceBase64,
      Value<String> keyReference,
      Value<int> sizeBytes,
      Value<DateTime> createdAt,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) => db.entries
      .createAlias($_aliasNameGenerator(db.attachments.entryId, db.entries.id));

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentTextsTable, List<AttachmentText>>
  _attachmentTextsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachmentTexts,
    aliasName: $_aliasNameGenerator(
      db.attachments.id,
      db.attachmentTexts.attachmentId,
    ),
  );

  $$AttachmentTextsTableProcessedTableManager get attachmentTextsRefs {
    final manager = $$AttachmentTextsTableTableManager(
      $_db,
      $_db.attachmentTexts,
    ).filter((f) => f.attachmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attachmentTextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentLocksTable, List<AttachmentLock>>
  _attachmentLocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachmentLocks,
    aliasName: $_aliasNameGenerator(
      db.attachments.id,
      db.attachmentLocks.attachmentId,
    ),
  );

  $$AttachmentLocksTableProcessedTableManager get attachmentLocksRefs {
    final manager = $$AttachmentLocksTableTableManager(
      $_db,
      $_db.attachmentLocks,
    ).filter((f) => f.attachmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attachmentLocksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentTextsRefs(
    Expression<bool> Function($$AttachmentTextsTableFilterComposer f) f,
  ) {
    final $$AttachmentTextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachmentTexts,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentTextsTableFilterComposer(
            $db: $db,
            $table: $db.attachmentTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentLocksRefs(
    Expression<bool> Function($$AttachmentLocksTableFilterComposer f) f,
  ) {
    final $$AttachmentLocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachmentLocks,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentLocksTableFilterComposer(
            $db: $db,
            $table: $db.attachmentLocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentTextsRefs<T extends Object>(
    Expression<T> Function($$AttachmentTextsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentTextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachmentTexts,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentTextsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachmentTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentLocksRefs<T extends Object>(
    Expression<T> Function($$AttachmentLocksTableAnnotationComposer a) f,
  ) {
    final $$AttachmentLocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachmentLocks,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentLocksTableAnnotationComposer(
            $db: $db,
            $table: $db.attachmentLocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({
            bool entryId,
            bool attachmentTextsRefs,
            bool attachmentLocksRefs,
          })
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String> encryptedPath = const Value.absent(),
                Value<String> nonceBase64 = const Value.absent(),
                Value<String> keyReference = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                entryId: entryId,
                fileName: fileName,
                mimeType: mimeType,
                encryptedPath: encryptedPath,
                nonceBase64: nonceBase64,
                keyReference: keyReference,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String fileName,
                Value<String?> mimeType = const Value.absent(),
                required String encryptedPath,
                required String nonceBase64,
                required String keyReference,
                required int sizeBytes,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                entryId: entryId,
                fileName: fileName,
                mimeType: mimeType,
                encryptedPath: encryptedPath,
                nonceBase64: nonceBase64,
                keyReference: keyReference,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                entryId = false,
                attachmentTextsRefs = false,
                attachmentLocksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentTextsRefs) db.attachmentTexts,
                    if (attachmentLocksRefs) db.attachmentLocks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (entryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.entryId,
                                    referencedTable:
                                        $$AttachmentsTableReferences
                                            ._entryIdTable(db),
                                    referencedColumn:
                                        $$AttachmentsTableReferences
                                            ._entryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentTextsRefs)
                        await $_getPrefetchedData<
                          Attachment,
                          $AttachmentsTable,
                          AttachmentText
                        >(
                          currentTable: table,
                          referencedTable: $$AttachmentsTableReferences
                              ._attachmentTextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttachmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentTextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attachmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentLocksRefs)
                        await $_getPrefetchedData<
                          Attachment,
                          $AttachmentsTable,
                          AttachmentLock
                        >(
                          currentTable: table,
                          referencedTable: $$AttachmentsTableReferences
                              ._attachmentLocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttachmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentLocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attachmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({
        bool entryId,
        bool attachmentTextsRefs,
        bool attachmentLocksRefs,
      })
    >;
typedef $$AttachmentTextsTableCreateCompanionBuilder =
    AttachmentTextsCompanion Function({
      Value<int> id,
      required int attachmentId,
      required String extractedText,
      Value<DateTime> createdAt,
    });
typedef $$AttachmentTextsTableUpdateCompanionBuilder =
    AttachmentTextsCompanion Function({
      Value<int> id,
      Value<int> attachmentId,
      Value<String> extractedText,
      Value<DateTime> createdAt,
    });

final class $$AttachmentTextsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttachmentTextsTable, AttachmentText> {
  $$AttachmentTextsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) =>
      db.attachments.createAlias(
        $_aliasNameGenerator(
          db.attachmentTexts.attachmentId,
          db.attachments.id,
        ),
      );

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<int>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentTextsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentTextsTable> {
  $$AttachmentTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentTextsTable> {
  $$AttachmentTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableOrderingComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentTextsTable> {
  $$AttachmentTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentTextsTable,
          AttachmentText,
          $$AttachmentTextsTableFilterComposer,
          $$AttachmentTextsTableOrderingComposer,
          $$AttachmentTextsTableAnnotationComposer,
          $$AttachmentTextsTableCreateCompanionBuilder,
          $$AttachmentTextsTableUpdateCompanionBuilder,
          (AttachmentText, $$AttachmentTextsTableReferences),
          AttachmentText,
          PrefetchHooks Function({bool attachmentId})
        > {
  $$AttachmentTextsTableTableManager(
    _$AppDatabase db,
    $AttachmentTextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attachmentId = const Value.absent(),
                Value<String> extractedText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttachmentTextsCompanion(
                id: id,
                attachmentId: attachmentId,
                extractedText: extractedText,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attachmentId,
                required String extractedText,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttachmentTextsCompanion.insert(
                id: id,
                attachmentId: attachmentId,
                extractedText: extractedText,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentTextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attachmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attachmentId,
                                referencedTable:
                                    $$AttachmentTextsTableReferences
                                        ._attachmentIdTable(db),
                                referencedColumn:
                                    $$AttachmentTextsTableReferences
                                        ._attachmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentTextsTable,
      AttachmentText,
      $$AttachmentTextsTableFilterComposer,
      $$AttachmentTextsTableOrderingComposer,
      $$AttachmentTextsTableAnnotationComposer,
      $$AttachmentTextsTableCreateCompanionBuilder,
      $$AttachmentTextsTableUpdateCompanionBuilder,
      (AttachmentText, $$AttachmentTextsTableReferences),
      AttachmentText,
      PrefetchHooks Function({bool attachmentId})
    >;
typedef $$BacklinksTableCreateCompanionBuilder =
    BacklinksCompanion Function({
      Value<int> id,
      required int sourceEntryId,
      required String targetType,
      required int targetId,
    });
typedef $$BacklinksTableUpdateCompanionBuilder =
    BacklinksCompanion Function({
      Value<int> id,
      Value<int> sourceEntryId,
      Value<String> targetType,
      Value<int> targetId,
    });

final class $$BacklinksTableReferences
    extends BaseReferences<_$AppDatabase, $BacklinksTable, Backlink> {
  $$BacklinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _sourceEntryIdTable(_$AppDatabase db) =>
      db.entries.createAlias(
        $_aliasNameGenerator(db.backlinks.sourceEntryId, db.entries.id),
      );

  $$EntriesTableProcessedTableManager get sourceEntryId {
    final $_column = $_itemColumn<int>('source_entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BacklinksTableFilterComposer
    extends Composer<_$AppDatabase, $BacklinksTable> {
  $$BacklinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get sourceEntryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacklinksTableOrderingComposer
    extends Composer<_$AppDatabase, $BacklinksTable> {
  $$BacklinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get sourceEntryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacklinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BacklinksTable> {
  $$BacklinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  $$EntriesTableAnnotationComposer get sourceEntryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BacklinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BacklinksTable,
          Backlink,
          $$BacklinksTableFilterComposer,
          $$BacklinksTableOrderingComposer,
          $$BacklinksTableAnnotationComposer,
          $$BacklinksTableCreateCompanionBuilder,
          $$BacklinksTableUpdateCompanionBuilder,
          (Backlink, $$BacklinksTableReferences),
          Backlink,
          PrefetchHooks Function({bool sourceEntryId})
        > {
  $$BacklinksTableTableManager(_$AppDatabase db, $BacklinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BacklinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BacklinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BacklinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceEntryId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int> targetId = const Value.absent(),
              }) => BacklinksCompanion(
                id: id,
                sourceEntryId: sourceEntryId,
                targetType: targetType,
                targetId: targetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceEntryId,
                required String targetType,
                required int targetId,
              }) => BacklinksCompanion.insert(
                id: id,
                sourceEntryId: sourceEntryId,
                targetType: targetType,
                targetId: targetId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BacklinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceEntryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceEntryId,
                                referencedTable: $$BacklinksTableReferences
                                    ._sourceEntryIdTable(db),
                                referencedColumn: $$BacklinksTableReferences
                                    ._sourceEntryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BacklinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BacklinksTable,
      Backlink,
      $$BacklinksTableFilterComposer,
      $$BacklinksTableOrderingComposer,
      $$BacklinksTableAnnotationComposer,
      $$BacklinksTableCreateCompanionBuilder,
      $$BacklinksTableUpdateCompanionBuilder,
      (Backlink, $$BacklinksTableReferences),
      Backlink,
      PrefetchHooks Function({bool sourceEntryId})
    >;
typedef $$SearchPresetsTableCreateCompanionBuilder =
    SearchPresetsCompanion Function({
      Value<int> id,
      required String name,
      required String query,
      Value<String?> resultType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SearchPresetsTableUpdateCompanionBuilder =
    SearchPresetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> query,
      Value<String?> resultType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$SearchPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $SearchPresetsTable> {
  $$SearchPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultType => $composableBuilder(
    column: $table.resultType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchPresetsTable> {
  $$SearchPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultType => $composableBuilder(
    column: $table.resultType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchPresetsTable> {
  $$SearchPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get resultType => $composableBuilder(
    column: $table.resultType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SearchPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchPresetsTable,
          SearchPreset,
          $$SearchPresetsTableFilterComposer,
          $$SearchPresetsTableOrderingComposer,
          $$SearchPresetsTableAnnotationComposer,
          $$SearchPresetsTableCreateCompanionBuilder,
          $$SearchPresetsTableUpdateCompanionBuilder,
          (
            SearchPreset,
            BaseReferences<_$AppDatabase, $SearchPresetsTable, SearchPreset>,
          ),
          SearchPreset,
          PrefetchHooks Function()
        > {
  $$SearchPresetsTableTableManager(_$AppDatabase db, $SearchPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String?> resultType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SearchPresetsCompanion(
                id: id,
                name: name,
                query: query,
                resultType: resultType,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String query,
                Value<String?> resultType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SearchPresetsCompanion.insert(
                id: id,
                name: name,
                query: query,
                resultType: resultType,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchPresetsTable,
      SearchPreset,
      $$SearchPresetsTableFilterComposer,
      $$SearchPresetsTableOrderingComposer,
      $$SearchPresetsTableAnnotationComposer,
      $$SearchPresetsTableCreateCompanionBuilder,
      $$SearchPresetsTableUpdateCompanionBuilder,
      (
        SearchPreset,
        BaseReferences<_$AppDatabase, $SearchPresetsTable, SearchPreset>,
      ),
      SearchPreset,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> attachmentStorageLocation,
      Value<String?> attachmentStorageTreeUri,
      Value<String?> attachmentStorageTreeLabel,
      Value<String> attachmentMigrationStatus,
      Value<String?> attachmentMigrationTarget,
      Value<String?> attachmentMigrationFailure,
      Value<int> attachmentMigrationProcessedCount,
      Value<int> attachmentMigrationTotalCount,
      Value<DateTime> updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> attachmentStorageLocation,
      Value<String?> attachmentStorageTreeUri,
      Value<String?> attachmentStorageTreeLabel,
      Value<String> attachmentMigrationStatus,
      Value<String?> attachmentMigrationTarget,
      Value<String?> attachmentMigrationFailure,
      Value<int> attachmentMigrationProcessedCount,
      Value<int> attachmentMigrationTotalCount,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentStorageLocation => $composableBuilder(
    column: $table.attachmentStorageLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentStorageTreeUri => $composableBuilder(
    column: $table.attachmentStorageTreeUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentStorageTreeLabel => $composableBuilder(
    column: $table.attachmentStorageTreeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentMigrationStatus => $composableBuilder(
    column: $table.attachmentMigrationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentMigrationTarget => $composableBuilder(
    column: $table.attachmentMigrationTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentMigrationFailure => $composableBuilder(
    column: $table.attachmentMigrationFailure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attachmentMigrationProcessedCount =>
      $composableBuilder(
        column: $table.attachmentMigrationProcessedCount,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get attachmentMigrationTotalCount => $composableBuilder(
    column: $table.attachmentMigrationTotalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentStorageLocation => $composableBuilder(
    column: $table.attachmentStorageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentStorageTreeUri => $composableBuilder(
    column: $table.attachmentStorageTreeUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentStorageTreeLabel => $composableBuilder(
    column: $table.attachmentStorageTreeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentMigrationStatus => $composableBuilder(
    column: $table.attachmentMigrationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentMigrationTarget => $composableBuilder(
    column: $table.attachmentMigrationTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentMigrationFailure => $composableBuilder(
    column: $table.attachmentMigrationFailure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attachmentMigrationProcessedCount =>
      $composableBuilder(
        column: $table.attachmentMigrationProcessedCount,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get attachmentMigrationTotalCount => $composableBuilder(
    column: $table.attachmentMigrationTotalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attachmentStorageLocation => $composableBuilder(
    column: $table.attachmentStorageLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentStorageTreeUri => $composableBuilder(
    column: $table.attachmentStorageTreeUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentStorageTreeLabel => $composableBuilder(
    column: $table.attachmentStorageTreeLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentMigrationStatus => $composableBuilder(
    column: $table.attachmentMigrationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentMigrationTarget => $composableBuilder(
    column: $table.attachmentMigrationTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentMigrationFailure => $composableBuilder(
    column: $table.attachmentMigrationFailure,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attachmentMigrationProcessedCount =>
      $composableBuilder(
        column: $table.attachmentMigrationProcessedCount,
        builder: (column) => column,
      );

  GeneratedColumn<int> get attachmentMigrationTotalCount => $composableBuilder(
    column: $table.attachmentMigrationTotalCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> attachmentStorageLocation = const Value.absent(),
                Value<String?> attachmentStorageTreeUri = const Value.absent(),
                Value<String?> attachmentStorageTreeLabel =
                    const Value.absent(),
                Value<String> attachmentMigrationStatus = const Value.absent(),
                Value<String?> attachmentMigrationTarget = const Value.absent(),
                Value<String?> attachmentMigrationFailure =
                    const Value.absent(),
                Value<int> attachmentMigrationProcessedCount =
                    const Value.absent(),
                Value<int> attachmentMigrationTotalCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                attachmentStorageLocation: attachmentStorageLocation,
                attachmentStorageTreeUri: attachmentStorageTreeUri,
                attachmentStorageTreeLabel: attachmentStorageTreeLabel,
                attachmentMigrationStatus: attachmentMigrationStatus,
                attachmentMigrationTarget: attachmentMigrationTarget,
                attachmentMigrationFailure: attachmentMigrationFailure,
                attachmentMigrationProcessedCount:
                    attachmentMigrationProcessedCount,
                attachmentMigrationTotalCount: attachmentMigrationTotalCount,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> attachmentStorageLocation = const Value.absent(),
                Value<String?> attachmentStorageTreeUri = const Value.absent(),
                Value<String?> attachmentStorageTreeLabel =
                    const Value.absent(),
                Value<String> attachmentMigrationStatus = const Value.absent(),
                Value<String?> attachmentMigrationTarget = const Value.absent(),
                Value<String?> attachmentMigrationFailure =
                    const Value.absent(),
                Value<int> attachmentMigrationProcessedCount =
                    const Value.absent(),
                Value<int> attachmentMigrationTotalCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                attachmentStorageLocation: attachmentStorageLocation,
                attachmentStorageTreeUri: attachmentStorageTreeUri,
                attachmentStorageTreeLabel: attachmentStorageTreeLabel,
                attachmentMigrationStatus: attachmentMigrationStatus,
                attachmentMigrationTarget: attachmentMigrationTarget,
                attachmentMigrationFailure: attachmentMigrationFailure,
                attachmentMigrationProcessedCount:
                    attachmentMigrationProcessedCount,
                attachmentMigrationTotalCount: attachmentMigrationTotalCount,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$AppSecurityTableCreateCompanionBuilder =
    AppSecurityCompanion Function({
      Value<int> id,
      Value<String?> lockMode,
      Value<bool> isLocked,
    });
typedef $$AppSecurityTableUpdateCompanionBuilder =
    AppSecurityCompanion Function({
      Value<int> id,
      Value<String?> lockMode,
      Value<bool> isLocked,
    });

class $$AppSecurityTableFilterComposer
    extends Composer<_$AppDatabase, $AppSecurityTable> {
  $$AppSecurityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lockMode => $composableBuilder(
    column: $table.lockMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSecurityTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSecurityTable> {
  $$AppSecurityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lockMode => $composableBuilder(
    column: $table.lockMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSecurityTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSecurityTable> {
  $$AppSecurityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lockMode =>
      $composableBuilder(column: $table.lockMode, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);
}

class $$AppSecurityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSecurityTable,
          AppSecurityData,
          $$AppSecurityTableFilterComposer,
          $$AppSecurityTableOrderingComposer,
          $$AppSecurityTableAnnotationComposer,
          $$AppSecurityTableCreateCompanionBuilder,
          $$AppSecurityTableUpdateCompanionBuilder,
          (
            AppSecurityData,
            BaseReferences<_$AppDatabase, $AppSecurityTable, AppSecurityData>,
          ),
          AppSecurityData,
          PrefetchHooks Function()
        > {
  $$AppSecurityTableTableManager(_$AppDatabase db, $AppSecurityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSecurityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSecurityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSecurityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> lockMode = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => AppSecurityCompanion(
                id: id,
                lockMode: lockMode,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> lockMode = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => AppSecurityCompanion.insert(
                id: id,
                lockMode: lockMode,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSecurityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSecurityTable,
      AppSecurityData,
      $$AppSecurityTableFilterComposer,
      $$AppSecurityTableOrderingComposer,
      $$AppSecurityTableAnnotationComposer,
      $$AppSecurityTableCreateCompanionBuilder,
      $$AppSecurityTableUpdateCompanionBuilder,
      (
        AppSecurityData,
        BaseReferences<_$AppDatabase, $AppSecurityTable, AppSecurityData>,
      ),
      AppSecurityData,
      PrefetchHooks Function()
    >;
typedef $$EntryRevisionsTableCreateCompanionBuilder =
    EntryRevisionsCompanion Function({
      Value<int> id,
      required int entryId,
      Value<String?> title,
      Value<String?> contentJson,
      Value<String?> plainText,
      Value<DateTime> createdAt,
    });
typedef $$EntryRevisionsTableUpdateCompanionBuilder =
    EntryRevisionsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String?> title,
      Value<String?> contentJson,
      Value<String?> plainText,
      Value<DateTime> createdAt,
    });

final class $$EntryRevisionsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryRevisionsTable, EntryRevision> {
  $$EntryRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntriesTable _entryIdTable(_$AppDatabase db) =>
      db.entries.createAlias(
        $_aliasNameGenerator(db.entryRevisions.entryId, db.entries.id),
      );

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryRevisionsTable> {
  $$EntryRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryRevisionsTable> {
  $$EntryRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryRevisionsTable> {
  $$EntryRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryRevisionsTable,
          EntryRevision,
          $$EntryRevisionsTableFilterComposer,
          $$EntryRevisionsTableOrderingComposer,
          $$EntryRevisionsTableAnnotationComposer,
          $$EntryRevisionsTableCreateCompanionBuilder,
          $$EntryRevisionsTableUpdateCompanionBuilder,
          (EntryRevision, $$EntryRevisionsTableReferences),
          EntryRevision,
          PrefetchHooks Function({bool entryId})
        > {
  $$EntryRevisionsTableTableManager(
    _$AppDatabase db,
    $EntryRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntryRevisionsCompanion(
                id: id,
                entryId: entryId,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                Value<String?> title = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EntryRevisionsCompanion.insert(
                id: id,
                entryId: entryId,
                title: title,
                contentJson: contentJson,
                plainText: plainText,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryRevisionsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn:
                                    $$EntryRevisionsTableReferences
                                        ._entryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryRevisionsTable,
      EntryRevision,
      $$EntryRevisionsTableFilterComposer,
      $$EntryRevisionsTableOrderingComposer,
      $$EntryRevisionsTableAnnotationComposer,
      $$EntryRevisionsTableCreateCompanionBuilder,
      $$EntryRevisionsTableUpdateCompanionBuilder,
      (EntryRevision, $$EntryRevisionsTableReferences),
      EntryRevision,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$VoiceNotesTableCreateCompanionBuilder =
    VoiceNotesCompanion Function({
      Value<int> id,
      required int entryId,
      required String fileName,
      required String encryptedPath,
      required String nonceBase64,
      required String keyReference,
      required int durationMs,
      Value<String?> transcript,
      Value<DateTime> createdAt,
    });
typedef $$VoiceNotesTableUpdateCompanionBuilder =
    VoiceNotesCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> fileName,
      Value<String> encryptedPath,
      Value<String> nonceBase64,
      Value<String> keyReference,
      Value<int> durationMs,
      Value<String?> transcript,
      Value<DateTime> createdAt,
    });

final class $$VoiceNotesTableReferences
    extends BaseReferences<_$AppDatabase, $VoiceNotesTable, VoiceNote> {
  $$VoiceNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) => db.entries
      .createAlias($_aliasNameGenerator(db.voiceNotes.entryId, db.entries.id));

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VoiceNotesTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nonceBase64 => $composableBuilder(
    column: $table.nonceBase64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyReference => $composableBuilder(
    column: $table.keyReference,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VoiceNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceNotesTable,
          VoiceNote,
          $$VoiceNotesTableFilterComposer,
          $$VoiceNotesTableOrderingComposer,
          $$VoiceNotesTableAnnotationComposer,
          $$VoiceNotesTableCreateCompanionBuilder,
          $$VoiceNotesTableUpdateCompanionBuilder,
          (VoiceNote, $$VoiceNotesTableReferences),
          VoiceNote,
          PrefetchHooks Function({bool entryId})
        > {
  $$VoiceNotesTableTableManager(_$AppDatabase db, $VoiceNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> encryptedPath = const Value.absent(),
                Value<String> nonceBase64 = const Value.absent(),
                Value<String> keyReference = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VoiceNotesCompanion(
                id: id,
                entryId: entryId,
                fileName: fileName,
                encryptedPath: encryptedPath,
                nonceBase64: nonceBase64,
                keyReference: keyReference,
                durationMs: durationMs,
                transcript: transcript,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String fileName,
                required String encryptedPath,
                required String nonceBase64,
                required String keyReference,
                required int durationMs,
                Value<String?> transcript = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VoiceNotesCompanion.insert(
                id: id,
                entryId: entryId,
                fileName: fileName,
                encryptedPath: encryptedPath,
                nonceBase64: nonceBase64,
                keyReference: keyReference,
                durationMs: durationMs,
                transcript: transcript,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VoiceNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$VoiceNotesTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$VoiceNotesTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VoiceNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceNotesTable,
      VoiceNote,
      $$VoiceNotesTableFilterComposer,
      $$VoiceNotesTableOrderingComposer,
      $$VoiceNotesTableAnnotationComposer,
      $$VoiceNotesTableCreateCompanionBuilder,
      $$VoiceNotesTableUpdateCompanionBuilder,
      (VoiceNote, $$VoiceNotesTableReferences),
      VoiceNote,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$BackupLogsTableCreateCompanionBuilder =
    BackupLogsCompanion Function({
      Value<int> id,
      required String status,
      Value<String?> backupPath,
      Value<int?> sizeBytes,
      Value<int> entryCount,
      Value<int> attachmentCount,
      Value<String?> errorMessage,
      Value<String> trigger,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });
typedef $$BackupLogsTableUpdateCompanionBuilder =
    BackupLogsCompanion Function({
      Value<int> id,
      Value<String> status,
      Value<String?> backupPath,
      Value<int?> sizeBytes,
      Value<int> entryCount,
      Value<int> attachmentCount,
      Value<String?> errorMessage,
      Value<String> trigger,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });

class $$BackupLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attachmentCount => $composableBuilder(
    column: $table.attachmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attachmentCount => $composableBuilder(
    column: $table.attachmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attachmentCount => $composableBuilder(
    column: $table.attachmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$BackupLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupLogsTable,
          BackupLog,
          $$BackupLogsTableFilterComposer,
          $$BackupLogsTableOrderingComposer,
          $$BackupLogsTableAnnotationComposer,
          $$BackupLogsTableCreateCompanionBuilder,
          $$BackupLogsTableUpdateCompanionBuilder,
          (
            BackupLog,
            BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>,
          ),
          BackupLog,
          PrefetchHooks Function()
        > {
  $$BackupLogsTableTableManager(_$AppDatabase db, $BackupLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> backupPath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<int> attachmentCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => BackupLogsCompanion(
                id: id,
                status: status,
                backupPath: backupPath,
                sizeBytes: sizeBytes,
                entryCount: entryCount,
                attachmentCount: attachmentCount,
                errorMessage: errorMessage,
                trigger: trigger,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String status,
                Value<String?> backupPath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<int> attachmentCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => BackupLogsCompanion.insert(
                id: id,
                status: status,
                backupPath: backupPath,
                sizeBytes: sizeBytes,
                entryCount: entryCount,
                attachmentCount: attachmentCount,
                errorMessage: errorMessage,
                trigger: trigger,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupLogsTable,
      BackupLog,
      $$BackupLogsTableFilterComposer,
      $$BackupLogsTableOrderingComposer,
      $$BackupLogsTableAnnotationComposer,
      $$BackupLogsTableCreateCompanionBuilder,
      $$BackupLogsTableUpdateCompanionBuilder,
      (BackupLog, BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>),
      BackupLog,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      required String recordTable,
      required int localId,
      required String syncId,
      Value<int> version,
      required String deviceId,
      Value<bool> isDeleted,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> lastModifiedAt,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<String> recordTable,
      Value<int> localId,
      Value<String> syncId,
      Value<int> version,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> lastModifiedAt,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordTable = const Value.absent(),
                Value<int> localId = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> lastModifiedAt = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                recordTable: recordTable,
                localId: localId,
                syncId: syncId,
                version: version,
                deviceId: deviceId,
                isDeleted: isDeleted,
                lastSyncedAt: lastSyncedAt,
                lastModifiedAt: lastModifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordTable,
                required int localId,
                required String syncId,
                Value<int> version = const Value.absent(),
                required String deviceId,
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> lastModifiedAt = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                recordTable: recordTable,
                localId: localId,
                syncId: syncId,
                version: version,
                deviceId: deviceId,
                isDeleted: isDeleted,
                lastSyncedAt: lastSyncedAt,
                lastModifiedAt: lastModifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<int> id,
      required String syncId,
      required String recordTable,
      required int localVersion,
      required int remoteVersion,
      required String localDataJson,
      required String remoteDataJson,
      Value<String> status,
      Value<String?> resolution,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<String> recordTable,
      Value<int> localVersion,
      Value<int> remoteVersion,
      Value<String> localDataJson,
      Value<String> remoteDataJson,
      Value<String> status,
      Value<String?> resolution,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get recordTable => $composableBuilder(
    column: $table.recordTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<String> recordTable = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<int> remoteVersion = const Value.absent(),
                Value<String> localDataJson = const Value.absent(),
                Value<String> remoteDataJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                syncId: syncId,
                recordTable: recordTable,
                localVersion: localVersion,
                remoteVersion: remoteVersion,
                localDataJson: localDataJson,
                remoteDataJson: remoteDataJson,
                status: status,
                resolution: resolution,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required String recordTable,
                required int localVersion,
                required int remoteVersion,
                required String localDataJson,
                required String remoteDataJson,
                Value<String> status = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                syncId: syncId,
                recordTable: recordTable,
                localVersion: localVersion,
                remoteVersion: remoteVersion,
                localDataJson: localDataJson,
                remoteDataJson: remoteDataJson,
                status: status,
                resolution: resolution,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$SyncLogsTableCreateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      required String status,
      Value<String> direction,
      Value<int> recordsPushed,
      Value<int> recordsPulled,
      Value<int> conflictsDetected,
      Value<String?> errorMessage,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });
typedef $$SyncLogsTableUpdateCompanionBuilder =
    SyncLogsCompanion Function({
      Value<int> id,
      Value<String> status,
      Value<String> direction,
      Value<int> recordsPushed,
      Value<int> recordsPulled,
      Value<int> conflictsDetected,
      Value<String?> errorMessage,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsPushed => $composableBuilder(
    column: $table.recordsPushed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordsPulled => $composableBuilder(
    column: $table.recordsPulled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conflictsDetected => $composableBuilder(
    column: $table.conflictsDetected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsPushed => $composableBuilder(
    column: $table.recordsPushed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordsPulled => $composableBuilder(
    column: $table.recordsPulled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conflictsDetected => $composableBuilder(
    column: $table.conflictsDetected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get recordsPushed => $composableBuilder(
    column: $table.recordsPushed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordsPulled => $composableBuilder(
    column: $table.recordsPulled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conflictsDetected => $composableBuilder(
    column: $table.conflictsDetected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          SyncLog,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
          SyncLog,
          PrefetchHooks Function()
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> recordsPushed = const Value.absent(),
                Value<int> recordsPulled = const Value.absent(),
                Value<int> conflictsDetected = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                status: status,
                direction: direction,
                recordsPushed: recordsPushed,
                recordsPulled: recordsPulled,
                conflictsDetected: conflictsDetected,
                errorMessage: errorMessage,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String status,
                Value<String> direction = const Value.absent(),
                Value<int> recordsPushed = const Value.absent(),
                Value<int> recordsPulled = const Value.absent(),
                Value<int> conflictsDetected = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                status: status,
                direction: direction,
                recordsPushed: recordsPushed,
                recordsPulled: recordsPulled,
                conflictsDetected: conflictsDetected,
                errorMessage: errorMessage,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      SyncLog,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (SyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, SyncLog>),
      SyncLog,
      PrefetchHooks Function()
    >;
typedef $$AutoLockProfilesTableCreateCompanionBuilder =
    AutoLockProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> timeoutSeconds,
      Value<bool> isActive,
      Value<bool> lockOnMinimize,
      Value<String?> scheduleCron,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AutoLockProfilesTableUpdateCompanionBuilder =
    AutoLockProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> timeoutSeconds,
      Value<bool> isActive,
      Value<bool> lockOnMinimize,
      Value<String?> scheduleCron,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AutoLockProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $AutoLockProfilesTable> {
  $$AutoLockProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lockOnMinimize => $composableBuilder(
    column: $table.lockOnMinimize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AutoLockProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $AutoLockProfilesTable> {
  $$AutoLockProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lockOnMinimize => $composableBuilder(
    column: $table.lockOnMinimize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AutoLockProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutoLockProfilesTable> {
  $$AutoLockProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get lockOnMinimize => $composableBuilder(
    column: $table.lockOnMinimize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AutoLockProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AutoLockProfilesTable,
          AutoLockProfile,
          $$AutoLockProfilesTableFilterComposer,
          $$AutoLockProfilesTableOrderingComposer,
          $$AutoLockProfilesTableAnnotationComposer,
          $$AutoLockProfilesTableCreateCompanionBuilder,
          $$AutoLockProfilesTableUpdateCompanionBuilder,
          (
            AutoLockProfile,
            BaseReferences<
              _$AppDatabase,
              $AutoLockProfilesTable,
              AutoLockProfile
            >,
          ),
          AutoLockProfile,
          PrefetchHooks Function()
        > {
  $$AutoLockProfilesTableTableManager(
    _$AppDatabase db,
    $AutoLockProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutoLockProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutoLockProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutoLockProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> lockOnMinimize = const Value.absent(),
                Value<String?> scheduleCron = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AutoLockProfilesCompanion(
                id: id,
                name: name,
                timeoutSeconds: timeoutSeconds,
                isActive: isActive,
                lockOnMinimize: lockOnMinimize,
                scheduleCron: scheduleCron,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> timeoutSeconds = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> lockOnMinimize = const Value.absent(),
                Value<String?> scheduleCron = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AutoLockProfilesCompanion.insert(
                id: id,
                name: name,
                timeoutSeconds: timeoutSeconds,
                isActive: isActive,
                lockOnMinimize: lockOnMinimize,
                scheduleCron: scheduleCron,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AutoLockProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AutoLockProfilesTable,
      AutoLockProfile,
      $$AutoLockProfilesTableFilterComposer,
      $$AutoLockProfilesTableOrderingComposer,
      $$AutoLockProfilesTableAnnotationComposer,
      $$AutoLockProfilesTableCreateCompanionBuilder,
      $$AutoLockProfilesTableUpdateCompanionBuilder,
      (
        AutoLockProfile,
        BaseReferences<_$AppDatabase, $AutoLockProfilesTable, AutoLockProfile>,
      ),
      AutoLockProfile,
      PrefetchHooks Function()
    >;
typedef $$AttachmentLocksTableCreateCompanionBuilder =
    AttachmentLocksCompanion Function({
      Value<int> id,
      required int attachmentId,
      Value<bool> isLocked,
      Value<String?> credentialReference,
      Value<DateTime> lockedAt,
      Value<DateTime?> unlockedAt,
    });
typedef $$AttachmentLocksTableUpdateCompanionBuilder =
    AttachmentLocksCompanion Function({
      Value<int> id,
      Value<int> attachmentId,
      Value<bool> isLocked,
      Value<String?> credentialReference,
      Value<DateTime> lockedAt,
      Value<DateTime?> unlockedAt,
    });

final class $$AttachmentLocksTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttachmentLocksTable, AttachmentLock> {
  $$AttachmentLocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) =>
      db.attachments.createAlias(
        $_aliasNameGenerator(
          db.attachmentLocks.attachmentId,
          db.attachments.id,
        ),
      );

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<int>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentLocksTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentLocksTable> {
  $$AttachmentLocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentLocksTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentLocksTable> {
  $$AttachmentLocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableOrderingComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentLocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentLocksTable> {
  $$AttachmentLocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get credentialReference => $composableBuilder(
    column: $table.credentialReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedAt =>
      $composableBuilder(column: $table.lockedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentLocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentLocksTable,
          AttachmentLock,
          $$AttachmentLocksTableFilterComposer,
          $$AttachmentLocksTableOrderingComposer,
          $$AttachmentLocksTableAnnotationComposer,
          $$AttachmentLocksTableCreateCompanionBuilder,
          $$AttachmentLocksTableUpdateCompanionBuilder,
          (AttachmentLock, $$AttachmentLocksTableReferences),
          AttachmentLock,
          PrefetchHooks Function({bool attachmentId})
        > {
  $$AttachmentLocksTableTableManager(
    _$AppDatabase db,
    $AttachmentLocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentLocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentLocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentLocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attachmentId = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String?> credentialReference = const Value.absent(),
                Value<DateTime> lockedAt = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => AttachmentLocksCompanion(
                id: id,
                attachmentId: attachmentId,
                isLocked: isLocked,
                credentialReference: credentialReference,
                lockedAt: lockedAt,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attachmentId,
                Value<bool> isLocked = const Value.absent(),
                Value<String?> credentialReference = const Value.absent(),
                Value<DateTime> lockedAt = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => AttachmentLocksCompanion.insert(
                id: id,
                attachmentId: attachmentId,
                isLocked: isLocked,
                credentialReference: credentialReference,
                lockedAt: lockedAt,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentLocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attachmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attachmentId,
                                referencedTable:
                                    $$AttachmentLocksTableReferences
                                        ._attachmentIdTable(db),
                                referencedColumn:
                                    $$AttachmentLocksTableReferences
                                        ._attachmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentLocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentLocksTable,
      AttachmentLock,
      $$AttachmentLocksTableFilterComposer,
      $$AttachmentLocksTableOrderingComposer,
      $$AttachmentLocksTableAnnotationComposer,
      $$AttachmentLocksTableCreateCompanionBuilder,
      $$AttachmentLocksTableUpdateCompanionBuilder,
      (AttachmentLock, $$AttachmentLocksTableReferences),
      AttachmentLock,
      PrefetchHooks Function({bool attachmentId})
    >;
typedef $$SecurityEventsTableCreateCompanionBuilder =
    SecurityEventsCompanion Function({
      Value<int> id,
      required String eventType,
      Value<String> severity,
      required String description,
      Value<String?> metadata,
      Value<DateTime> createdAt,
    });
typedef $$SecurityEventsTableUpdateCompanionBuilder =
    SecurityEventsCompanion Function({
      Value<int> id,
      Value<String> eventType,
      Value<String> severity,
      Value<String> description,
      Value<String?> metadata,
      Value<DateTime> createdAt,
    });

class $$SecurityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SecurityEventsTable> {
  $$SecurityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecurityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SecurityEventsTable> {
  $$SecurityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecurityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecurityEventsTable> {
  $$SecurityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SecurityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecurityEventsTable,
          SecurityEvent,
          $$SecurityEventsTableFilterComposer,
          $$SecurityEventsTableOrderingComposer,
          $$SecurityEventsTableAnnotationComposer,
          $$SecurityEventsTableCreateCompanionBuilder,
          $$SecurityEventsTableUpdateCompanionBuilder,
          (
            SecurityEvent,
            BaseReferences<_$AppDatabase, $SecurityEventsTable, SecurityEvent>,
          ),
          SecurityEvent,
          PrefetchHooks Function()
        > {
  $$SecurityEventsTableTableManager(
    _$AppDatabase db,
    $SecurityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecurityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecurityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecurityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SecurityEventsCompanion(
                id: id,
                eventType: eventType,
                severity: severity,
                description: description,
                metadata: metadata,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventType,
                Value<String> severity = const Value.absent(),
                required String description,
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SecurityEventsCompanion.insert(
                id: id,
                eventType: eventType,
                severity: severity,
                description: description,
                metadata: metadata,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecurityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecurityEventsTable,
      SecurityEvent,
      $$SecurityEventsTableFilterComposer,
      $$SecurityEventsTableOrderingComposer,
      $$SecurityEventsTableAnnotationComposer,
      $$SecurityEventsTableCreateCompanionBuilder,
      $$SecurityEventsTableUpdateCompanionBuilder,
      (
        SecurityEvent,
        BaseReferences<_$AppDatabase, $SecurityEventsTable, SecurityEvent>,
      ),
      SecurityEvent,
      PrefetchHooks Function()
    >;
typedef $$EntryMoodsTableCreateCompanionBuilder =
    EntryMoodsCompanion Function({
      Value<int> id,
      required int entryId,
      required int mood,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EntryMoodsTableUpdateCompanionBuilder =
    EntryMoodsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<int> mood,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EntryMoodsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryMoodsTable, EntryMood> {
  $$EntryMoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) => db.entries
      .createAlias($_aliasNameGenerator(db.entryMoods.entryId, db.entries.id));

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryMoodsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryMoodsTable> {
  $$EntryMoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryMoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryMoodsTable> {
  $$EntryMoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryMoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryMoodsTable> {
  $$EntryMoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryMoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryMoodsTable,
          EntryMood,
          $$EntryMoodsTableFilterComposer,
          $$EntryMoodsTableOrderingComposer,
          $$EntryMoodsTableAnnotationComposer,
          $$EntryMoodsTableCreateCompanionBuilder,
          $$EntryMoodsTableUpdateCompanionBuilder,
          (EntryMood, $$EntryMoodsTableReferences),
          EntryMood,
          PrefetchHooks Function({bool entryId})
        > {
  $$EntryMoodsTableTableManager(_$AppDatabase db, $EntryMoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryMoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryMoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryMoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntryMoodsCompanion(
                id: id,
                entryId: entryId,
                mood: mood,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required int mood,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntryMoodsCompanion.insert(
                id: id,
                entryId: entryId,
                mood: mood,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryMoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryMoodsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntryMoodsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryMoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryMoodsTable,
      EntryMood,
      $$EntryMoodsTableFilterComposer,
      $$EntryMoodsTableOrderingComposer,
      $$EntryMoodsTableAnnotationComposer,
      $$EntryMoodsTableCreateCompanionBuilder,
      $$EntryMoodsTableUpdateCompanionBuilder,
      (EntryMood, $$EntryMoodsTableReferences),
      EntryMood,
      PrefetchHooks Function({bool entryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db, _db.journals);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$JournalTagsTableTableManager get journalTags =>
      $$JournalTagsTableTableManager(_db, _db.journalTags);
  $$EntryTagsTableTableManager get entryTags =>
      $$EntryTagsTableTableManager(_db, _db.entryTags);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$AttachmentTextsTableTableManager get attachmentTexts =>
      $$AttachmentTextsTableTableManager(_db, _db.attachmentTexts);
  $$BacklinksTableTableManager get backlinks =>
      $$BacklinksTableTableManager(_db, _db.backlinks);
  $$SearchPresetsTableTableManager get searchPresets =>
      $$SearchPresetsTableTableManager(_db, _db.searchPresets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AppSecurityTableTableManager get appSecurity =>
      $$AppSecurityTableTableManager(_db, _db.appSecurity);
  $$EntryRevisionsTableTableManager get entryRevisions =>
      $$EntryRevisionsTableTableManager(_db, _db.entryRevisions);
  $$VoiceNotesTableTableManager get voiceNotes =>
      $$VoiceNotesTableTableManager(_db, _db.voiceNotes);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db, _db.backupLogs);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$AutoLockProfilesTableTableManager get autoLockProfiles =>
      $$AutoLockProfilesTableTableManager(_db, _db.autoLockProfiles);
  $$AttachmentLocksTableTableManager get attachmentLocks =>
      $$AttachmentLocksTableTableManager(_db, _db.attachmentLocks);
  $$SecurityEventsTableTableManager get securityEvents =>
      $$SecurityEventsTableTableManager(_db, _db.securityEvents);
  $$EntryMoodsTableTableManager get entryMoods =>
      $$EntryMoodsTableTableManager(_db, _db.entryMoods);
}
