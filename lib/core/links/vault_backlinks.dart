enum VaultBacklinkTargetType { journal, entry }

class VaultBacklinkTarget {
  final VaultBacklinkTargetType type;
  final int targetId;

  const VaultBacklinkTarget({required this.type, required this.targetId});
}
