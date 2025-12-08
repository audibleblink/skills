# MDE - Security Device Tables

Security-focused tables for Microsoft Defender for Endpoint (MDE) device telemetry.

---

## Table: DeviceRegistryEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-deviceregistryevents-table?view=o365-worldwide)

**Description:** Creation and modification of registry entries

### Table Schema:
| Field | Description |
| --- | --- |
| **ActionType** | Type of activity that triggered the event |
| **AppGuardContainerId** | Identifier for the Application Guard container |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **InitiatingProcessAccountDomain** | Domain of the account that ran the initiating process |
| **InitiatingProcessAccountName** | User name of the account |
| **InitiatingProcessAccountObjectId** | Azure AD object ID of the user account |
| **InitiatingProcessAccountSid** | SID of the account |
| **InitiatingProcessAccountUpn** | UPN of the account |
| **InitiatingProcessCommandLine** | Command line used to run the initiating process |
| **InitiatingProcessCreationTime** | Date and time when the process was started |
| **InitiatingProcessFileName** | Name of the process that initiated the event |
| **InitiatingProcessFileSize** | Size of the process image file |
| **InitiatingProcessFolderPath** | Folder containing the process |
| **InitiatingProcessId** | Process ID (PID) of the initiating process |
| **InitiatingProcessIntegrityLevel** | Integrity level of the process |
| **InitiatingProcessMD5** | MD5 hash of the process image file |
| **InitiatingProcessParentCreationTime** | Date and time when the parent process was started |
| **InitiatingProcessParentFileName** | Name of the parent process |
| **InitiatingProcessParentId** | PID of the parent process |
| **InitiatingProcessSHA1** | SHA-1 hash of the process image file |
| **InitiatingProcessSHA256** | SHA-256 hash of the process image file |
| **InitiatingProcessTokenElevation** | Token elevation type |
| **PreviousRegistryKey** | Original registry key before modification |
| **PreviousRegistryValueData** | Original data of the registry value before modification |
| **PreviousRegistryValueName** | Original name of the registry value before modification |
| **RegistryKey** | Registry key that the recorded action was applied to |
| **RegistryValueData** | Data of the registry value |
| **RegistryValueName** | Name of the registry value |
| **RegistryValueType** | Data type of the registry value (binary, string, etc.) |
| **ReportId** | Event identifier based on a repeating counter |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **RegistryKeyCreated** | A registry key was created |
| **RegistryKeyDeleted** | A registry key was deleted |
| **RegistryKeyRenamed** | A registry key was renamed |
| **RegistryValueDeleted** | A registry value was deleted |
| **RegistryValueSet** | The data for a registry value was modified |

### Examples:

#### Check for services set to automatically start with Windows
```kql
let myDevice = "<insert your device ID>";
DeviceRegistryEvents
| where DeviceId == myDevice
    and ActionType in ("RegistryValueSet")
    and RegistryKey matches regex @"HKEY_LOCAL_MACHINE\\SYSTEM\\.*\\Services\\.*"
    and RegistryValueName == "Start" and RegistryValueData == "2"
| limit 100
```

#### Detect disabling of Defender
```kql
DeviceRegistryEvents
| where RegistryKey has @"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender"
    and (RegistryValueName has "DisableRealtimeProtection"
    or RegistryValueName has "DisableRealtimeMonitoring"
    or RegistryValueName has "DisableBehaviorMonitoring"
    or RegistryValueName has "DisableIOAVProtection"
    or RegistryValueName has "DisableScriptScanning"
    or RegistryValueName has "DisableBlockAtFirstSeen")
    and RegistryValueData has "1"
    and isnotempty(PreviousRegistryValueData)
    and Timestamp > ago(7d)
| project Timestamp, ActionType, DeviceId, DeviceName, RegistryKey, RegistryValueName, RegistryValueData, PreviousRegistryValueData
```

---

## Table: DeviceLogonEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicelogonevents-table?view=o365-worldwide)

