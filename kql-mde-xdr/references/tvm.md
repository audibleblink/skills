# TVM - Threat & Vulnerability Management

Tables for Microsoft Defender Vulnerability Management (TVM).

## Table: DeviceTvmSoftwareInventory

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsoftwareinventory-table?view=o365-worldwide)

**Description:** Inventory of software installed on devices, including their version information and end-of-support status

### Table Schema:
| Field | Description |
| --- | --- |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **EndOfSupportDate** | End-of-support (EOS) or end-of-life (EOL) date of the software product |
| **EndOfSupportStatus** | Indicates the lifecycle stage of the software product |
| **OSArchitecture** | Architecture of the operating system |
| **OSPlatform** | Platform of the operating system |
| **OSVersion** | Version of the operating system |
| **ProductCodeCpe** | The standard Common Platform Enumeration (CPE) name |
| **SoftwareName** | Name of the software product |
| **SoftwareVendor** | Name of the software vendor |
| **SoftwareVersion** | Version number of the software product |

### Examples:

#### List software titles which are not supported anymore
```kql
DeviceTvmSoftwareInventory
| where EndOfSupportStatus == 'EOS Software'
| summarize dcount(DeviceId) by SoftwareName
```

---

## Table: DeviceTvmSoftwareVulnerabilities

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsoftwarevulnerabilities-table?view=o365-worldwide)

**Description:** Software vulnerabilities found on devices and the list of available security updates that address each vulnerability

### Table Schema:
| Field | Description |
| --- | --- |
| **CveId** | Unique identifier assigned to the security vulnerability (CVE) |
| **CveMitigationStatus** | Status of the workaround mitigation for the CVE |
| **CveTags** | Array of tags relevant to the CVE (ZeroDay, NoSecurityUpdate) |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **OSArchitecture** | Architecture of the operating system |
| **OSPlatform** | Platform of the operating system |
| **OSVersion** | Version of the operating system |
| **RecommendedSecurityUpdate** | Name or description of the security update |
| **RecommendedSecurityUpdateId** | Identifier of the applicable security updates or KB articles |
| **SoftwareName** | Name of the software product |
| **SoftwareVendor** | Name of the software vendor |
| **SoftwareVersion** | Version number of the software product |
| **VulnerabilitySeverityLevel** | Severity level assigned to the vulnerability |

### Examples:

#### List devices affected by a specific vulnerability
```kql
DeviceTvmSoftwareVulnerabilities
| where CveId == 'CVE-2020-0791'
| limit 100
```

---

## Table: DeviceTvmSoftwareVulnerabilitiesKB

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsoftwarevulnerabilitieskb-table?view=o365-worldwide)

**Description:** Knowledge base of publicly disclosed vulnerabilities, including whether exploit code is publicly available

### Table Schema:
| Field | Description |
| --- | --- |
| **AffectedSoftware** | List of all software products affected by the vulnerability |
| **CveId** | Unique identifier assigned to the security vulnerability (CVE) |
| **CvssScore** | Severity score assigned under the CVSS |
| **IsExploitAvailable** | Indicates whether exploit code is publicly available |
| **LastModifiedTime** | Date and time the item was last modified |
| **PublishedDate** | Date vulnerability was disclosed to the public |
| **VulnerabilityDescription** | Description of the vulnerability and associated risks |
| **VulnerabilitySeverityLevel** | Severity level assigned to the vulnerability |

### Examples:

#### Get all information on a specific vulnerability
```kql
DeviceTvmSoftwareVulnerabilitiesKB
| where CveId == 'CVE-2020-0791'
```

#### List vulnerabilities with available exploits published in the last week
```kql
DeviceTvmSoftwareVulnerabilitiesKB
| where IsExploitAvailable == True and PublishedDate > ago(7d)
| limit 100
```

---

## Table: DeviceTvmSecureConfigurationAssessment

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsecureconfigurationassessment-table?view=o365-worldwide)

**Description:** Threat & Vulnerability Management assessment events, indicating the status of various security configurations on devices

