# MDE - Core Device Tables

Core tables for Microsoft Defender for Endpoint (MDE) device telemetry.

---

## Table: DeviceInfo

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-deviceinfo-table?view=o365-worldwide)

**Description:** Machine information, including OS information

### Table Schema:
| Field | Description |
| --- | --- |
| **AadDeviceId** | Unique identifier for the device in Azure AD |
| **AdditionalFields** | Additional information about the entity or event |
| **AssetValue** | Priority or value assigned to the device (Low, Normal, High) |
| **ClientVersion** | Version of the endpoint agent or sensor |
| **DeviceCategory** | Broader classification (Endpoint, Network device, IoT, Unknown) |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **DeviceSubtype** | Additional modifier for certain device types |
| **DeviceType** | Type of device (workstation, server, mobile, etc.) |
| **ExclusionReason** | The reason for the device being excluded |
| **ExposureLevel** | The device's level of vulnerability (Low, Medium, High) |
| **IsAzureADJoined** | Boolean indicator of whether machine is joined to Azure AD |
| **IsExcluded** | Determines if the device is excluded from views and reports |
| **IsInternetFacing** | Indicates whether the device is internet-facing |
| **JoinType** | The device's Azure Active Directory join type |
| **LoggedOnUsers** | List of all users logged on the machine (JSON array) |
| **MachineGroup** | Machine group for role-based access control |
| **MergedDeviceIds** | Previous device IDs assigned to the same device |
| **MergedToDeviceId** | The most recent device ID assigned |
| **Model** | Model name or number of the product |
| **OnboardingStatus** | Indicates whether the device is onboarded to MDE |
| **OSArchitecture** | Architecture of the operating system |
| **OSBuild** | Build version of the operating system |
| **OSDistribution** | Distribution of the OS platform (Ubuntu, RedHat, etc.) |
| **OSPlatform** | Platform of the operating system (Windows 10, macOS, etc.) |
| **OSVersion** | Version of the operating system |
| **OSVersionInfo** | Additional info about the OS version |
| **PublicIP** | Public IP address used to connect to MDE service |
| **RegistryDeviceTag** | Device tag added through the registry |
| **ReportId** | Event identifier based on a repeating counter |
| **SensorHealthState** | Indicates health of the device's EDR sensor |
| **Timestamp** | Date and time when the record was generated |
| **Vendor** | Name of the product vendor or manufacturer |

### Examples:

#### List devices running operating systems older than Windows 10
```kql
DeviceInfo
| where todecimal(OSVersion) < 10
| summarize by DeviceId, DeviceName, OSVersion, OSPlatform, OSBuild
```

#### List users that have logged on to a specific device
```kql
let myDevice = "<insert your device ID>";
DeviceInfo
| where Timestamp between (datetime(2020-05-19) .. datetime(2020-05-20)) and DeviceId == myDevice
| project LoggedOnUsers
| mvexpand todynamic(LoggedOnUsers) to typeof(string)
| summarize by LoggedOnUsers
```

---

## Table: DeviceNetworkInfo

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicenetworkinfo-table?view=o365-worldwide)

**Description:** Network properties of machines, including adapters, IP and MAC addresses, connected networks and domains

### Table Schema:
| Field | Description |
| --- | --- |
| **ConnectedNetworks** | Networks that the adapter is connected to (JSON array) |
| **DefaultGateways** | Default gateway addresses in JSON array format |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **DnsAddresses** | DNS server addresses in JSON array format |
| **IPAddresses** | JSON array containing all IP addresses assigned to the adapter |
| **IPv4Dhcp** | IPv4 address of DHCP server |
| **IPv6Dhcp** | IPv6 address of DHCP server |
| **MacAddress** | MAC address of the network adapter |
| **NetworkAdapterName** | Name of the network adapter |
| **NetworkAdapterStatus** | Operational status of the network adapter |
| **NetworkAdapterType** | Network adapter type |
| **NetworkAdapterVendor** | Name of the manufacturer or vendor |
| **ReportId** | Event identifier based on a repeating counter |
| **Timestamp** | Date and time when the record was generated |
| **TunnelType** | Tunneling protocol (6to4, Teredo, ISATAP, PPTP, SSTP, SSH) |

### Examples:

