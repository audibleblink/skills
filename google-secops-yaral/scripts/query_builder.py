#!/usr/bin/env python3
"""
YARAL Query Builder Examples

This module demonstrates how to construct YARAL queries programmatically.
Use these patterns as templates for your threat hunting workflows.
"""

from dataclasses import dataclass
from typing import List, Optional
from enum import Enum


class Port(Enum):
    """Common network ports"""
    HTTP = 80
    HTTPS = 443
    DNS = 53
    KERBEROS = 88
    LDAP = 389
    NTP = 123
    SMTP = 25


class TimeUnit(Enum):
    """Time units for YARAL queries"""
    SECONDS = "s"
    MINUTES = "m"
    HOURS = "h"
    DAYS = "d"


@dataclass
class TimeWindow:
    """Represents a time window for correlation"""
    value: int
    unit: TimeUnit

    def __str__(self) -> str:
        return f"{self.value}{self.unit.value}"


class YARALQueryBuilder:
    """Helper to construct YARAL queries for common threat hunting scenarios"""

    @staticmethod
    def network_from_application(
        app_names: List[str],
        exclude_system_users: bool = True,
        within_seconds: int = 10,
    ) -> str:
        """
        Build a query to find network connections from a specific application.

        Args:
            app_names: List of executable names (e.g., ["chrome.exe", "firefox.exe"])
            exclude_system_users: If True, filter out SYSTEM user processes
            within_seconds: Window in seconds to capture network connections

        Returns:
            YARAL query string
        """
        app_list = ', '.join([f'"{app}"' for app in app_names])
        system_filter = '| process.user.user_name != "SYSTEM"\n' if exclude_system_users else ""

        query = f'''process
| process.name in [{app_list}]
{system_filter}| process.image_file.path.startsWith("C:\\\\\\\\Program Files")
  or process.image_file.path.startsWith("C:\\\\\\\\Users")
| within {within_seconds}s: network_connection
  // All network connections from {', '.join(app_names)} within {within_seconds} seconds'''

        return query

    @staticmethod
    def multi_destination_beaconing(
        min_unique_destinations: int = 5,
        time_window: TimeWindow = TimeWindow(2, TimeUnit.MINUTES),
        exclude_standard_ports: bool = True,
    ) -> str:
        """
        Build a query to detect processes connecting to multiple distinct IPs.

        Args:
            min_unique_destinations: Minimum number of unique destination IPs
            time_window: Time window for correlation
            exclude_standard_ports: If True, exclude port 80/443 (standard web traffic)

        Returns:
            YARAL query string
        """
        port_filter = '| min(nc.dst_port) != 443 and max(nc.dst_port) != 80\n  // Non-standard ports suggest C2\n' if exclude_standard_ports else ""

        query = f'''process
| process.ppid != 0
| process.image_file.path.startsWith("C:\\\\\\\\Users")
  or process.image_file.path.startsWith("C:\\\\\\\\Temp")
| within {time_window}: network_connection as nc
| count(distinct nc.dst_ipv4) >= {min_unique_destinations}
{port_filter}'''

        return query

    @staticmethod
    def multi_parent_child_network(
        min_parent_count: int = 2,
        child_time_window: TimeWindow = TimeWindow(10, TimeUnit.SECONDS),
    ) -> str:
        """
        Build a query to detect child processes spawned by multiple parents
        with network connections.

        Args:
            min_parent_count: Minimum number of different parent processes
            child_time_window: Time window for child network activity

        Returns:
            YARAL query string
        """
        query = f'''process as child_process
| child_process.ppid != 0
| child_process.image_file.path.startsWith("C:\\\\\\\\Users")
| child_process.user.user_name != "SYSTEM"
| within {child_time_window}: network_connection as nc
  where nc.process_id == child_process.pid
  and nc.dst_port not in [80, 443, 53]
    // Non-standard ports (exclude web/DNS)
| any_of(process as parent) where
    parent.pid == child_process.ppid
    and count(distinct parent.ppid) >= {min_parent_count}
    // Same child spawned by multiple parents'''

        return query

    @staticmethod
    def suspicious_child_from_office_app() -> str:
        """
        Build a query to detect unusual child processes from Office/user apps
        with network connections.

        Returns:
            YARAL query string
        """
        query = '''process as parent
| parent.name in ["explorer.exe", "notepad.exe", "mspaint.exe", "winword.exe", "excel.exe"]
  // Office/user apps spawning system tools
| childprocess
| childprocess.name in ["powershell.exe", "cmd.exe", "certutil.exe", "bitsadmin.exe"]
| within 2s: network_connection
  where network_connection.process_id == childprocess.pid
  and network_connection.dst_port not in [80, 443, 53]
    // Non-standard port suggests C2, not normal update/web traffic'''

        return query

    @staticmethod
    def geographic_beaconing(
        min_countries: int = 3,
        time_window: TimeWindow = TimeWindow(5, TimeUnit.MINUTES),
    ) -> str:
        """
        Build a query to detect connections to multiple countries (geographic beaconing).

        Args:
            min_countries: Minimum number of distinct countries
            time_window: Time window for correlation

        Returns:
            YARAL query string
        """
        query = f'''process
| process.ppid != 0
| process.user.user_name != "SYSTEM"
| process.name not in ["chrome.exe", "firefox.exe", "msedge.exe", "teams.exe"]
| within {time_window}: network_connection as nc
| count(distinct getCountry(nc.dst_ipv4)) >= {min_countries}
  // Connections to {min_countries}+ countries is unusual and suggests C2'''

        return query


if __name__ == "__main__":
    # Example usage: Generate common queries
    builder = YARALQueryBuilder()

    print("\n=== Query 1: Network from Specific App ===")
    print(builder.network_from_application(["chrome.exe", "firefox.exe"]))

    print("\n=== Query 2: Multi-Destination Beaconing ===")
    print(builder.multi_destination_beaconing(min_unique_destinations=5))

    print("\n=== Query 3: Multi-Parent Child Network ===")
    print(builder.multi_parent_child_network(min_parent_count=2))

    print("\n=== Query 4: Suspicious Child from Office ===")
    print(builder.suspicious_child_from_office_app())

    print("\n=== Query 5: Geographic Beaconing ===")
    print(builder.geographic_beaconing(min_countries=3))