**Description:** Sign-ins and other authentication events

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountSid** | Security Identifier (SID) of the account |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **FailureReason** | Information explaining why the recorded action failed |
| **InitiatingProcessAccountDomain** | Domain of the account that ran the initiating process |
| **InitiatingProcessAccountName** | User name of the account that ran the initiating process |
| **InitiatingProcessAccountObjectId** | Azure AD object ID of the user account |
| **InitiatingProcessAccountSid** | SID of the account that ran the initiating process |
| **InitiatingProcessAccountUpn** | UPN of the account that ran the initiating process |
| **InitiatingProcessCommandLine** | Command line used to run the initiating process |
| **InitiatingProcessCreationTime** | Date and time when the initiating process was started |
| **InitiatingProcessFileName** | Name of the process that initiated the event |
| **InitiatingProcessFileSize** | Size of the initiating process image file |
| **InitiatingProcessFolderPath** | Folder containing the initiating process |
| **InitiatingProcessId** | Process ID (PID) of the initiating process |
| **InitiatingProcessIntegrityLevel** | Integrity level of the initiating process |
| **InitiatingProcessMD5** | MD5 hash of the initiating process image file |
| **InitiatingProcessParentCreationTime** | Date and time when the parent process was started |
| **InitiatingProcessParentFileName** | Name of the parent process |
| **InitiatingProcessParentId** | PID of the parent process |
| **InitiatingProcessSHA1** | SHA-1 hash of the initiating process image file |
| **InitiatingProcessSHA256** | SHA-256 hash of the initiating process image file |
| **InitiatingProcessTokenElevation** | Token elevation type |
| **IsLocalAdmin** | Boolean indicator of whether the user is a local administrator on the device |
| **LogonId** | Identifier for a logon session |
| **LogonType** | Type of logon session (Interactive, RemoteInteractive, Network, Batch, Service, etc.) |
| **Protocol** | Protocol used during the authentication |
| **RemoteDeviceName** | Name of the device that performed a remote operation on the affected device |
| **RemoteIP** | IP address that was being connected to |
| **RemoteIPType** | Type of IP address (Public, Private, Reserved, Loopback, etc.) |
| **RemotePort** | TCP port on the remote device |
| **ReportId** | Event identifier based on a repeating counter |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **LogonAttempted** | A user attempted to log on to the device |
| **LogonFailed** | A user attempted to logon but failed |
| **LogonSuccess** | A user successfully logged on to the device |

### LogonType Values:
| LogonType | Description |
| --- | --- |
| **Batch** | Batch logon (scheduled tasks) |
| **CachedInteractive** | Cached credentials logon (offline) |
| **CachedRemoteInteractive** | Cached remote interactive logon |
| **CachedUnlock** | Cached unlock logon |
| **Interactive** | User logged on via keyboard/mouse |
| **Network** | User/computer logged on via network (SMB, mapped drives) |
| **NetworkCleartext** | User logged on via network with cleartext credentials |
| **NewCredentials** | Clone of current token with new credentials for outbound connections |
| **RemoteInteractive** | User logged on via RDP/Terminal Services |
| **Service** | Service started by Service Control Manager |
| **Unlock** | Workstation unlock |

### Examples:

#### Find logons that occurred right after malicious email was received
```kql
let MaliciousEmail = EmailEvents
| where ThreatTypes has "Malware"
| project TimeEmail = Timestamp, Subject, SenderFromAddress, AccountName = tostring(split(RecipientEmailAddress, "@")[0]);
MaliciousEmail
| join (
    DeviceLogonEvents
    | project LogonTime = Timestamp, AccountName, DeviceName
) on AccountName
| where (LogonTime - TimeEmail) between (0min .. 30min)
| take 10
```

#### List authentication events by local administrators
```kql
let myDevice = "<insert your device ID>";
DeviceLogonEvents
| where IsLocalAdmin == '1' and Timestamp > ago(7d) and DeviceId == myDevice
| limit 500
```

---

## Table: DeviceImageLoadEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-deviceimageloadevents-table?view=o365-worldwide)

**Description:** DLL loading events

### Table Schema:
| Field | Description |
| --- | --- |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **AppGuardContainerId** | Identifier for the Application Guard container |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **FileName** | Name of the loaded DLL file |
| **FileSize** | Size of the file in bytes |
| **FolderPath** | Folder containing the loaded DLL |
| **InitiatingProcessAccountDomain** | Domain of the account that ran the initiating process |
| **InitiatingProcessAccountName** | User name of the account that ran the initiating process |
| **InitiatingProcessAccountObjectId** | Azure AD object ID of the user account |
| **InitiatingProcessAccountSid** | SID of the account that ran the initiating process |
| **InitiatingProcessAccountUpn** | UPN of the account that ran the initiating process |
| **InitiatingProcessCommandLine** | Command line used to run the initiating process |
| **InitiatingProcessCreationTime** | Date and time when the initiating process was started |
| **InitiatingProcessFileName** | Name of the process that loaded the DLL |
| **InitiatingProcessFileSize** | Size of the initiating process image file |
| **InitiatingProcessFolderPath** | Folder containing the initiating process |
| **InitiatingProcessId** | Process ID (PID) of the initiating process |
| **InitiatingProcessIntegrityLevel** | Integrity level of the initiating process |
| **InitiatingProcessMD5** | MD5 hash of the initiating process image file |
| **InitiatingProcessParentCreationTime** | Date and time when the parent process was started |
| **InitiatingProcessParentFileName** | Name of the parent process |
| **InitiatingProcessParentId** | PID of the parent process |
| **InitiatingProcessSHA1** | SHA-1 hash of the initiating process image file |
| **InitiatingProcessSHA256** | SHA-256 hash of the initiating process image file |
| **InitiatingProcessSignatureStatus** | Signature status of the initiating process |
| **InitiatingProcessSignerType** | Type of file signer of the initiating process |
| **InitiatingProcessTokenElevation** | Token elevation type |
| **MD5** | MD5 hash of the loaded DLL |
| **ReportId** | Event identifier based on a repeating counter |
| **SHA1** | SHA-1 hash of the loaded DLL |
| **SHA256** | SHA-256 hash of the loaded DLL |
| **SignatureStatus** | Signature status of the loaded DLL |
| **SignerType** | Type of file signer of the loaded DLL |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **ImageLoaded** | A dynamic link library (DLL) was loaded |