#### List all devices that have been assigned a specific IP address
```kql
let pivotTimeParam = datetime(2020-05-18 19:51:00);
let ipAddressParam = "192.168.1.5";
DeviceNetworkInfo
| where Timestamp between ((pivotTimeParam-15m) .. 30m)
    and IPAddresses contains strcat("\"", ipAddressParam, "\"")
    and NetworkAdapterStatus == "Up"
| project DeviceName, Timestamp, IPAddresses, TimeDifference=abs(Timestamp-pivotTimeParam)
| sort by TimeDifference asc
```

---

## Table: DeviceProcessEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-deviceprocessevents-table?view=o365-worldwide)

**Description:** Process creation and related events

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountSid** | Security Identifier (SID) of the account |
| **AccountUpn** | User principal name (UPN) of the account |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **AppGuardContainerId** | Identifier for the Application Guard container |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **FileName** | Name of the file that the recorded action was applied to |
| **FileSize** | Size of the file in bytes |
| **FolderPath** | Folder containing the file |
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
| **InitiatingProcessLogonId** | Identifier for a logon session of the initiating process |
| **InitiatingProcessMD5** | MD5 hash of the initiating process image file |
| **InitiatingProcessParentCreationTime** | Date and time when the parent process was started |
| **InitiatingProcessParentFileName** | Name of the parent process |
| **InitiatingProcessParentId** | PID of the parent process |
| **InitiatingProcessSHA1** | SHA-1 hash of the initiating process image file |
| **InitiatingProcessSHA256** | SHA-256 hash of the initiating process image file |
| **InitiatingProcessSignatureStatus** | Signature status of the initiating process |
| **InitiatingProcessSignerType** | Type of file signer of the initiating process |
| **InitiatingProcessTokenElevation** | Token elevation type (Limited, Default, Full) |
| **LogonId** | Identifier for a logon session |
| **MD5** | MD5 hash of the file |
| **ProcessCommandLine** | Command line used to create the new process |
| **ProcessCreationTime** | Date and time the process was created |
| **ProcessId** | Process ID (PID) of the newly created process |
| **ProcessIntegrityLevel** | Integrity level of the newly created process |
| **ProcessTokenElevation** | Token elevation type applied to the new process |
| **ReportId** | Event identifier based on a repeating counter |
| **SHA1** | SHA-1 hash of the file |
| **SHA256** | SHA-256 hash of the file |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **OpenProcess** | The OpenProcess function was called indicating an attempt to open a handle to a process |
| **ProcessCreated** | A process was launched on the device |

### Examples:

#### Check process command lines for attempts to clear event logs
```kql
let myDevice = "<insert your device ID>";
DeviceProcessEvents
| where DeviceId == myDevice and Timestamp > ago(7d)
| where (InitiatingProcessCommandLine contains "wevtutil" and
    (InitiatingProcessCommandLine contains ' cl ' or
     InitiatingProcessCommandLine contains ' clear ' or
     InitiatingProcessCommandLine contains ' clearev '))
    or (InitiatingProcessCommandLine contains ' wmic ' and
        InitiatingProcessCommandLine contains ' cleareventlog ')
```

#### Find PowerShell activities after receiving an email from a malicious sender
```kql
let MaliciousSender = "malicious.sender@domain.com";
EmailEvents
| where Timestamp > ago(7d)
| where SenderFromAddress =~ MaliciousSender
| project EmailReceivedTime = Timestamp, Subject, SenderFromAddress, AccountName = tostring(split(RecipientEmailAddress, "@")[0])
| join (
    DeviceProcessEvents
    | where Timestamp > ago(7d)
    | where FileName =~ "powershell.exe"
    | where InitiatingProcessParentFileName =~ "outlook.exe"
    | project ProcessCreateTime = Timestamp, AccountName, DeviceName, InitiatingProcessParentFileName, InitiatingProcessFileName, FileName, ProcessCommandLine
) on AccountName
| where (ProcessCreateTime - EmailReceivedTime) between (0min .. 30min)
```

---

## Table: DeviceNetworkEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicenetworkevents-table?view=o365-worldwide)

**Description:** Network connection and related events

### Table Schema:
| Field | Description |
| --- | --- |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
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
| **LocalIP** | IP address assigned to the local machine |
| **LocalIPType** | Type of IP address (Public, Private, Reserved, etc.) |
| **LocalPort** | TCP port on the local machine |
| **Protocol** | Protocol used during the communication |
| **RemoteIP** | IP address that was being connected to |
| **RemoteIPType** | Type of IP address |
| **RemotePort** | TCP port on the remote device |
| **RemoteUrl** | URL or FQDN that was being connected to |
| **ReportId** | Event identifier based on a repeating counter |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **ConnectionFailed** | An attempt to establish a network connection failed |
| **ConnectionFound** | An active network connection was found |
| **ConnectionRequest** | The device initiated a network connection |
| **ConnectionSuccess** | A network connection was successfully established |
| **InboundConnectionAccepted** | The device accepted a network connection |
| **ListeningConnectionCreated** | A process started listening for connections on a port |

