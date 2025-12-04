# MDA/MDI - Apps & Identities

Tables for Microsoft Defender for Cloud Apps (MDA) and Microsoft Defender for Identity (MDI).

## Table: AADSignInEventsBeta

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-aadsignineventsbeta-table?view=o365-worldwide)

**Description:** Information about Azure Active Directory (AAD) sign-in events either by a user (interactive) or a client on the user's behalf (non-interactive)

### Table Schema:
| Field | Description |
| --- | --- |
| **AadDeviceId** | Unique identifier for the device in Azure AD |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountUpn** | User principal name (UPN) of the account |
| **AlternateSignInName** | On-premises user principal name (UPN) of the user signing in to Azure AD |
| **Application** | Application that performed the recorded action |
| **ApplicationId** | Unique identifier for the application |
| **AuthenticationProcessingDetails** | Details about the authentication processor |
| **AuthenticationRequirement** | Type of authentication required for the sign-in (multiFactorAuthentication or singleFactorAuthentication) |
| **Browser** | Details about the version of the browser used to sign in |
| **City** | City where the client IP address is geolocated |
| **ClientAppUsed** | Indicates the client app used |
| **ConditionalAccessPolicies** | Details of the conditional access policies applied to the sign-in event |
| **ConditionalAccessStatus** | Status of the conditional access policies applied to the sign-in (0=applied, 1=failed, 2=not applied) |
| **CorrelationId** | Unique identifier of the sign-in event |
| **Country** | Country/Region where the account user is located |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **DeviceTrustType** | Indicates the trust type of the device (Workplace, AzureAd, ServerAd) |
| **ErrorCode** | Contains the error code if a sign-in error occurs |
| **IPAddress** | IP address assigned to the device during communication |
| **IsCompliant** | Indicates whether the device is compliant |
| **IsExternalUser** | Indicates whether user does not belong to the organization's domain |
| **IsGuestUser** | Indicates whether the user is a guest in the tenant |
| **IsManaged** | Indicates whether the endpoint is managed by Microsoft Defender for Endpoint |
| **LastPasswordChangeTimestamp** | Date and time when the user last changed their password |
| **Latitude** | The north to south coordinates of the sign-in location |
| **LogonType** | Type of logon session (interactive, remote interactive, network, batch, service) |
| **Longitude** | The east to west coordinates of the sign-in location |
| **NetworkLocationDetails** | Network location details of the authentication processor |
| **OSPlatform** | Platform of the operating system running on the device |
| **ReportId** | Unique identifier for the event |
| **RequestId** | Unique identifier of the request |
| **ResourceDisplayName** | Display name of the resource accessed |
| **ResourceId** | Unique identifier of the resource accessed |
| **ResourceTenantId** | Unique identifier of the tenant of the resource accessed |
| **RiskEventTypes** | Array of risk event types applicable to the event |
| **RiskLevelAggregated** | Aggregated risk level during sign-in (0=not set, 1=none, 10=low, 50=medium, 100=high) |
| **RiskLevelDuringSignIn** | User risk level at sign-in |
| **RiskState** | Indicates risky user state (0=none, 1=confirmed safe, 2=remediated, 3=dismissed, 4=at risk, 5=confirmed compromised) |
| **SessionId** | Unique number assigned to a user by a website's server |
| **State** | State where the sign-in occurred |
| **Timestamp** | Date and time when the record was generated |
| **TokenIssuerType** | Indicates if the token issuer is Azure Active Directory (0) or ADFS (1) |
| **UserAgent** | User agent information from the web browser or other client application |

### Examples:

#### Find attempts to sign in to disabled accounts
```kql
let timeRange = 14d;
AADSignInEventsBeta
| where Timestamp >= ago(timeRange)
| where ErrorCode == '50057'  // The user account is disabled
| summarize StartTime = min(Timestamp), EndTime = max(Timestamp), 
    numberAccountsTargeted = dcount(AccountObjectId),
    numberApplicationsTargeted = dcount(ApplicationId), 
    accountSet = make_set(AccountUpn), 
    applicationSet = make_set(Application),
    numberLoginAttempts = count() by IPAddress
| order by numberLoginAttempts desc
```

#### Get users that signed in from multiple locations
```kql
AADSignInEventsBeta
| where Timestamp > ago(1d)
| summarize CountPerCity = dcount(City), citySet = make_set(City) by AccountUpn
| where CountPerCity > 1
| order by CountPerCity desc
```

---

## Table: AADSpnSignInEventsBeta

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-aadspnsignineventsbeta-table?view=o365-worldwide)

