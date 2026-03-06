# Credential Access

## OS Credential Dumping: LSASS Memory

### Technique Overview

The Local Security Authority Subsystem Service (LSASS) is a critical Windows process (`lsass.exe`) responsible for enforcing security policy, handling user authentication, and managing Active Directory operations. During authentication, Windows stores credential material — including NTLM password hashes, Kerberos tickets, and in some configurations plaintext passwords — in LSASS process memory. This makes LSASS one of the highest-value targets for credential theft on Windows systems.

Adversaries dump LSASS memory to extract these credentials for use in lateral movement, privilege escalation, and persistent access. Because LSASS is a system-privileged process (running as `SYSTEM`), access to its memory requires either `SeDebugPrivilege` or local administrator rights — privileges that post-exploitation attackers typically already possess.

There are several common approaches to LSASS credential dumping:

- **Full process memory dump**: The attacker reads the entire LSASS process address space to disk (a `.dmp` file) using Windows APIs such as `MiniDumpWriteDump`, then parses it offline with tools like Mimikatz. This is the most common approach.
- **Direct API reads**: Tools like Mimikatz use `OpenProcess` + `ReadProcessMemory` on the live LSASS process, extracting credential structures in memory without writing a dump file.
- **Driver/kernel-assisted dumps**: Attackers load a vulnerable or malicious driver to read LSASS memory from kernel space, bypassing user-mode protections like Windows Credential Guard hooks.
- **Shadow copy / registry extraction**: Indirect methods that pull SAM/SYSTEM/SECURITY registry hive files from volume shadow copies, enabling offline hash extraction without touching LSASS directly.

Credentials extracted from LSASS memory enable **Pass-the-Hash (PtH)**, **Pass-the-Ticket (PtT)**, **Overpass-the-Hash**, and direct account compromise without knowing plaintext passwords.

---

### Attack Steps

1. **Gain Privileged Access**: The attacker must hold local administrator privileges or `SYSTEM`-level access. This is typically achieved through prior exploitation, UAC bypass, or token impersonation. Without these privileges, LSASS memory is inaccessible.

2. **Enable SeDebugPrivilege**: Mimikatz and similar tools automatically enable `SeDebugPrivilege` on the attacker's process token, which grants the ability to open handles to processes owned by other users including SYSTEM-owned processes.

   ```
   privilege::debug
   ```

3. **Identify the LSASS Process**: The attacker resolves the PID of `lsass.exe` via `OpenProcess` or through a tool-level enumeration. This is performed by most attack frameworks automatically.

4. **Extract Credentials — Method A: Live Memory Read (Mimikatz)**

   Mimikatz's `sekurlsa` module reads credential structures directly from LSASS memory in real time. This requires no disk artifact but does open a handle to LSASS.

   ```
   sekurlsa::logonpasswords
   ```

   Output includes NTLM hashes, SHA1 hashes, Kerberos tickets, and — on older/misconfigured systems — WDigest plaintext credentials.

5. **Extract Credentials — Method B: Process Memory Dump (ProcDump / Task Manager / comsvcs.dll)**

   The attacker creates a full minidump of LSASS to disk for offline parsing. Several built-in and third-party tools accomplish this:

   **ProcDump (Microsoft Sysinternals):**
   ```cmd
   procdump.exe -accepteula -ma lsass.exe lsass.dmp
   ```

   **Task Manager (GUI):** Right-click `lsass.exe` → "Create dump file" (requires admin).

   **Built-in comsvcs.dll via rundll32 (living off the land):**
   ```cmd
   rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump <lsass_pid> C:\Windows\Temp\lsass.dmp full
   ```

   **PowerShell using .NET (fileless variant):**
   ```powershell
   $lsass = Get-Process lsass
   [System.Diagnostics.Process]::GetProcessById($lsass.Id) | Out-Null
   # Dump via reflection-loaded MiniDumpWriteDump call
   ```

6. **Exfiltrate the Dump File**: The `.dmp` file is compressed and transferred to an attacker-controlled system or parsed locally using Mimikatz:

   ```cmd
   sekurlsa::minidump lsass.dmp
   sekurlsa::logonpasswords
   ```