### Table Schema:
| Field | Description |
| --- | --- |
| **ConfigurationCategory** | Category or grouping to which the configuration belongs |
| **ConfigurationId** | Unique identifier for a specific configuration |
| **ConfigurationImpact** | Rated impact of the configuration to the overall configuration score (1-10) |
| **ConfigurationSubcategory** | Subcategory or subgrouping to which the configuration belongs |
| **Context** | Configuration context data of the machine |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **IsApplicable** | Indicates whether the configuration or policy is applicable |
| **IsCompliant** | Indicates whether the configuration or policy is properly configured |
| **IsExpectedUserImpact** | Indicates whether there will be user impact if the configuration is applied |
| **OSPlatform** | Platform of the operating system |
| **Timestamp** | Date and time when the record was generated |

---

## Table: DeviceTvmSecureConfigurationAssessmentKB

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsecureconfigurationassessmentkb-table?view=o365-worldwide)

**Description:** Knowledge base of various security configurations used by Threat & Vulnerability Management to assess devices; includes mappings to various standards and benchmarks

### Table Schema:
| Field | Description |
| --- | --- |
| **ConfigurationBenchmarks** | List of industry benchmarks recommending the configuration |
| **ConfigurationCategory** | Category or grouping to which the configuration belongs |
| **ConfigurationDescription** | Description of the configuration |
| **ConfigurationId** | Unique identifier for a specific configuration |
| **ConfigurationImpact** | Rated impact of the configuration (1-10) |
| **ConfigurationName** | Display name of the configuration |
| **ConfigurationSubcategory** | Subcategory or subgrouping |
| **RemediationOptions** | Recommended actions to reduce or address associated risks |
| **RiskDescription** | Description of any associated risks |
| **Tags** | Labels representing various attributes |

---

## Table: DeviceTvmInfoGathering

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvminfogathering-table?view=o365-worldwide)

**Description:** The DeviceTvmInfoGathering table contains Threat & Vulnerability Management assessment events including the status of various configurations and attack surface area states of devices

### Table Schema:
| Field | Description |
| --- | --- |
| **AdditionalFields** | Additional information about the entity or event |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **LastSeenTime** | Date and time when the service last saw the device |
| **OSPlatform** | Platform of the operating system |
| **Timestamp** | Date and time when the record was generated |

---

## Table: DeviceTvmInfoGatheringKB

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvminfogatheringkb-table?view=o365-worldwide)

**Description:** The DeviceTvmInfoGatheringKB table contains the list of various configuration and attack surface area assessments used by Threat & Vulnerability Management

### Table Schema:
| Field | Description |
| --- | --- |
| **Categories** | List of categories that the information belongs to (JSON array) |
| **DataStructure** | The data structure of the information gathered |
| **Description** | Description of the information gathered |
| **FieldName** | Name of the field in the AdditionalFields column |
| **IgId** | Unique identifier for the piece of information gathered |

---

## Table: DeviceTvmSoftwareEvidenceBeta

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmsoftwareevidencebeta-table?view=o365-worldwide)

**Description:** Evidence indicating the existence of a software on a device based on registry paths, disk paths, or both

### Table Schema:
| Field | Description |
| --- | --- |
| **DeviceId** | Unique identifier for the device in the service |
| **DiskPaths** | Disk paths on which file level evidence was detected |
| **LastSeenTime** | Date and time when the service last saw the device |
| **RegistryPaths** | Registry paths on which evidence was detected |
| **SoftwareName** | Name of the software product |
| **SoftwareVendor** | Name of the software vendor |
| **SoftwareVersion** | Version number of the software product |

---

## Table: DeviceBaselineComplianceAssessment

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicebaselinecomplianceassessment-table?view=o365-worldwide)

**Description:** Baseline compliance assessment snapshot, indicating the status of various security configurations related to baseline profiles on devices

### Table Schema:
| Field | Description |
| --- | --- |
| **ConfigurationId** | Unique identifier for a specific configuration |
| **CurrentValue** | Set of detected values found on the device |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **IsApplicable** | Indicates whether the configuration or policy is applicable |
| **IsCompliant** | Indicates whether the device is compliant |
| **IsExempt** | Indicates whether the device is exempt from baseline configuration |
| **OSPlatform** | Platform of the operating system |
| **OSVersion** | Version of the operating system |
| **ProfileId** | Unique identifier for the profile |
| **RecommendedValue** | Set of expected values for the device setting to be compliant |
| **Source** | The registry path or other location used to determine the current device setting |

