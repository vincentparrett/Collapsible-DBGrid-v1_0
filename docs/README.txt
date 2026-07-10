# CollapsibleDBGrid

Reusable Delphi component library for grouped, collapsible, data-aware grids in FMX and VCL.

## Current Scope

- Read-only data browsing.
- Group header rows mixed into visible rows.
- Expand/collapse by clicking group headers.
- Groups start collapsed by default.
- Dataset selection sync from visible data rows.
- Design-time preview rows when no active dataset is assigned.
- Design-time datasource assignment does not read active datasets by default.
- FMX and VCL controls sharing the same row model and dataset projection.

## Basic Use

```pascal
CollapsibleGrid.DataSource := YourDataSource;
CollapsibleGrid.GroupField := 'YourGroupField';
CollapsibleGrid.KeyField := 'YourPrimaryKeyField';
CollapsibleGrid.StartCollapsed := True;
```

The component does not create dataset-specific columns by default. Configure the `Columns` collection at design time for the dataset you are using.

`UseActiveDataAtDesignTime` defaults to `False` so assigning a datasource in the IDE does not walk an active query or open database work. Set it to `True` only when you deliberately want live dataset rows shown in the designer.

## Build

From the project root:

```powershell
.\tools\build_components.ps1
```

The build creates a shared common runtime package plus FMX and VCL runtime/design packages. The FMX and VCL packages both depend on `CommonCollapsibleDBGridRuntime` so shared units are loaded only once by the IDE.

For one-time IDE registration:

```powershell
.\tools\install_once.ps1
```

If Delphi is open, package BPLs may be locked. Use:

```powershell
.\tools\rebuild_for_ide.ps1
```
