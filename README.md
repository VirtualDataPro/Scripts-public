# VMware PowerShell Toolkit

A collection of PowerShell and VMware PowerCLI scripts for inventory,
storage, networking, migration, security, and operational tasks.

## Public-release notice

This repository is a sanitized public edition. Organization-specific systems,
accounts, addresses, exports, document metadata, historical archives, and
third-party material without a confirmed redistribution license were excluded.

Names under `example.com` and `example.local`, UUIDs consisting only of zeroes,
and private addresses such as `192.168.1.0/24` are documentation placeholders.
Replace them with values appropriate to your environment before use.

No production credentials are included. Scripts request credentials at runtime
where needed; do not hard-code secrets or commit exported infrastructure data.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `Inventory/` | Inventory and reporting scripts |
| `Storage/` | Datastore, pathing, RDM, iSCSI, and storage maintenance |
| `Networking/` | DVS, firewall, SSH, NIC, and discovery tasks |
| `Migration/` | Export/import and resource-pool migration workflows |
| `Security/` | ESXi hardening, STIG, and lockdown operations |
| `Operations/` | Lifecycle, snapshots, alarms, sizing, and recovery |
| `Modules/` | Reusable PowerShell helpers |
| `Docs/` | Public-release inventory and sanitization notes |

## Safety

These scripts span multiple PowerCLI and vSphere generations. Review every
script before execution and test it in a non-production environment. Many
mutating scripts predate consistent `SupportsShouldProcess`/`-WhatIf` support.
Confirm targets, permissions, backups, and rollback procedures yourself.

## Licensing and provenance

Code retained here is released under the [MIT License](LICENSE). Material
explicitly attributed to other authors, book examples, historical archives,
and ambiguous externally sourced snippets were excluded from this public copy.
If you identify retained code with incompatible provenance, please open an
issue with the file path and source information.

