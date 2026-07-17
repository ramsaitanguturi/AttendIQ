class ConflictResolver {
  /// Compares local and remote timestamps to see if local wins.
  /// Last-Write-Wins: client wins if local updatedAt is equal to or after remote updatedAt.
  static bool localWins(DateTime localUpdatedAt, DateTime remoteUpdatedAt) {
    return !localUpdatedAt.isBefore(remoteUpdatedAt);
  }
}