**Description:** Information about sign-in events initiated by Azure Active Directory (AAD) service principal or managed identities

### Table Schema:
| Field | Description |
| --- | --- |
| **Application** | Application that performed the recorded action |
| **ApplicationId** | Unique identifier for the application |
| **City** | City where the client IP address is geolocated |
| **CorrelationId** | Unique identifier of the sign-in event |
| **Country** | Country/Region where the account user is located |
| **ErrorCode** | Contains the error code if a sign-in error occurs |
| **IPAddress** | IP address assigned to the device during communication |
| **IsManagedIdentity** | Indicates whether the sign-in was initiated by a managed identity |
| **Latitude** | The north to south coordinates of the sign-in location |
| **Longitude** | The east to west coordinates of the sign-in location |
| **ReportId** | Unique identifier for the event |
| **RequestId** | Unique identifier of the request |
| **ResourceDisplayName** | Display name of the resource accessed |
| **ResourceId** | Unique identifier of the resource accessed |
| **ResourceTenantId** | Unique identifier of the tenant of the resource accessed |
| **ServicePrincipalId** | Unique identifier of the service principal that initiated the sign-in |
| **ServicePrincipalName** | Name of the service principal that initiated the sign-in |
| **State** | State where the sign-in occurred |
| **Timestamp** | Date and time when the record was generated |

### Examples:

#### Get inactive service principals
```kql
AADSpnSignInEventsBeta
| where Timestamp > ago(30d)
| where ErrorCode == 0
| summarize LastSignIn = max(Timestamp) by ServicePrincipalId
| where LastSignIn < ago(10d)
| order by LastSignIn desc
```

#### Get most active managed identities
```kql
AADSpnSignInEventsBeta
| where Timestamp > ago(1d)
| where IsManagedIdentity == True
| summarize CountPerManagedIdentity = count() by ServicePrincipalId
| order by CountPerManagedIdentity desc
| take 100
```

---

## Table: IdentityInfo

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-identityinfo-table?view=o365-worldwide)

**Description:** Account information from various sources, including Azure Active Directory

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountUpn** | User principal name (UPN) of the account |
| **City** | City where the client IP address is geolocated |
| **CloudSid** | Cloud security identifier of the account |
| **Country** | Country/Region where the account user is located |
| **Department** | Name of the department that the account user belongs to |
| **EmailAddress** | SMTP address of the account |
| **GivenName** | Given name or first name of the account user |
| **IsAccountEnabled** | Indicates whether the account is enabled or not |
| **JobTitle** | Job title of the account user |
| **OnPremSid** | On-premises security identifier (SID) of the account |
| **SipProxyAddress** | Voice of over IP (VOIP) session initiation protocol (SIP) address |
| **Surname** | Surname, family name, or last name of the account user |

### Examples:

#### List all users in a specific department
```kql
let MyDepartment = "<insert your department>";
IdentityInfo
| where Department == MyDepartment
| summarize by AccountObjectId, AccountUpn
```

#### List all users located in a particular country
```kql
let MyCountry = "<insert your country>";
IdentityInfo
| where Country == MyCountry
| summarize by AccountObjectId, AccountUpn
```

---

## Table: IdentityLogonEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-identitylogonevents-table?view=o365-worldwide)

**Description:** Authentication events recorded by Active Directory and other Microsoft online services

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountSid** | Security Identifier (SID) of the account |
| **AccountUpn** | User principal name (UPN) of the account |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **Application** | Application that performed the recorded action |
| **DestinationDeviceName** | Name of the device running the server application |
| **DestinationIPAddress** | IP address of the device running the server application |
| **DestinationPort** | Destination port of the activity |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **DeviceType** | Type of device based on purpose and functionality |
| **FailureReason** | Information explaining why the recorded action failed |
| **IPAddress** | IP address assigned to the device during communication |
| **ISP** | Internet service provider associated with the IP address |
| **Location** | City, country, or other geographic location associated with the event |
| **LogonType** | Type of logon session (interactive, remote interactive, network, batch, service) |
| **OSPlatform** | Platform of the operating system running on the device |
| **Port** | TCP port used during communication |
| **Protocol** | Protocol used during the communication |
| **ReportId** | Unique identifier for the event |
| **TargetAccountDisplayName** | Display name of the account that the recorded action was applied to |
| **TargetDeviceName** | FQDN of the device that the recorded action was applied to |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **LogonFailed** | A user attempted to logon to the device but failed |
| **LogonSuccess** | A user successfully logged on to the device |