### Examples:

#### Find PowerShell execution events that could involve a download
```kql
union DeviceProcessEvents, DeviceNetworkEvents
| where Timestamp > ago(7d)
| where FileName in~ ("powershell.exe", "powershell_ise.exe")
| where ProcessCommandLine has_any("WebClient", "DownloadFile", "DownloadData", "DownloadString", "WebRequest", "Shellcode", "http", "https")
| project Timestamp, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, FileName, ProcessCommandLine, RemoteIP, RemoteUrl, RemotePort, RemoteIPType
| top 100 by Timestamp
```

#### Find network connections by known Tor clients
```kql
DeviceNetworkEvents
| where Timestamp > ago(7d) and InitiatingProcessFileName in~ ("tor.exe", "meek-client.exe")
| summarize DeviceCount=dcount(DeviceId), DeviceNames=make_set(DeviceName, 5) by InitiatingProcessMD5
| order by DeviceCount desc
```

---

## Table: DeviceFileEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicefileevents-table?view=o365-worldwide)

**Description:** File creation, modification, and other file system events

**NOTE:** This table does NOT contain macOS plist modification events. Use `DeviceEvents` with `ActionType == "PlistPropertyModified"` instead.

### Table Schema:
| Field | Description |
| --- | --- |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **AppGuardContainerId** | Identifier for the Application Guard container |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **FileName** | Name of the file |
| **FileOriginIP** | IP address where the file was downloaded from |
| **FileOriginReferrerUrl** | URL of the web page that links to the downloaded file |
| **FileOriginUrl** | URL where the file was downloaded from |
| **FileSize** | Size of the file in bytes |
| **FolderPath** | Folder containing the file |
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
| **IsAzureInfoProtectionApplied** | Indicates whether the file is encrypted by Azure Information Protection |
| **MD5** | MD5 hash of the file |
| **PreviousFileName** | Original name of the file that was renamed |
| **PreviousFolderPath** | Original folder containing the file |
| **ReportId** | Event identifier based on a repeating counter |
| **RequestAccountDomain** | Domain of the account used to remotely initiate the activity |
| **RequestAccountName** | User name of account used to remotely initiate the activity |
| **RequestAccountSid** | SID of the account used to remotely initiate the activity |
| **RequestProtocol** | Network protocol used (Unknown, Local, SMB, NFS) |
| **RequestSourceIP** | IPv4 or IPv6 address of the remote device |
| **RequestSourcePort** | Source port on the remote device |
| **SensitivityLabel** | Label applied to classify content for information protection |
| **SensitivitySubLabel** | Sublabel for information protection |
| **SHA1** | SHA-1 hash of the file |
| **SHA256** | SHA-256 hash of the file |
| **ShareName** | Name of shared folder containing the file |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **FileCreated** | A file was created on the device |
| **FileDeleted** | A file was deleted |
| **FileModified** | A file was modified |
| **FileRenamed** | A file was renamed |

### Examples:

#### Get the list of sensitive files uploaded to a cloud app
```kql
DeviceFileEvents
| where SensitivityLabel in ("Highly Confidential", "Confidential") and Timestamp > ago(1d)
| project FileName, FolderPath, DeviceId, DeviceName, ActionType, SensitivityLabel, Timestamp
| summarize LastTimeSeenOnDevice = max(Timestamp) by FileName, FolderPath, DeviceName, DeviceId, SensitivityLabel
| join (
    CloudAppEvents
    | where ActionType == "FileUploaded" and Timestamp > ago(1d)
    | extend FileName = tostring(RawEventData.SourceFileName)
) on FileName
| project UploadTime = Timestamp, ActionType, Application, FileName, SensitivityLabel, AccountDisplayName, AccountObjectId, IPAddress, CountryCode, LastTimeSeenOnDevice, DeviceName, DeviceId, FolderPath
| limit 100
```

#### Track when a specific file has been copied or moved
```kql
let myFile = '<file SHA1>';
DeviceFileEvents
| where SHA1 == myFile and ActionType == 'FileCreated'
| limit 100
```
