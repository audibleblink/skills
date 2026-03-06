# Explanation

This query uses the `DeviceFileEvents` table, which captures file create, modify, and rename operations on enrolled endpoints. It filters for `.plist` files written to the standard LaunchAgent and LaunchDaemon directories on macOS — the canonical locations used for user-level and system-level persistence. The `InitiatingProcess*` fields expose the process name, full path, command line, and account responsible for the change, giving visibility into what wrote the plist without needing a separate join.
