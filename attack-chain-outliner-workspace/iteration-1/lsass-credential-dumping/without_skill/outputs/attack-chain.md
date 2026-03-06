# LSASS Memory Dumping — Credential Theft Technique

## Overview

**LSASS** (Local Security Authority Subsystem Service) is a core Windows process (`lsass.exe`) responsible for enforcing security policy, handling user authentication, and storing credential material in memory. Because LSASS caches plaintext passwords, NTLM hashes, Kerberos tickets, and other secrets for logged-on users, it is a high-value target for attackers seeking to move laterally or escalate privileges.

LSASS credential dumping is classified under:

- **MITRE ATT&CK:** [T1003.001 — OS Credential Dumping: LSASS Memory](https://attack.mitre.org/techniques/T1003/001/)

---

## How It Works

### What LSASS Stores

| Credential Type       | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| NTLM password hashes  | Used for pass-the-hash attacks                                |
| Plaintext passwords   | Cached via WDigest (older Windows / misconfigured systems)    |
| Kerberos TGTs/tickets | Usable for pass-the-ticket and Golden/Silver Ticket attacks   |
| DPAPI master keys     | Used to decrypt browser-stored credentials and certificates   |

### Attack Flow

1. **Gain elevated access** — Attacker obtains `SYSTEM` or `SeDebugPrivilege` on the target host (typically via initial access + local privilege escalation).
2. **Target the LSASS process** — Identify the PID of `lsass.exe`.
3. **Dump process memory** — Extract the full memory space of LSASS, either to a file (minidump) or directly in-memory.
4. **Parse the dump offline or in-memory** — Tools like Mimikatz parse the credential structures to extract usable secrets.
5. **Use credentials** — Hashes and tickets are leveraged for lateral movement, persistence, or further privilege escalation.

---

## Common Tools and Methods

### Built-in / Living-off-the-Land

| Method                         | Description                                                                        |
|--------------------------------|------------------------------------------------------------------------------------|
| **Task Manager**               | Right-click `lsass.exe` → "Create dump file". Requires admin rights.              |
| **ProcDump** (Sysinternals)    | `procdump.exe -ma lsass.exe lsass.dmp` — Legitimate tool, commonly abused.        |
| **comsvcs.dll MiniDump**       | `rundll32 comsvcs.dll, MiniDump <PID> lsass.dmp full` — No external binary needed.|
| **Windows Error Reporting**    | WER can be manipulated to produce crash dumps of LSASS.                            |

### Offensive Tooling

| Tool           | Notes                                                                            |
|----------------|----------------------------------------------------------------------------------|
| **Mimikatz**   | `sekurlsa::logonpasswords` — The canonical tool; reads LSASS directly or from a dump file. |
| **Pypykatz**   | Python port of Mimikatz; parses dump files offline on Linux.                     |
| **CrackMapExec** | Automates LSASS dumping over SMB across multiple hosts.                        |
| **Cobalt Strike** | Built-in `hashdump` and `logonpasswords` commands; uses reflective injection.  |
| **Nanodump**   | Produces a minidump while evading AV/EDR via syscalls and obfuscated signatures. |
| **PPLdump**    | Bypasses Protected Process Light (PPL) to dump LSASS when it is protected.      |

---

## Prerequisites and Required Privileges

- **SeDebugPrivilege** — Required to open a handle to LSASS; granted to local administrators by default.
- **SYSTEM** — Alternatively, running as SYSTEM bypasses the need for SeDebugPrivilege.
- **Local admin equivalent** — Any account with local admin rights can typically dump LSASS.

> Note: Domain administrator rights alone are not sufficient unless the attacker has a session on a domain controller or has already obtained local admin on the target.

---

## LSASS Protection Mechanisms

### Credential Guard (Windows 10+)
Isolates LSASS in a Hyper-V protected container (VTL1). Secrets are stored in the isolated environment, so even a full LSASS dump will not contain plaintext passwords or Kerberos ticket material. Requires Virtualization-Based Security (VBS).

### Protected Process Light (PPL)
Marks `lsass.exe` as a PPL process, restricting which processes can open a handle to it. Enabled via `HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL = 1`. Can be bypassed by kernel-level exploits or vulnerable drivers (BYOVD).

### WDigest Disabled (Windows 8.1+)
By default, WDigest authentication is disabled on modern Windows, preventing LSASS from caching plaintext passwords. Attackers may attempt to re-enable it: `HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\UseLogonCredential = 1`.

### ASR Rules (Microsoft Defender)
Attack Surface Reduction rule **"Block credential stealing from the Windows local security authority subsystem"** (`9e6c4e1f-7d60-472f-ba1a-a39ef669e4b3`) blocks processes from accessing LSASS memory.

---

## Detection Opportunities

### Event Log Sources

| Source                       | Event ID / Signal                                                      |
|------------------------------|------------------------------------------------------------------------|
| **Security Event Log**       | 4656 / 4663 — Handle requested/opened on `lsass.exe`                  |
| **Security Event Log**       | 4688 — Process creation for ProcDump, rundll32 with comsvcs.dll        |
| **Sysmon**                   | Event 10 — Process access to `lsass.exe` (SourceImage != expected)     |
| **Sysmon**                   | Event 11 — File creation of `.dmp` files in temp directories           |
| **Windows Defender / EDR**   | Alert on Mimikatz signatures or LSASS memory read patterns             |

### Key Behavioral Indicators

- Unexpected process (e.g., `cmd.exe`, `powershell.exe`, `rundll32.exe`) opening a handle to `lsass.exe` with `PROCESS_VM_READ` access rights.
- `procdump.exe` or `comsvcs.dll` executed with arguments referencing LSASS PID or process name.
- `.dmp` files created in `%TEMP%`, `%APPDATA%`, or world-writable directories.
- `sekurlsa`, `logonpasswords`, or `privilege::debug` strings in command-line arguments or script content.
- Unusual network connections immediately following suspected credential dump (sign of lateral movement).

### Detection Query Examples (Pseudo)

**Sysmon Event 10 — Suspicious LSASS Access:**
```
EventID = 10
AND TargetImage CONTAINS "lsass.exe"
AND SourceImage NOT IN (expected_security_tools)
AND GrantedAccess IN (0x1010, 0x1410, 0x143A, 0x1FFFFF)
```

**Process Creation — comsvcs MiniDump:**
```
EventID = 4688 OR Sysmon EventID = 1
AND CommandLine CONTAINS "comsvcs.dll"
AND CommandLine CONTAINS "MiniDump"
```

---

## Attacker Evasion Techniques

| Evasion Technique                   | Description                                                                      |
|-------------------------------------|----------------------------------------------------------------------------------|
| **Direct syscalls**                 | Bypasses user-mode API hooks placed by EDR on `NtReadVirtualMemory` etc.        |
| **Handle duplication**              | Duplicates an existing LSASS handle from another process to avoid creating a new, auditable one. |
| **Kernel driver abuse (BYOVD)**     | Uses a vulnerable signed driver to read kernel memory or disable PPL.            |
| **Dumping from a shadow copy**      | Copies `SYSTEM`, `SECURITY`, and `SAM` hive from a VSS snapshot; avoids touching live LSASS. |
| **Remote dump via RPC/WMI**         | Triggers dump on target remotely so suspicious process runs under a trusted context. |
| **Memory-only parsing**             | Parses credentials directly in memory (no dump file written to disk), reducing forensic artifacts. |

---

## Mitigations

| Control                                | Recommendation                                                                   |
|----------------------------------------|----------------------------------------------------------------------------------|
| **Enable Credential Guard**            | Prevents extraction of NTLM hashes and Kerberos tickets from LSASS memory.      |
| **Enable LSASS PPL**                   | `RunAsPPL = 1`; limits which processes can obtain a handle to LSASS.            |
| **Disable WDigest**                    | Ensure `UseLogonCredential = 0`; prevents plaintext password caching.            |
| **Least privilege**                    | Minimize local administrator accounts; restrict SeDebugPrivilege.               |
| **Enable ASR rules**                   | Block LSASS access via Microsoft Defender ASR rule `9e6c4e1f...`.               |
| **Audit LSASS handles**                | Enable `Audit Object Access` for `lsass.exe` (Security Event 4656/4663).        |
| **Deploy EDR**                         | Modern EDR solutions detect and block LSASS memory reads in real time.          |
| **Privileged Access Workstations**     | Restrict where domain admins log in to reduce exposed Kerberos tickets.         |
| **Tiered administration model**        | Prevent admin credentials from being cached across trust boundaries.            |

---

## MITRE ATT&CK Mapping

| Field           | Value                                                       |
|-----------------|-------------------------------------------------------------|
| Tactic          | Credential Access (TA0006)                                  |
| Technique       | OS Credential Dumping (T1003)                               |
| Sub-technique   | LSASS Memory (T1003.001)                                    |
| Platforms       | Windows                                                     |
| Permissions     | Administrator, SYSTEM, SeDebugPrivilege                     |
| Data Sources    | Process Access, Process Creation, File Creation, Command    |

---

## Related Techniques

- **T1003.002** — SAM Database dump (offline registry hive extraction)
- **T1003.003** — NTDS.dit dump (Active Directory credential database)
- **T1003.006** — DCSync (mimics domain controller replication to pull hashes without touching LSASS directly)
- **T1550.002** — Pass the Hash (using NTLM hashes obtained from LSASS)
- **T1550.003** — Pass the Ticket (using Kerberos tickets obtained from LSASS)

---

## References

- MITRE ATT&CK T1003.001: https://attack.mitre.org/techniques/T1003/001/
- Microsoft — Credential Guard: https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/
- Microsoft — Configuring LSASS PPL: https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
- Microsoft — ASR Rules Reference: https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-reference
