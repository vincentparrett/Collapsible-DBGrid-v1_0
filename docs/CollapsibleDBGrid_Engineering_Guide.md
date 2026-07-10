# CollapsibleDBGrid Engineering Guide

## Purpose

CollapsibleDBGrid is a Delphi component library providing grouped, collapsible, data-aware grids for both VCL and FMX.

The design goal is a drop-in design-time component, not runtime-created forms or manually wired UI. Both framework versions share grouping and dataset projection logic while keeping visual rendering framework-specific.

## Project Layout

```text
Collapsible Grid v 1_0/
  src/
    Common/
      CollapsibleDBGrid.Core.pas
      CollapsibleDBGrid.Data.pas
    FMX/
      FMX.CollapsibleDBGrid.pas
      FMX.CollapsibleDBGrid.Register.pas
    VCL/
      VCL.CollapsibleDBGrid.pas
      VCL.CollapsibleDBGrid.Register.pas
  packages/
    CommonCollapsibleDBGridRuntime.dpk
    FMXCollapsibleDBGridRuntime.dpk
    FMXCollapsibleDBGridDesign.dpk
    VCLCollapsibleDBGridRuntime.dpk
    VCLCollapsibleDBGridDesign.dpk
  docs/
  bin/
```

The `bin` folder is for local build output. It should not contain authoritative source files.

## Architecture

The library has three layers:

1. Common row model and row builder
2. Framework-specific data-aware grid controls
3. Design-time registration packages

The common layer builds a visible row projection from a dataset:

- group header rows
- data rows
- collapsed/expanded group state
- display values for configured columns

The VCL and FMX controls consume that projection and render it using their own drawing systems.

## Common Units

### `CollapsibleDBGrid.Core.pas`

Contains shared row/state primitives:

- `TCollapsibleGridRowKind`
- `TCollapsibleGridRow`
- `TCollapsibleGridRows`
- `TCollapsibleGroupState`

`TCollapsibleGroupState` owns collapse state by group name and has `DefaultCollapsed`.

### `CollapsibleDBGrid.Data.pas`

Contains column metadata and dataset projection:

- `TCollapsibleDBGridColumn`
- `TCollapsibleDBGridColumns`
- `TCollapsibleDBGridBuildOptions`
- `TCollapsibleDBGridRowBuilder`

`BuildFromDataSet` scans the dataset and builds visible rows. It preserves the current dataset position with bookmarks where possible.

Important behavior:

- Uses `GroupField` to group records.
- Uses configured `Columns` to decide displayed fields.
- Uses `KeyField` if available.
- Falls back to `RecNo` when needed.
- Respects `StartCollapsed` through `TCollapsibleGroupState`.
- Can remove path prefixes when `RemoveFileNamePath` is enabled.

## VCL Component

Unit:

```pascal
src\VCL\VCL.CollapsibleDBGrid.pas
```

Class:

```pascal
TVCLCollapsibleDBGrid = class(TCustomDrawGrid, ICollapsibleDBGridColumnsChanged)
```

The VCL control owns:

- `TDataLink`
- shared `TCollapsibleGridRows`
- shared `TCollapsibleDBGridColumns`
- `TCollapsibleGroupState`
- VCL popup menu

Rendering is done through `DrawCell`.

VCL-specific behavior:

- Header row is fixed row `0`.
- Data/model rows are offset by fixed rows.
- Auto-height uses actual row heights and grid line width.
- Right-click menu supports Expand All Groups and Collapse All Groups.
- Startup autosizing can fit the grid width to columns.

## FMX Component

Unit:

```pascal
src\FMX\FMX.CollapsibleDBGrid.pas
```

Class:

```pascal
TFMXCollapsibleDBGrid = class(TStringGrid, ICollapsibleDBGridColumnsChanged)
```

The FMX control owns:

- `TDataLink`
- shared `TCollapsibleGridRows`
- shared `TCollapsibleDBGridColumns`
- `TCollapsibleGroupState`
- FMX popup menu

FMX uses a `TStringGrid` base but does not expose native FMX grid columns as the user-facing column model. The public `Columns` property is the component data-column collection. Internal FMX visual columns are created from that collection and marked not stored.

Important FMX implementation details:

- Uses `FMX.Grid.Style` and a presentation-name override so the inherited grid presentation is registered correctly.
- Sets `DefaultDrawing := False`.
- Draws row backgrounds through `OnDrawColumnBackground`.
- Draws text through `OnDrawColumnCell`.
- Draws the teal header through `OnDrawColumnHeader`.
- Sets `RowHeight := 20`.
- Uses `TopRow` to scroll an expanded group to the top.
- Auto-height caps against the owning FMX form client area, not only the immediate parent.

## Public Properties

Both VCL and FMX expose the same main component API:

```pascal
DataSource: TDataSource
GroupField: string
KeyField: string
StartCollapsed: Boolean
AutoHeight: Boolean
AutoSizeColumnsAtStartup: Boolean
AutoExpandSelectedGroup: Boolean
ShowDesignPreview: Boolean
UseActiveDataAtDesignTime: Boolean
DesignPreviewGroupCount: Integer
DesignPreviewRowsPerGroup: Integer
ShowEmptyGroupAs: string
RemoveFileNamePath: Boolean
Columns: TCollapsibleDBGridColumns
```

Column items expose:

```pascal
FieldName: string
Header: string
Width: Integer
```

## Events

Both controls expose:

```pascal
OnGetGroupText
OnGetCellText
OnGroupExpanded
OnGroupCollapsed
OnRowActivated
OnSelectionChanged
```

Use these to customize display text and respond to user navigation without modifying the core row builder.

## Dataset Synchronization

The grid reads from `TDataSource.DataSet`.