### Examples:

#### Detect unsigned DLLs loaded by system processes
```kql
DeviceImageLoadEvents
| where Timestamp > ago(24h)
| where InitiatingProcessFileName in~ ("svchost.exe", "services.exe", "lsass.exe")
| where SignatureStatus != "Valid" or SignerType != "Microsoft"
| project Timestamp, DeviceName, InitiatingProcessFileName, FileName, FolderPath, SignatureStatus, SHA256
```

#### Find DLL side-loading attempts (DLLs loaded from unusual locations)
```kql
DeviceImageLoadEvents
| where Timestamp > ago(7d)
| where FolderPath !startswith "C:\\Windows\\System32"
    and FolderPath !startswith "C:\\Windows\\SysWOW64"
    and FolderPath !startswith "C:\\Program Files"
| where InitiatingProcessFileName in~ ("rundll32.exe", "regsvr32.exe")
| project Timestamp, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, FileName, FolderPath, SHA256
| limit 100
```

#### Hunt for specific malicious DLL by hash
```kql
let maliciousHash = "<insert SHA256 hash>";
DeviceImageLoadEvents
| where Timestamp > ago(30d)
| where SHA256 == maliciousHash
| project Timestamp, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, FileName, FolderPath
```

---

## Table: DeviceEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-deviceevents-table?view=o365-worldwide)

**Description:** Multiple event types, including events triggered by security controls such as Windows Defender Antivirus and exploit protection

### Key ActionTypes for Threat Hunting:
| ActionType | Description |
| --- | --- |
| **AntivirusDetection** | Windows Defender Antivirus detected a threat |
| **AsrLsassCredentialTheftBlocked** | ASR blocked possible credential theft from lsass.exe |
| **CreateRemoteThreadApiCall** | A thread running in another process's address space was created |
| **DpapiAccessed** | Decryption of sensitive data encrypted using DPAPI |
| **DriverLoad** | A driver was loaded |
| **LdapSearch** | An LDAP search was performed |
| **NamedPipeEvent** | A named pipe was created or opened |
| **OpenProcessApiCall** | OpenProcess function called (potential process manipulation) |
| **PlistPropertyModified** | A property in a plist was modified (macOS) |
| **PowerShellCommand** | A PowerShell command was executed |
| **ScheduledTaskCreated** | A scheduled task was created |
| **ScheduledTaskUpdated** | A scheduled task was updated |
| **ServiceInstalled** | A service was installed |
| **WmiBindEventFilterToConsumer** | A WMI event filter was bound to a consumer |

### Examples:

#### Get antivirus scan events
```kql
let myDevice = "<insert your device ID>";
DeviceEvents
| where ActionType startswith "AntivirusScan" and Timestamp > ago(7d) and DeviceId == myDevice
| extend ScanDesc = parse_json(AdditionalFields)
| project Timestamp, DeviceName, ActionType, Domain = ScanDesc.Domain, ScanId = ScanDesc.ScanId, User = ScanDesc.User
```

#### Get list of USB devices attached to a device
```kql
let myDevice = "<insert your device ID>";
DeviceEvents
| where ActionType == "UsbDriveMount" and Timestamp > ago(7d) and DeviceId == myDevice
| extend ProductName = todynamic(AdditionalFields)["ProductName"],
         SerialNumber = todynamic(AdditionalFields)["SerialNumber"],
         Manufacturer = todynamic(AdditionalFields)["Manufacturer"],
         Volume = todynamic(AdditionalFields)["Volume"]
| summarize lastInsert = max(Timestamp) by tostring(ProductName), tostring(SerialNumber), tostring(Manufacturer), tostring(Volume)
```

---

## Table: DeviceFileCertificateInfo

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicefilecertificateinfo-table?view=o365-worldwide)

**Description:** Certificate information of signed files obtained from certificate verification events on endpoints

### Examples:

#### Find files with suspicious ECC certificates
```kql
DeviceFileCertificateInfo
| where Timestamp > ago(30d)
| where IsSigned == 1 and IsTrusted == 1 and IsRootSignerMicrosoft == 1
| where SignatureType == "Embedded"
| where Issuer !startswith "Microsoft" and Issuer !startswith "Windows"
| project Timestamp, DeviceName, SHA1, Issuer, IssuerHash, Signer, SignerHash, CertificateCreationTime, CertificateExpirationTime, CrlDistributionPointUrls
| limit 10
```