---

## Table: DeviceBaselineComplianceAssessmentKB

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicebaselinecomplianceassessmentkb-table?view=o365-worldwide)

**Description:** Knowledge base of various security configurations used by baseline compliance to assess devices

---

## Table: DeviceBaselineComplianceProfiles

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicebaselinecomplianceprofiles-table?view=o365-worldwide)

**Description:** Baseline profiles used for monitoring device baseline compliance

---

## Table: DeviceTvmCertificateInfo

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmcertificateinfo-table?view=o365-worldwide)

**Description:** Certificate information for devices in the organization

### Table Schema:
| Field | Description |
| --- | --- |
| **DeviceId** | Unique identifier for the device in the service |
| **ExpirationDate** | The date and time beyond which the certificate is no longer valid |
| **ExtendedKeyUsage** | Other valid uses for the certificate |
| **FriendlyName** | Easy-to-understand version of a certificate's title |
| **IssueDate** | The earliest date and time when the certificate became valid |
| **IssuedBy** | Entity that verified the information and signed the certificate |
| **IssuedTo** | Entity that a certificate belongs to |
| **KeySize** | Size of the key used in the signature algorithm |
| **KeyUsage** | The valid cryptographic uses of the certificate's public key |
| **Path** | The location of the certificate |
| **SerialNumber** | Unique identifier for the certificate |
| **SignatureAlgorithm** | Hashing algorithm and encryption algorithm used |
| **SubjectType** | Indicates if the holder of the certificate is a CA or end entity |
| **Thumbprint** | Unique identifier for the certificate |

---

## Table: DeviceTvmBrowserExtensions

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmbrowserextensions-table?view=o365-worldwide)

**Description:** Browser extension installations found on devices as shown in Threat & Vulnerability Management

### Table Schema:
| Field | Description |
| --- | --- |
| **BrowserName** | Name of the web browser with the extension |
| **DeviceId** | Unique identifier for the device in the service |
| **ExtensionDescription** | Description from the publisher about the extension |
| **ExtensionId** | Unique identifier for the browser extension |
| **ExtensionName** | Name of the extension |
| **ExtensionRisk** | Risk level for the extension based on permissions requested |
| **ExtensionVendor** | Name of the vendor offering the extension |
| **ExtensionVersion** | Version number of the extension |
| **InstallationTime** | Date and time when the browser extension was first installed |
| **IsActivated** | Whether the extension is turned on or off |

---

## Table: DeviceTvmBrowserExtensionsKB

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmbrowserextensionskb-table?view=o365-worldwide)

**Description:** Knowledge base of browser extension details and permission information used in the Threat & Vulnerability Management browser extensions page

---

## Table: DeviceTvmHardwareFirmware

[Link to Microsoft](https://learn.microsoft.com/en-us/microsoft-365/security/defender/advanced-hunting-devicetvmhardwarefirmware-table?view=o365-worldwide)

**Description:** The DeviceTvmHardwareFirmware table holds information about device hardware and firmware (system model, processor, BIOS, chipset, TPM, Intel ME, etc.)

### Table Schema:
| Field | Description |
| --- | --- |
| **AdditionalFields** | Additional information about the entity or event |
| **ComponentFamily** | Component family or class |
| **ComponentName** | Name of hardware or firmware component |
| **ComponentType** | Type of hardware or firmware component |
| **ComponentVersion** | Component version (e.g., BIOS version) |
| **DeviceId** | Unique identifier for the device in the service |
| **DeviceName** | Fully qualified domain name (FQDN) of the device |
| **Manufacturer** | Manufacturer of hardware or firmware component |

### Examples:

#### Count the number of Lenovo devices
```kql
DeviceTvmHardwareFirmware
| where ComponentType == 'Hardware' and Manufacturer == 'lenovo'
| summarize count()
```

#### Find all devices with specific BIOS version
```kql
DeviceTvmHardwareFirmware
| where ComponentType == 'Bios' and ComponentVersion contains '<insert a BIOS version>'
| project DeviceId, DeviceName
```