Dataset changes trigger refresh through `TDataLink` methods:

- `ActiveChanged`
- `DataSetChanged`
- `DataSetScrolled`
- `RecordChanged`

Clicking a data row attempts to move the dataset to that row. Current implementation primarily uses `RecNo` for synchronization. `KeyField` is captured in the row model and should be preferred for future robust locate-based synchronization, especially for filtered/sorted datasets.

## Design-Time Behavior

Default behavior:

```pascal
ShowDesignPreview := True;
UseActiveDataAtDesignTime := False;
StartCollapsed := True;
```

The controls should not open database connections automatically in the IDE.

If no active dataset is available at design time, preview groups and rows are generated from the configured `Columns`.

If `UseActiveDataAtDesignTime` is enabled and the dataset is already active, real data can be used in the designer.

## Package Design

Runtime packages:

- `CommonCollapsibleDBGridRuntime.dpk`
- `FMXCollapsibleDBGridRuntime.dpk`
- `VCLCollapsibleDBGridRuntime.dpk`

Design packages:

- `FMXCollapsibleDBGridDesign.dpk`
- `VCLCollapsibleDBGridDesign.dpk`

The design packages register components on the `CollapsibleDBGrid` palette page.

Registration units:

```pascal
FMX.CollapsibleDBGrid.Register.pas
VCL.CollapsibleDBGrid.Register.pas
```

## Distribution Package

A redistributable component archive should include:

```text
src\Common
src\VCL
src\FMX
packages
docs
Images
samples
```

Do not include local development-only helper scripts unless they have been reviewed, generalized, and documented for external users.

Do not include generated clutter such as:

- `.dcu`
- `.bpl`
- `.dcp`
- `.local`
- `.identcache`
- `__history`
- `__recovery`
- temporary test projects

Precompiled BPL/DCP files may be distributed separately only when they are built for the exact Delphi version and platform the recipient uses.

## Manual Build and Install

External users should be able to install from the Delphi IDE without relying on local project scripts.

### Prerequisites

- Delphi 13 or a compatible Delphi version.
- VCL framework support for VCL installation.
- FMX framework support for FMX installation.
- Write access to Delphi's package output folders.

Common package output locations are:

```text
C:\Users\Public\Documents\Embarcadero\Studio\<version>\Bpl
C:\Users\Public\Documents\Embarcadero\Studio\<version>\Dcp
```

### Required Source Paths

The package projects reference units from the source folders. If the package opens but cannot find units, add these source folders to Delphi's Library Path for the target platform:

```text
<install folder>\src\Common
<install folder>\src\VCL
<install folder>\src\FMX
```

For VCL-only installation, `src\Common` and `src\VCL` are required.

For FMX-only installation, `src\Common` and `src\FMX` are required.

### Install Order

Build runtime packages before design-time packages.

For VCL:

1. Build `CommonCollapsibleDBGridRuntime.dpk`.
2. Build `VCLCollapsibleDBGridRuntime.dpk`.
3. Build `VCLCollapsibleDBGridDesign.dpk`.
4. Install `VCLCollapsibleDBGridDesign.dpk`.
5. Restart Delphi.

For FMX:

1. Build `CommonCollapsibleDBGridRuntime.dpk`.
2. Build `FMXCollapsibleDBGridRuntime.dpk`.
3. Build `FMXCollapsibleDBGridDesign.dpk`.
4. Install `FMXCollapsibleDBGridDesign.dpk`.
5. Restart Delphi.

If installing both frameworks, build the common runtime once, then build both runtime packages, then build and install both design packages.

### Before Reinstalling

Always close Delphi before replacing packages or BPL files. Verify that `bds.exe` is not running.

If Delphi is left open:

- BPL files may be locked.
- The IDE may continue using stale packages.
- package registration may appear correct while the old component code remains loaded.

### Installing Precompiled Packages

If precompiled BPL/DCP files are supplied, they must match:

- Delphi version
- platform
- package dependencies
- output folder expectations

Copy BPL files to Delphi's BPL folder and DCP files to Delphi's DCP folder. Then install/register the design package through the IDE or Delphi package registration mechanism.

Precompiled packages are less portable than source packages. Source installation is preferred when the recipient has Delphi.

### Verifying the Install

After Delphi restarts:

1. Create a new VCL or FMX test application.
2. Search the Tool Palette for `CollapsibleDBGrid`.
3. Drop the component on a form.
4. Add a `TDataSource`, dataset, and connection.
5. Add at least one item to `Columns`.
6. Set `DataSource` and `GroupField`.

The grid should show design preview rows when no active dataset is available, or real grouped rows when connected to an active dataset at runtime.

## Development Build Notes

For maintainers, package order is still:

1. common runtime
2. framework runtime
3. framework design package

Use Delphi's compiler output seriously. Hints and warnings often indicate package dependency or unit-uses problems that will later become IDE load failures.

## Current Behavioral Notes

Both versions:

- Are read-only browsers.
- Use the shared projection builder.
- Start groups collapsed by default.
- Support click to expand/collapse.
- Support right-click expand/collapse all.
- Support startup autosizing.
- Support optional auto-height.
- Support design-time preview rows.

VCL is currently more mature in debug instrumentation.

FMX requires more care because native `TStringGrid` visual columns and styled presentation internals can be streamed separately. The component creates internal visual columns from the public `Columns` collection and marks them not stored.

## Future Work

Recommended next engineering tasks:

- Add key-based locate synchronization using `KeyField`.
- Add sample VCL and FMX demo projects under `samples`.
- Add automated package smoke build checks.
- Add optional editor support only after read-only behavior remains stable.
- Add theme/color properties if users need visual customization outside default VCL/FMX styling.