### Examples:

#### Find LDAP authentication attempts using cleartext passwords
```kql
IdentityLogonEvents
| where Timestamp > ago(7d)
| where Protocol == "LDAP"
| project LogonTime = Timestamp, DeviceName, Application, ActionType, LogonType
| join kind=inner (
    DeviceNetworkEvents
    | where Timestamp > ago(7d)
    | where ActionType == "ConnectionSuccess"
    | extend DeviceName = toupper(trim(@"\..*$", DeviceName))
    | where RemotePort == "389"
    | project NetworkConnectionTime = Timestamp, DeviceName, AccountName = InitiatingProcessAccountName, InitiatingProcessFileName, InitiatingProcessCommandLine
) on DeviceName
| where LogonTime - NetworkConnectionTime between (-2m .. 2m)
| project Application, LogonType, ActionType, LogonTime, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine
```

---

## Table: IdentityQueryEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-identityqueryevents-table?view=o365-worldwide)

**Description:** Query activities performed against Active Directory objects, such as users, groups, devices, and domains

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountSid** | Security Identifier (SID) of the account |
| **AccountUpn** | User principal name (UPN) of the account |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **Application** | Application that performed the recorded action |
| **DestinationDeviceName** | Name of the device running the server application |
| **DestinationIPAddress** | IP address of the device running the server application |
| **DestinationPort** | Destination port of the activity |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **IPAddress** | IP address assigned to the device during communication |
| **Location** | City, country, or other geographic location associated with the event |
| **Port** | TCP port used during communication |
| **Protocol** | Protocol used during the communication |
| **Query** | String used to run the query |
| **QueryTarget** | User, group, domain, or any other entity being queried |
| **QueryType** | Type of the query |
| **ReportId** | Unique identifier for the event |
| **TargetAccountDisplayName** | Display name of the account that the recorded action was applied to |
| **TargetAccountUpn** | UPN of the account that the recorded action was applied to |
| **TargetDeviceName** | FQDN of the device that the recorded action was applied to |
| **Timestamp** | Date and time when the record was generated |

### ActionTypes:
| ActionType | Description |
| --- | --- |
| **DNS query** | Type of query user performed against the domain controller (AXFR, TXT, MX, NS, SRV, ANY, DNSKEY) |
| **LDAP query** | An LDAP query was performed |
| **LdapQuery** | An LDAP query was performed |
| **SAMR query** | A SAMR query was performed |

### Examples:

#### Find use of net.exe to send SAMR queries to Active Directory
```kql
IdentityQueryEvents
| where Timestamp > ago(3d)
| where ActionType == "SAMR query"
| project QueryTime = Timestamp, DeviceName, AccountName, Query, QueryTarget
| join kind=inner (
    DeviceProcessEvents
    | where Timestamp > ago(3d)
    | extend DeviceName = toupper(trim(@"\..*$", DeviceName))
    | project ProcessCreationTime = Timestamp, DeviceName, AccountName, InitiatingProcessFileName, InitiatingProcessCommandLine
) on DeviceName
| where ProcessCreationTime - QueryTime between (-2m .. 2m)
| project QueryTime, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine, Query, QueryTarget
```

---

## Table: IdentityDirectoryEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-identitydirectoryevents-table?view=o365-worldwide)

**Description:** Events involving a domain controller or a directory service, such as Active Directory (AD) or Azure AD

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountDomain** | Domain of the account |
| **AccountName** | User name of the account |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountSid** | Security Identifier (SID) of the account |
| **AccountUpn** | User principal name (UPN) of the account |
| **ActionType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **Application** | Application that performed the recorded action |
| **DestinationDeviceName** | Name of the device running the server application |
| **DestinationIPAddress** | IP address of the device running the server application |
| **DestinationPort** | Destination port of the activity |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **IPAddress** | IP address assigned to the device during communication |
| **ISP** | Internet service provider associated with the IP address |
| **Location** | City, country, or other geographic location associated with the event |
| **Port** | TCP port used during communication |
| **Protocol** | Protocol used during the communication |
| **ReportId** | Unique identifier for the event |
| **TargetAccountDisplayName** | Display name of the account that the recorded action was applied to |
| **TargetAccountUpn** | UPN of the account that the recorded action was applied to |
| **TargetDeviceName** | FQDN of the device that the recorded action was applied to |
| **Timestamp** | Date and time when the record was generated |

