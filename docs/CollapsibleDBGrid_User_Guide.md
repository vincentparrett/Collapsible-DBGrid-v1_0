# CollapsibleDBGrid User Guide

## Overview

CollapsibleDBGrid is a reusable Delphi component library that provides data-aware collapsible grouped grids for both VCL and FMX applications.

- VCL component: `TVCLCollapsibleDBGrid`
- FMX component: `TFMXCollapsibleDBGrid`
- Palette page: `CollapsibleDBGrid`

Both versions are designed to be dropped on a form at design time and configured through the Object Inspector. They are read-only browser grids: they display dataset records grouped under expandable/collapsible header rows and synchronize selected data rows back to the dataset.

## Required Data Components

At minimum, place these on the form:

- A database connection component, such as `TFDConnection`
- A dataset component, such as `TFDQuery`, `TFDTable`, or another `TDataSet` descendant
- A `TDataSource`
- A `TVCLCollapsibleDBGrid` or `TFMXCollapsibleDBGrid`

Connect them like this:

```pascal
FDQuery1.Connection := FDConnection1;
DataSource1.DataSet := FDQuery1;
CollapsibleDBGrid1.DataSource := DataSource1;
```

The grid does not open database connections automatically in the IDE. Open the connection/query yourself when you want live data.

## Installation

This component library is installed through Delphi package files. A shared distribution should include the source folders and Delphi packages, not local maintenance scripts from the development machine.

### Prerequisites

- Delphi 13 or a compatible Delphi version.
- VCL support installed if you plan to use `TVCLCollapsibleDBGrid`.
- FMX support installed if you plan to use `TFMXCollapsibleDBGrid`.
- Permission to write compiled package output to Delphi's BPL/DCP folders.

Typical Delphi package output folders are similar to:

```text
C:\Users\Public\Documents\Embarcadero\Studio\<version>\Bpl
C:\Users\Public\Documents\Embarcadero\Studio\<version>\Dcp
```

Your exact `<version>` depends on the installed RAD Studio version.

### Files That Must Be Included

The recipient needs these folders:

```text
src\Common
src\VCL
src\FMX
packages
docs
```

The recipient does not need local development helper scripts.

### Before Installing

1. Close all running Delphi IDE windows.
2. Check Task Manager for `bds.exe`.
3. If `bds.exe` is still running, end it or restart Windows before installing.

Delphi keeps design packages loaded while the IDE is open. If the IDE is running, BPL files can be locked and the installation may appear to succeed while Delphi still uses an older package.

### Install the VCL Component

Use this sequence for VCL:

1. Open Delphi.
2. Open `packages\CommonCollapsibleDBGridRuntime.dpk`.
3. Build the package.
4. Open `packages\VCLCollapsibleDBGridRuntime.dpk`.
5. Build the package.
6. Open `packages\VCLCollapsibleDBGridDesign.dpk`.
7. Build the package.
8. Install the design package.
9. Restart Delphi.

After restart, the component should appear on the `CollapsibleDBGrid` palette page as `TVCLCollapsibleDBGrid`.

### Install the FMX Component

Use this sequence for FMX:

1. Open Delphi.
2. Open `packages\CommonCollapsibleDBGridRuntime.dpk`.
3. Build the package.
4. Open `packages\FMXCollapsibleDBGridRuntime.dpk`.
5. Build the package.
6. Open `packages\FMXCollapsibleDBGridDesign.dpk`.
7. Build the package.
8. Install the design package.
9. Restart Delphi.

After restart, the component should appear on the `CollapsibleDBGrid` palette page as `TFMXCollapsibleDBGrid`.

### Library Search Path

If Delphi cannot find units such as `VCL.CollapsibleDBGrid`, `FMX.CollapsibleDBGrid`, or `CollapsibleDBGrid.Data`, add these source folders to the Delphi Library Path for the target platform:

```text
<install folder>\src\Common
<install folder>\src\VCL
<install folder>\src\FMX
```

For VCL-only use, the FMX source path is not required. For FMX-only use, the VCL source path is not required.

### Runtime Deployment

Applications using runtime packages must be able to find the runtime BPL files at run time. Either:

- build the application without runtime packages, or
- deploy the required BPL files with the application, or
- make sure the BPL output folder is on the system path.

For most simple applications, building without runtime packages is easiest.

### Verifying Installation

For VCL:

1. Create a new VCL Forms application.
2. Open the Tool Palette.
3. Search for `TVCLCollapsibleDBGrid`.
4. Drop it on the form.

For FMX:

1. Create a new Multi-Device application.
2. Open the Tool Palette.
3. Search for `TFMXCollapsibleDBGrid`.
4. Drop it on the form.

If the component appears and can be placed on a form, the design package is loaded correctly.