7. **Use Extracted Credentials**: NTLM hashes are used for Pass-the-Hash; Kerberos tickets enable Pass-the-Ticket or Overpass-the-Hash attacks. Plaintext passwords (if WDigest is enabled) allow direct authentication.

---

### Detection Opportunities

- **Process Handle to LSASS with VM_READ Access (High Fidelity)**: Any process opening an `OpenProcess` handle to `lsass.exe` with access rights including `PROCESS_VM_READ` or `PROCESS_ALL_ACCESS` is a strong indicator. Legitimate processes that access LSASS (AV engines, EDR agents) are typically known and whitelisted. Sysmon Event ID 10 (`ProcessAccess`) captures this with the granted access mask.

- **MiniDump File Creation for lsass.exe (High Fidelity)**: Creation of `.dmp` files referencing lsass, or file write events from processes calling `MiniDumpWriteDump` targeting LSASS, is highly anomalous. Monitor for files named `lsass*.dmp` or any `.dmp` file written to temp/staging directories by non-system processes.

- **rundll32 Executing comsvcs.dll with MiniDump Argument (High Fidelity)**: The `comsvcs.dll` living-off-the-land technique is distinctive: `rundll32.exe` spawning with `comsvcs.dll` and "MiniDump" in the command line is rarely legitimate outside of this attack pattern.

- **ProcDump Execution Targeting lsass (High Fidelity)**: `procdump.exe` or `procdump64.exe` with `-ma lsass` or targeting LSASS PID in the command line. ProcDump is a legitimate tool but its use against LSASS is almost universally malicious.

- **Mimikatz Strings and Indicators (High Fidelity)**: EDR memory scanning for Mimikatz strings (`sekurlsa`, `privilege::debug`, `lsadump`), PE signature, or behavioral fingerprints. PowerShell-loaded or reflectively injected Mimikatz variants also exhibit characteristic API call sequences.

- **Anomalous LSASS Child Processes (Medium Fidelity)**: LSASS should not spawn child processes in normal operation. Any process with `lsass.exe` as parent is suspicious and warrants investigation.

- **Sensitive Privilege Adjustment — SeDebugPrivilege (Medium Fidelity)**: Windows Security Event ID 4703 (Token Right Adjusted) or 4672 (Special Logon) for `SeDebugPrivilege` being enabled on a user process. Legitimate use cases exist (some debuggers, specific admin tools), so context of the requesting process matters.

- **Volume Shadow Copy Access for SAM/SYSTEM/SECURITY (Medium Fidelity)**: Indirect LSASS-free credential dumping via `vssadmin`, `wmic shadowcopy`, or direct VSS path access to extract registry hives. Less common in normal operations but not exclusively malicious (backups).

- **Evasion Techniques**:
  - **Process injection into trusted processes**: Injecting Mimikatz into `explorer.exe` or `svchost.exe` to access LSASS from a trusted process name, evading allowlists based on process name.
  - **PPL bypass via driver**: Attackers use vulnerable signed drivers (BYOVD — Bring Your Own Vulnerable Driver) to remove LSASS Protected Process Light (PPL) protections before dumping.
  - **Custom dumper tools**: Purpose-built LSASS dumpers (NanoDump, HandleKatz, SilentProcessExit, etc.) that avoid common Mimikatz signatures and split the dump to avoid file-level detection.
  - **Encrypted/compressed dumps**: Dumping LSASS memory directly into an encrypted container or compressing immediately before write to evade content-based detection.
  - **Network-based dump**: Some tools dump LSASS memory directly over the network without writing to local disk.
  - **LSASS RunAsPPL bypass**: Kernel-level manipulation or enabling PPL explicitly requires specialized tooling, but misconfigured or unpatched systems may lack PPL entirely.

- **False Positives**:
  - Legitimate EDR/AV solutions open handles to LSASS for monitoring and injection (establish a baseline of known-good processes).
  - Microsoft debugging tools (`cdb.exe`, `windbg.exe`) may access LSASS during authorized diagnostic sessions.
  - Some legitimate backup solutions access LSASS indirectly via VSS.

