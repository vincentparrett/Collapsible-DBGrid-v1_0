# Collapsible DBGrid v1.0

Collapsible DBGrid v1.0 is a reusable Delphi component library for grouped, collapsible, data-aware grids in both VCL and FireMonkey (FMX).

The library provides FMX and VCL grid controls that share a common row model and dataset projection layer. It is intended for Delphi developers who need read-only grouped browsing, collapsible group headers, and dataset selection sync without hand-building that behavior in each application.

## Features

- VCL and FMX component implementations
- Shared common runtime package
- Runtime and design-time packages for VCL and FMX
- Group header rows mixed into visible data rows
- Expand/collapse by clicking group headers
- Groups can start collapsed by default
- Dataset selection synchronization from visible data rows
- Design-time preview rows when no active dataset is assigned
- Safe design-time datasource assignment by default
- Documentation and build/install helper scripts included

## Basic Use

```pascal
CollapsibleGrid.DataSource := YourDataSource;
CollapsibleGrid.GroupField := 'YourGroupField';
CollapsibleGrid.KeyField := 'YourPrimaryKeyField';
CollapsibleGrid.StartCollapsed := True;
```

The component does not create dataset-specific columns by default. Configure the `Columns` collection at design time for the dataset you are using.

`UseActiveDataAtDesignTime` defaults to `False` so assigning a datasource in the IDE does not walk an active query or open database work. Set it to `True` only when you deliberately want live dataset rows shown in the designer.

## Build Requirements

- Windows
- Embarcadero Delphi / RAD Studio
- VCL and/or FireMonkey support, depending on which packages you build

From the project root:

```powershell
.\tools\build_components.ps1
```

The build creates a shared common runtime package plus FMX and VCL runtime/design packages. The FMX and VCL packages both depend on `CommonCollapsibleDBGridRuntime` so shared units are loaded only once by the IDE.

For one-time IDE registration:

```powershell
.\tools\install_once.ps1
```

If Delphi is open and package BPLs are locked, use:

```powershell
.\tools\rebuild_for_ide.ps1
```

## Repository Layout

```text
.
|-- src/          Component source code grouped by Common, FMX, and VCL
|-- packages/     Delphi runtime and design-time package projects
|-- docs/         User and engineering guides
|-- Images/       Image assets used by documentation or the project
|-- samples/      Sample payloads/projects when present
|-- tools/        Build, install, and guide-generation scripts
|-- .gitignore    Files intentionally excluded from Git
`-- .gitattributes Git text/binary handling rules
```

## Files Not Included in Git

This repository intentionally excludes generated and local-only files such as:

- Delphi build output: `*.dcu`, `*.bpl`, `*.dcp`, `bin/`, `Win32/`, `Win64/`, `Debug/`, `Release/`
- Delphi local state: `*.local`, `*.identcache`, `__history/`, `__recovery/`
- Python/tool caches such as `__pycache__/` and `*.pyc`
- Local archives, logs, and temporary files

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

Copyright (c) 2026 Tommy Martin.

## Author

Tommy Martin
- Supports Delphi 12 and later. The current packages are being built on Delphi 13.1.