## Basic Setup

1. Drop the grid on the form.
2. Set `DataSource` to a `TDataSource`.
3. Set `GroupField` to the dataset field used for grouping.
4. Add entries to `Columns`.
5. For each column, set:
   - `FieldName`: dataset field to display
   - `Header`: column heading
   - `Width`: design width before startup autosizing
6. Optional: set `KeyField` to a stable unique field.

Example:

```pascal
CollapsibleDBGrid1.DataSource := DataSource1;
CollapsibleDBGrid1.GroupField := 'season';
CollapsibleDBGrid1.KeyField := 'id';
```

Columns example:

```text
Columns[0].FieldName = song_name
Columns[0].Header    = Song Name

Columns[1].FieldName = song_duration
Columns[1].Header    = Duration
```

## Important Properties

`DataSource`

The data source connected to an active dataset.

`GroupField`

The dataset field used to create group header rows.

`KeyField`

Optional stable row identity field. Use this when available.

`StartCollapsed`

When `True`, groups start collapsed. Default is `True`.

`AutoExpandSelectedGroup`

When dataset selection changes, the grid can open the selected row's group. Default is `True`.

`AutoHeight`

When `True`, the grid resizes vertically to fit visible rows where possible. If expanded content is taller than the form, it snaps to full visible rows and keeps scrolling available.

`AutoSizeColumnsAtStartup`

When `True`, columns are autosized once at runtime startup using the current data. Default is `True`.

`ShowDesignPreview`

When `True`, design-time preview groups and rows are shown if no active dataset is available. Default is `True`.

`UseActiveDataAtDesignTime`

When `True`, an already-active dataset can be used in the designer. Default is `False`.

`DesignPreviewGroupCount`

Number of dummy preview groups at design time.

`DesignPreviewRowsPerGroup`

Number of dummy rows per preview group at design time.

`ShowEmptyGroupAs`

Text used when the group field is blank or null.

`RemoveFileNamePath`

When `True`, path-like values such as `C:\Music\Song.mp3` display as `Song.mp3`.

`Columns`

Collection of displayed data columns. This is the property to edit in both VCL and FMX.

## Runtime Behavior

The grid displays two kinds of visible rows:

- Group header rows, such as `[+] Christmas (10 rows)`
- Data rows under expanded groups

Click a group header to expand or collapse it.

Right-click the grid for:

- Expand All Groups
- Collapse All Groups

When a data row is clicked, the grid moves the dataset to that record where possible.

## Events

`OnGetGroupText`

Customize group header text.

`OnGetCellText`

Customize displayed cell text.

`OnGroupExpanded`

Runs after a group is expanded.

`OnGroupCollapsed`

Runs after a group is collapsed.

`OnRowActivated`

Runs when a data row is activated, such as double-click.

`OnSelectionChanged`

Runs when the selected grid row changes.

## VCL Notes

Use `TVCLCollapsibleDBGrid` in VCL projects.

The VCL version inherits from `TCustomDrawGrid`. It draws its own header, group rows, alternating rows, and selection coloring.

Recommended VCL setup:

```pascal
VCLCollapsibleDBGrid1.DataSource := DataSource1;
VCLCollapsibleDBGrid1.GroupField := 'season';
VCLCollapsibleDBGrid1.StartCollapsed := True;
VCLCollapsibleDBGrid1.AutoHeight := True;
```

## FMX Notes

Use `TFMXCollapsibleDBGrid` in FMX projects.

The FMX version inherits from `TStringGrid`, but it manages its own displayed columns from the component `Columns` collection. Do not add native `TStringColumn` children manually.

Recommended FMX setup:

```pascal
FMXCollapsibleDBGrid1.DataSource := DataSource1;
FMXCollapsibleDBGrid1.GroupField := 'season';
FMXCollapsibleDBGrid1.StartCollapsed := True;
FMXCollapsibleDBGrid1.AutoHeight := True;
```

If the FMX grid appears empty but the dataset is active, verify:

- `Columns` has at least one item.
- Each column has a valid `FieldName`.
- `GroupField` exists in the dataset.
- The dataset is active at runtime.

## Troubleshooting

Grid shows preview rows only:

- The dataset is not active.
- `DataSource` is not connected.
- `UseActiveDataAtDesignTime` is `False` in the designer.

Grid shows no rows:

- `Columns` is empty.
- Column `FieldName` values do not match dataset fields.
- Dataset is inactive or empty.

Groups do not appear:

- `GroupField` is blank.
- `GroupField` does not exist in the dataset.

IDE package load error:

- Close Delphi completely.
- Rebuild/install packages.
- Restart Delphi.

BPL files are locked:

- Close `bds.exe`.
- Rebuild and reinstall the affected design package.
- Restart Delphi.