---

### Data Sources & Log Fields

**Sysmon (Windows Sysinternals):**

- `Event ID 10 — ProcessAccess`: Most critical event for detecting LSASS handle opens
  - `TargetImage`: Must equal `C:\Windows\System32\lsass.exe`
  - `GrantedAccess`: Access mask — flag `0x1010`, `0x1410`, `0x40`, `0x1fffff` (full access)
  - `SourceImage`: The process requesting the handle — compare against allowlist
  - `SourceCommandLine`: Full command line of the requesting process
  - `CallTrace`: Stack trace of the API call — useful for detecting injected code

- `Event ID 1 — ProcessCreate`: Detects ProcDump, Task Manager dump, and comsvcs invocations
  - `Image`: Process executable path
  - `CommandLine`: Full command line — parse for `lsass`, `MiniDump`, `-ma`, comsvcs
  - `ParentImage`: Parent process — flag unusual parents for dump utilities
  - `User`: Executing user context

- `Event ID 11 — FileCreate`: Detects `.dmp` file creation on disk
  - `TargetFilename`: Flag paths matching `*lsass*.dmp` or `*.dmp` in temp directories
  - `Image`: Process that created the file

- `Event ID 7 — ImageLoad`: Detects loading of comsvcs.dll, dbgcore.dll, or other dump-related libraries into unusual processes
  - `Image`: Host process
  - `ImageLoaded`: DLL path — flag `comsvcs.dll` loaded by `rundll32.exe`

**Windows Security Event Log:**

- `Event ID 4656 — Handle to Object Requested`: Object access attempts on LSASS process object
  - `ObjectName`: `\Device\HarddiskVolume*\Windows\System32\lsass.exe` pattern
  - `AccessMask`: Requested access rights
  - `SubjectUserName`: Requesting account

- `Event ID 4663 — Object Access Attempt`: Access to LSASS process object
  - `ObjectName`: LSASS process name
  - `AccessMask`: Actual access granted

- `Event ID 4672 — Special Privileges Assigned`: SeDebugPrivilege granted
  - `SubjectUserName`: Account granted the privilege
  - `PrivilegeList`: Check for `SeDebugPrivilege`

- `Event ID 4703 — Token Right Adjusted`: Runtime privilege enable/disable
  - `EnabledPrivilegeList`: Check for `SeDebugPrivilege` being enabled dynamically

**Windows Defender / Microsoft Defender for Endpoint (MDE):**

- `DeviceProcessEvents`: Process creation and access events with rich context
  - Fields: `ProcessCommandLine`, `InitiatingProcessFileName`, `FileName`

- `DeviceEvents` with `ActionType == "LsassProcessAccess"`: Dedicated MDE telemetry for LSASS handle opens
  - `InitiatingProcessFileName`: Requesting process
  - `AdditionalFields`: Contains `GrantedAccess` mask

- `DeviceFileEvents`: File creation events for dump files
  - `FileName`, `FolderPath`, `InitiatingProcessFileName`

**ETW (Event Tracing for Windows):**

- Provider: `Microsoft-Windows-Security-Auditing`
- Provider: `Microsoft-Windows-Threat-Intelligence` (requires PPL-level consumer, used by EDRs)
  - `KERNEL_THREATINT_TASK_PROTECTEDPROCESS`: Fires on protected process access attempts

**Command-line log inspection:**
```cmd
:: Query Sysmon ProcessAccess events for LSASS targets
wevtutil qe Microsoft-Windows-Sysmon/Operational /q:"*[EventData[Data[@Name='TargetImage'] and Data='C:\Windows\System32\lsass.exe']]" /f:text

:: Query Security log for SeDebugPrivilege assignments
wevtutil qe Security /q:"*[System[EventID=4672] and EventData[Data[@Name='PrivilegeList'] and contains(.,'SeDebugPrivilege')]]" /f:text
```

