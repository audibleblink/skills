#!/usr/bin/env python3
"""Grade kql-mde-xdr eval outputs against assertions."""

import json
import re
import os


def read(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        return ""


def grade_macos_persistence(query_text, variant):
    assertions = []

    # 1. Uses DeviceEvents (not DeviceFileEvents)
    uses_device_events = (
        "DeviceEvents" in query_text
        and "DeviceFileEvents"
        not in query_text.replace("// NOT DeviceFileEvents", "").split("DeviceEvents")[
            0
        ]
    )
    # More precise: primary table should be DeviceEvents
    primary_table_correct = bool(
        re.search(r"\bDeviceEvents\b", query_text)
    ) and not bool(re.search(r"^DeviceFileEvents", query_text.strip()))
    assertions.append(
        {
            "text": "Uses DeviceEvents (not DeviceFileEvents) as primary table for plist events",
            "passed": "DeviceEvents" in query_text
            and "PlistPropertyModified" in query_text,
            "evidence": f"DeviceEvents in query: {'DeviceEvents' in query_text}, PlistPropertyModified in query: {'PlistPropertyModified' in query_text}",
        }
    )

    # 2. ActionType == PlistPropertyModified
    assertions.append(
        {
            "text": "Filters on ActionType == PlistPropertyModified",
            "passed": "PlistPropertyModified" in query_text,
            "evidence": f"Found 'PlistPropertyModified': {'PlistPropertyModified' in query_text}",
        }
    )

    # 3. Platform-filters macOS via DeviceInfo join/let (not OSPlatform on DeviceEvents)
    uses_deviceinfo_for_platform = (
        "DeviceInfo" in query_text and "OSPlatform" in query_text
    )
    bad_platform_filter = bool(
        re.search(r"DeviceEvents\s*\|[^|]*OSPlatform", query_text.replace("\n", " "))
    )
    assertions.append(
        {
            "text": "Filters to macOS via DeviceInfo lookup (not direct OSPlatform on event table)",
            "passed": uses_deviceinfo_for_platform and not bad_platform_filter,
            "evidence": f"Uses DeviceInfo+OSPlatform: {uses_deviceinfo_for_platform}, Bad direct filter: {bad_platform_filter}",
        }
    )

    # 4. Projects plist path
    assertions.append(
        {
            "text": "Projects plist path from AdditionalFields",
            "passed": "PlistDetails" in query_text or "AdditionalFields" in query_text,
            "evidence": f"AdditionalFields/PlistDetails present: {'AdditionalFields' in query_text or 'PlistDetails' in query_text}",
        }
    )

    # 5. Projects property name and value
    assertions.append(
        {
            "text": "Projects modified property name and value",
            "passed": "PropertyName" in query_text and "PropertyValue" in query_text,
            "evidence": f"PropertyName: {'PropertyName' in query_text}, PropertyValue: {'PropertyValue' in query_text}",
        }
    )

    # 6. Projects initiating process info
    assertions.append(
        {
            "text": "Projects initiating process details (who made the change)",
            "passed": "InitiatingProcessFileName" in query_text,
            "evidence": f"InitiatingProcessFileName present: {'InitiatingProcessFileName' in query_text}",
        }
    )

    return assertions


def grade_credential_dumping(query_text, variant):
    assertions = []

    # 1. Covers LSASS (T1003.001)
    covers_lsass = "lsass" in query_text.lower()
    assertions.append(
        {
            "text": "Covers LSASS memory access (T1003.001)",
            "passed": covers_lsass,
            "evidence": f"'lsass' found in query: {covers_lsass}",
        }
    )

    # 2. Covers SAM (T1003.002)
    covers_sam = (
        bool(re.search(r"\bsam\b", query_text, re.IGNORECASE)) or "SAM" in query_text
    )
    assertions.append(
        {
            "text": "Covers SAM database dump (T1003.002)",
            "passed": covers_sam,
            "evidence": f"SAM reference found: {covers_sam}",
        }
    )

    # 3. Covers NTDS (T1003.003)
    covers_ntds = "ntds" in query_text.lower()
    assertions.append(
        {
            "text": "Covers NTDS.dit access (T1003.003)",
            "passed": covers_ntds,
            "evidence": f"'ntds' found in query: {covers_ntds}",
        }
    )

    # 4. Projects DeviceName
    assertions.append(
        {
            "text": "Projects DeviceName in output",
            "passed": "DeviceName" in query_text,
            "evidence": f"DeviceName in query: {'DeviceName' in query_text}",
        }
    )

    # 5. Projects AccountName
    assertions.append(
        {
            "text": "Projects AccountName in output",
            "passed": "AccountName" in query_text,
            "evidence": f"AccountName in query: {'AccountName' in query_text}",
        }
    )

    # 6. Projects command line
    assertions.append(
        {
            "text": "Projects command line in output",
            "passed": "CommandLine" in query_text or "ProcessCommandLine" in query_text,
            "evidence": f"CommandLine/ProcessCommandLine in query: {'CommandLine' in query_text or 'ProcessCommandLine' in query_text}",
        }
    )

    # 7. Uses OpenProcessApiCall for LSASS (skill-specific knowledge from devices-security.md)
    uses_open_process = "OpenProcessApiCall" in query_text
    assertions.append(
        {
            "text": "Uses OpenProcessApiCall ActionType for LSASS access detection (skill-specific)",
            "passed": uses_open_process,
            "evidence": f"OpenProcessApiCall present: {uses_open_process}",
        }
    )

    # 8. Uses has over contains for performance (skill guidance)
    uses_has = (
        " has " in query_text or "has_any" in query_text or "has_all" in query_text
    )
    uses_contains = " contains " in query_text
    assertions.append(
        {
            "text": "Prefers 'has' operator over 'contains' for performance",
            "passed": uses_has and not uses_contains,
            "evidence": f"has/has_any present: {uses_has}, contains present: {uses_contains}",
        }
    )

    return assertions


def grade_ioc_pivot(query_text, variant):
    assertions = []

    # 1. Searches DeviceNetworkEvents by RemoteIP
    assertions.append(
        {
            "text": "Searches DeviceNetworkEvents for the IP as RemoteIP",
            "passed": "DeviceNetworkEvents" in query_text and "RemoteIP" in query_text,
            "evidence": f"DeviceNetworkEvents: {'DeviceNetworkEvents' in query_text}, RemoteIP: {'RemoteIP' in query_text}",
        }
    )

    # 2. Searches AlertEvidence
    assertions.append(
        {
            "text": "Pivots through AlertEvidence for related alerts",
            "passed": "AlertEvidence" in query_text,
            "evidence": f"AlertEvidence in query: {'AlertEvidence' in query_text}",
        }
    )

    # 3. Joins AlertInfo for alert details
    assertions.append(
        {
            "text": "Joins AlertInfo to surface alert titles/severity",
            "passed": "AlertInfo" in query_text,
            "evidence": f"AlertInfo in query: {'AlertInfo' in query_text}",
        }
    )

    # 4. Surfaces user accounts
    assertions.append(
        {
            "text": "Surfaces user accounts involved with the IP",
            "passed": "AccountName" in query_text,
            "evidence": f"AccountName in query: {'AccountName' in query_text}",
        }
    )

    # 5. Uses FileOriginIP for file downloads (skill-specific field knowledge)
    uses_file_origin = "FileOriginIP" in query_text
    assertions.append(
        {
            "text": "Uses FileOriginIP in DeviceFileEvents to catch downloads from IP (skill-specific)",
            "passed": uses_file_origin,
            "evidence": f"FileOriginIP present: {uses_file_origin}",
        }
    )

    # 6. Uses materialize() for performance on reused sub-queries
    uses_materialize = "materialize" in query_text
    assertions.append(
        {
            "text": "Uses materialize() for performance on reused sub-queries",
            "passed": uses_materialize,
            "evidence": f"materialize() present: {uses_materialize}",
        }
    )

    # 7. Has time filter
    has_time_filter = "ago(" in query_text
    assertions.append(
        {
            "text": "Includes a time filter",
            "passed": has_time_filter,
            "evidence": f"ago() time filter present: {has_time_filter}",
        }
    )

    # 8. Produces unified/correlated result set
    assertions.append(
        {
            "text": "Correlates results into a unified output (uses union or single result)",
            "passed": "union" in query_text.lower() or "join" in query_text.lower(),
            "evidence": f"union/join present: {'union' in query_text.lower() or 'join' in query_text.lower()}",
        }
    )

    return assertions


BASE = "/Users/blink/Code/skills/kql-mde-xdr-workspace/iteration-1"
evals = [
    ("eval-macos-persistence", grade_macos_persistence),
    ("eval-credential-dumping", grade_credential_dumping),
    ("eval-ioc-pivot", grade_ioc_pivot),
]
variants = ["with_skill", "without_skill"]

results = {}

for eval_dir, grade_fn in evals:
    for variant in variants:
        query_path = f"{BASE}/{eval_dir}/{variant}/outputs/query.kql"
        query_text = read(query_path)
        if not query_text:
            print(f"WARNING: No query at {query_path}")
            continue

        assertions = grade_fn(query_text, variant)
        passed = sum(1 for a in assertions if a["passed"])
        total = len(assertions)
        pass_rate = passed / total if total else 0

        grading = {
            "eval_name": eval_dir,
            "variant": variant,
            "pass_rate": pass_rate,
            "passed": passed,
            "total": total,
            "expectations": assertions,
        }

        out_path = f"{BASE}/{eval_dir}/{variant}/grading.json"
        with open(out_path, "w") as f:
            json.dump(grading, f, indent=2)

        results[f"{eval_dir}/{variant}"] = grading
        print(f"{eval_dir}/{variant}: {passed}/{total} ({pass_rate:.0%})")

# Print summary
print("\n=== SUMMARY ===")
for key, g in results.items():
    print(f"{key}: {g['passed']}/{g['total']} ({g['pass_rate']:.0%})")