### Key ActionTypes:
| ActionType | Description |
| --- | --- |
| **Account Password changed** | User changed their password |
| **Account Password expired** | User's password expired |
| **Group Membership changed** | User was added/removed to/from a group |
| **Security Principal created** | Account was created (both user and computer) |
| **Directory Service replication** | User tried to replicate the directory service |
| **PowerShell execution** | User attempted to remotely execute a PowerShell command |
| **Potential lateral movement path identified** | Identified potential lateral movement path to a sensitive user |

### Examples:

#### Find the latest password change event for a specific account
```kql
let userAccount = '<insert your user account>';
IdentityDirectoryEvents
| where ActionType == 'Account Password changed'
| where TargetAccountDisplayName == userAccount
| summarize LastPasswordChangeTime = max(Timestamp) by TargetAccountDisplayName
```

#### List changes made to a specific group
```kql
let group = '<insert your group>';
IdentityDirectoryEvents
| where ActionType == 'Group Membership changed'
| extend AddedToGroup = AdditionalFields['TO.GROUP']
| extend RemovedFromGroup = AdditionalFields['FROM.GROUP']
| extend TargetAccount = AdditionalFields['TARGET_OBJECT.USER']
| where AddedToGroup == group or RemovedFromGroup == group
| project-reorder Timestamp, ActionType, AddedToGroup, RemovedFromGroup, TargetAccount
| limit 100
```

---

## Table: CloudAppEvents

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-cloudappevents-table?view=o365-worldwide)

**Description:** Events involving accounts and objects in Office 365 and other cloud apps and services

### Table Schema:
| Field | Description |
| --- | --- |
| **AccountDisplayName** | Name displayed in the address book entry for the account user |
| **AccountId** | An identifier for the account as found by Microsoft Cloud App Security |
| **AccountObjectId** | Unique identifier for the account in Azure AD |
| **AccountType** | Type of user account (Regular, System, Admin, Application) |
| **ActionType** | Type of activity that triggered the event |
| **ActivityObjects** | List of objects involved in the recorded activity |
| **ActivityType** | Type of activity that triggered the event |
| **AdditionalFields** | Additional information about the entity or event |
| **AppInstanceId** | Unique identifier for the instance of an application |
| **Application** | Application that performed the recorded action |
| **ApplicationId** | Unique identifier for the application |
| **City** | City where the client IP address is geolocated |
| **CountryCode** | Two-letter code indicating the country |
| **DeviceType** | Type of device based on purpose and functionality |
| **IPAddress** | IP address assigned to the device during communication |
| **IPCategory** | Additional information about the IP address |
| **IPTags** | Customer-defined information applied to specific IP addresses |
| **IsAdminOperation** | Indicates whether the activity was performed by an administrator |
| **IsAnonymousProxy** | Indicates whether the IP address belongs to a known anonymous proxy |
| **IsExternalUser** | Indicates whether user does not belong to the organization's domain |
| **IsImpersonated** | Indicates whether the activity was performed on behalf of another user |
| **ISP** | Internet service provider associated with the IP address |
| **ObjectId** | Unique identifier of the object that the recorded action was applied to |
| **ObjectName** | Name of the object that the recorded action was applied to |
| **ObjectType** | The type of object (file, folder, etc.) |
| **OSPlatform** | Platform of the operating system running on the device |
| **RawEventData** | Raw event information from the source application in JSON format |
| **ReportId** | Unique identifier for the event |
| **Timestamp** | Date and time when the record was generated |
| **UserAgent** | User agent information from the web browser or other client application |
| **UserAgentTags** | More information provided by Microsoft Cloud App Security |

### Examples:

#### Find applications that renamed .docx files to .doc
```kql
CloudAppEvents
| where Timestamp > ago(3d)
| where Application in ("Microsoft OneDrive for Business", "Microsoft SharePoint Online") and ActionType == "FileRenamed"
| extend NewFileNameExtension = tostring(RawEventData.DestinationFileExtension)
| extend OldFileNameExtension = tostring(RawEventData.SourceFileExtension)
| extend OldFileName = tostring(RawEventData.SourceFileName)
| extend NewFileName = tostring(RawEventData.DestinationFileName)
| where NewFileNameExtension == "doc" and OldFileNameExtension == "docx"
| project RenameTime = Timestamp, OldFileNameExtension, OldFileName, NewFileNameExtension, NewFileName, ActionType, Application, AccountDisplayName, AccountObjectId
```

#### Get a list of sharing activities in cloud apps
```kql
CloudAppEvents
| where ActivityType == "Share"
| take 100
```