**Artifacts to monitor:**
- `C:\Windows\Temp\lsass*.dmp`
- `C:\Users\*\AppData\Local\Temp\lsass*.dmp`
- `C:\Windows\System32\lsass.dmp` (Task Manager default location)
- Any `.dmp` file written to staging/exfil directories
- `C:\ProgramData\*.dmp`

---

### Pseudocode Queries

**High Fidelity: LSASS Process Handle with Memory Read Access**
```
event.type == "process_access" AND
process.target.name == "lsass.exe" AND
process.granted_access IN ["0x1010", "0x1410", "0x1fffff", "0x40", "0x1438"] AND
process.source.name NOT IN [
  "MsMpEng.exe", "csrss.exe", "wininit.exe", "services.exe",
  "svchost.exe", "lsm.exe", "taskmgr.exe",
  "<known_edr_agent.exe>"
]
```

**High Fidelity: comsvcs.dll MiniDump Living-off-the-Land**
```
event.type == "process_start" AND
process.name == "rundll32.exe" AND
process.command_line MATCHES "(?i).*comsvcs(\.dll)?.*MiniDump.*" AND
process.command_line MATCHES ".*lsass.*|.*\d{3,5}.*"
```

**High Fidelity: LSASS Dump File Written to Disk**
```
event.type == "file_create" AND
(
  file.name MATCHES "(?i)lsass.*\.dmp" OR
  (
    file.extension == "dmp" AND
    file.path MATCHES "(?i).*(temp|tmp|programdata|appdata).*"
  )
) AND
process.name NOT IN ["werfault.exe", "WerFaultSecure.exe"]
```

**High Fidelity: ProcDump Targeting LSASS**
```
event.type == "process_start" AND
process.name MATCHES "(?i)procdump(64)?\.exe" AND
process.command_line MATCHES "(?i).*(lsass|-ma lsass).*"
```

**Medium Fidelity: SeDebugPrivilege Enabled on Non-System Process**
```
event.type == "privilege_adjusted" AND
event.privilege == "SeDebugPrivilege" AND
event.privilege_state == "enabled" AND
process.name NOT IN [
  "lsass.exe", "csrss.exe", "wininit.exe",
  "MsMpEng.exe", "devenv.exe", "windbg.exe", "cdb.exe"
]
```

**Medium Fidelity: Suspicious DLL Load into rundll32 (comsvcs)**
```
event.type == "image_load" AND
process.name == "rundll32.exe" AND
file.name == "comsvcs.dll" AND
process.command_line MATCHES "(?i).*MiniDump.*"
```

**Medium Fidelity: Anomalous LSASS Child Process**
```
event.type == "process_start" AND
process.parent.name == "lsass.exe" AND
process.name NOT IN ["werfault.exe", "WerFaultSecure.exe"]
```

**Behavioral: Bulk Dump File Staging (Potential Exfil Prep)**
```
// Detects multiple .dmp file creations in short succession in staging directories
event.type == "file_create" AND
file.extension == "dmp" AND
file.path MATCHES "(?i).*(temp|tmp|public|programdata).*"
// Alert when: count(event) > 1 within 5 minutes for same host
```

**Behavioral: Mimikatz CLI Patterns**
```
event.type == "process_start" AND
(
  process.command_line MATCHES "(?i).*(sekurlsa|lsadump|privilege::debug|token::elevate).*" OR
  process.name MATCHES "(?i)mimikatz.*"
)
```

---

### MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| Credential Access | T1003 | OS Credential Dumping |
| Credential Access | T1003.001 | OS Credential Dumping: LSASS Memory |
| Privilege Escalation | T1134 | Access Token Manipulation |
| Defense Evasion | T1134 | Access Token Manipulation |
| Privilege Escalation | T1134.001 | Access Token Manipulation: Token Impersonation/Theft |
| Defense Evasion | T1218.011 | System Binary Proxy Execution: Rundll32 |
| Lateral Movement | T1550.002 | Use Alternate Authentication Material: Pass the Hash |
| Lateral Movement | T1550.003 | Use Alternate Authentication Material: Pass the Ticket |
