unit FMX.CollapsibleDBGrid;

interface

uses
  System.Classes, System.Math, System.SysUtils, System.Types, System.UITypes,
  System.Rtti, Data.DB, FMX.Controls, FMX.Grid, FMX.Grid.Style, FMX.Graphics,
  FMX.Forms, FMX.Menus, FMX.Presentation.Factory, FMX.ScrollBox, FMX.Types,
  CollapsibleDBGrid.Core, CollapsibleDBGrid.Data;

type
  TFMXCollapsibleDBGrid = class;

  TCollapsibleGridNotifyEvent = procedure(Sender: TObject; const GroupName: string) of object;
  TCollapsibleGridRowEvent = procedure(Sender: TObject; const Row: TCollapsibleGridRow) of object;
  TCollapsibleGridBeforeGroupEvent = procedure(Sender: TObject; const GroupName: string;
    var Allow: Boolean) of object;
  TCollapsibleGridBeforeRowEvent = procedure(Sender: TObject;
    const Row: TCollapsibleGridRow; var Allow: Boolean) of object;
  TCollapsibleFormatGroupHeaderEvent = procedure(Sender: TObject;
    const Row: TCollapsibleGridRow; var Text: string) of object;
  TFMXCollapsibleDrawRowEvent = procedure(Sender: TObject; const Canvas: TCanvas;
    const Row: TCollapsibleGridRow; const Bounds: TRectF; const State: TGridDrawStates;
    var DefaultDraw: Boolean) of object;

  TFMXCollapsibleGridDataLink = class(TDataLink)
  private
    FGrid: TFMXCollapsibleDBGrid;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AGrid: TFMXCollapsibleDBGrid);
  end;

  TFMXCollapsibleDBGrid = class(TStringGrid, ICollapsibleDBGridColumnsChanged)
  private
    FAutoExpandSelectedGroup: Boolean;
    FAutoHeight: Boolean;
    FAutoSizeColumnsAtStartup: Boolean;
    FAutoSizedAtStartup: Boolean;
    FColumns: TCollapsibleDBGridColumns;
    FContextMenu: TPopupMenu;
    FDataLink: TFMXCollapsibleGridDataLink;
    FDesignPreviewGroupCount: Integer;
    FDesignPreviewRowsPerGroup: Integer;
    FGroupField: string;
    FGroupState: TCollapsibleGroupState;
    FGroupTextSettings: TTextSettings;
    FGroupRowColor: TAlphaColor;
    FHeaderTextSettings: TTextSettings;
    FHeaderRowColor: TAlphaColor;
    FKeyField: string;
    FOnBeforeGroupCollapse: TCollapsibleGridBeforeGroupEvent;
    FOnBeforeGroupExpand: TCollapsibleGridBeforeGroupEvent;
    FOnBeforeRowSelect: TCollapsibleGridBeforeRowEvent;
    FOnDrawDataRow: TFMXCollapsibleDrawRowEvent;
    FOnDrawGroupRow: TFMXCollapsibleDrawRowEvent;
    FOnFormatGroupHeader: TCollapsibleFormatGroupHeaderEvent;
    FOddRowColor: TAlphaColor;
    FOnGetCellText: TCollapsibleGetCellTextEvent;
    FOnGetGroupText: TCollapsibleGetGroupTextEvent;
    FOnGroupCollapsed: TCollapsibleGridNotifyEvent;
    FOnGroupExpanded: TCollapsibleGridNotifyEvent;
    FOnRowActivated: TCollapsibleGridRowEvent;
    FOnSelectionChanged: TCollapsibleGridRowEvent;
    FRemoveFileNamePath: Boolean;
    FRefreshDepth: Integer;
    FRows: TCollapsibleGridRows;
    FSelectionSyncDepth: Integer;
    FSelectedRowColor: TAlphaColor;
    FShowDesignPreview: Boolean;
    FShowEmptyGroupAs: string;
    FStartCollapsed: Boolean;
    FUpdatingColumnWidths: Boolean;
    FUseActiveDataAtDesignTime: Boolean;
    procedure ApplyAutoHeight;
    function BuildAutoSizeRows: TCollapsibleGridRows;
    procedure AutoSizeColumn(ACol: Integer; ARows: TCollapsibleGridRows);
    procedure AutoSizeColumns;
    function CellDisplayText(ACol: Integer; const ARow: TCollapsibleGridRow): string;
    function CanAutoSizeColumns: Boolean;
    procedure ContextCollapseAllGroups(Sender: TObject);
    procedure ContextExpandAllGroups(Sender: TObject);
    procedure CreateContextMenu;
    procedure FitGridWidthToColumns;
    function GetDataSource: TDataSource;
    function GetCurrentGroupName(ADataSet: TDataSet): string;
    function GetGroupFontColor: TAlphaColor;
    function GetGroupFontFamily: TFontName;
    function GetGroupFontPointSize: Integer;
    function GetGroupFontStyle: TFontStyles;
    function GetHeaderFontColor: TAlphaColor;
    function GetHeaderFontFamily: TFontName;
    function GetHeaderFontPointSize: Integer;
    function GetHeaderFontStyle: TFontStyles;
    function GetRowObject(ARow: Integer; out AGridRow: TCollapsibleGridRow): Boolean;
    procedure GroupTextSettingsChanged(Sender: TObject);
    procedure HeaderTextSettingsChanged(Sender: TObject);
    function DesiredRowHeight: Single;
    procedure InternalCellClick(const Column: TColumn; const Row: Integer);
    procedure InternalCellDblClick(const Column: TColumn; const Row: Integer);
    procedure InternalSelChanged(Sender: TObject);
    procedure InternalDrawColumnBackground(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure InternalDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure InternalDrawColumnHeader(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF);
    procedure InternalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure InternalViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    function GridColumn(AIndex: Integer): TColumn;
    procedure RebuildColumns;
    function RowFillColor(ARow: Integer; const AState: TGridDrawStates): TAlphaColor;
    procedure SetAutoHeight(const Value: Boolean);
    procedure SetColumns(const Value: TCollapsibleDBGridColumns);
    procedure SetDataSource(const Value: TDataSource);
    procedure SetGroupField(const Value: string);
    procedure SetGroupFontColor(const Value: TAlphaColor);
    procedure SetGroupFontFamily(const Value: TFontName);
    procedure ReadLegacyGroupFontSize(Reader: TReader);
    procedure ReadLegacyHeaderFontSize(Reader: TReader);
    procedure SetGroupFontPointSize(const Value: Integer);
    procedure SetGroupFontStyle(const Value: TFontStyles);
    procedure SetGroupRowColor(const Value: TAlphaColor);
    procedure SetHeaderFontColor(const Value: TAlphaColor);
    procedure SetHeaderFontFamily(const Value: TFontName);
    procedure SetHeaderFontPointSize(const Value: Integer);
    procedure SetHeaderFontStyle(const Value: TFontStyles);
    procedure SetHeaderRowColor(const Value: TAlphaColor);
    procedure SetKeyField(const Value: string);
    procedure SetOddRowColor(const Value: TAlphaColor);
    procedure SetRemoveFileNamePath(const Value: Boolean);
    procedure SetSelectedRowColor(const Value: TAlphaColor);
    procedure SetStartCollapsed(const Value: Boolean);
    procedure ToggleRow(ARow: Integer);
    function TrySyncDataSetFromRow(ARow: Integer): Boolean;
    procedure SyncDataSetFromTopVisibleRow;
    procedure UpdateMetricsForTextSettings;
    procedure ColumnsChanged;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function DefinePresentationName: string; override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer;
      var Handled: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure RebuildRows;
    procedure SyncSelectionFromDataSet(AExpandCurrentGroup: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CollapseAll;
    procedure ExpandAll;
    procedure RefreshData;
    property Rows: TCollapsibleGridRows read FRows;
  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property GroupField: string read FGroupField write SetGroupField;
    property GroupFontFamily: TFontName read GetGroupFontFamily write SetGroupFontFamily;
    property GroupFontPointSize: Integer read GetGroupFontPointSize write SetGroupFontPointSize;
    property GroupFontColor: TAlphaColor read GetGroupFontColor write SetGroupFontColor;
    property GroupFontStyle: TFontStyles read GetGroupFontStyle write SetGroupFontStyle;
    property GroupRowColor: TAlphaColor read FGroupRowColor write SetGroupRowColor;
    property HeaderFontFamily: TFontName read GetHeaderFontFamily write SetHeaderFontFamily;
    property HeaderFontPointSize: Integer read GetHeaderFontPointSize write SetHeaderFontPointSize;
    property HeaderFontColor: TAlphaColor read GetHeaderFontColor write SetHeaderFontColor;
    property HeaderFontStyle: TFontStyles read GetHeaderFontStyle write SetHeaderFontStyle;
    property HeaderRowColor: TAlphaColor read FHeaderRowColor write SetHeaderRowColor;
    property OddRowColor: TAlphaColor read FOddRowColor write SetOddRowColor;
    property SelectedRowColor: TAlphaColor read FSelectedRowColor write SetSelectedRowColor;
    property KeyField: string read FKeyField write SetKeyField;
    property StartCollapsed: Boolean read FStartCollapsed write SetStartCollapsed default True;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default False;
    property AutoSizeColumnsAtStartup: Boolean read FAutoSizeColumnsAtStartup write FAutoSizeColumnsAtStartup default False;
    property AutoExpandSelectedGroup: Boolean read FAutoExpandSelectedGroup write FAutoExpandSelectedGroup default True;
    property ShowDesignPreview: Boolean read FShowDesignPreview write FShowDesignPreview default True;
    property UseActiveDataAtDesignTime: Boolean read FUseActiveDataAtDesignTime write FUseActiveDataAtDesignTime default False;
    property DesignPreviewGroupCount: Integer read FDesignPreviewGroupCount write FDesignPreviewGroupCount default 3;
    property DesignPreviewRowsPerGroup: Integer read FDesignPreviewRowsPerGroup write FDesignPreviewRowsPerGroup default 3;
    property ShowEmptyGroupAs: string read FShowEmptyGroupAs write FShowEmptyGroupAs;
    property RemoveFileNamePath: Boolean read FRemoveFileNamePath write SetRemoveFileNamePath default False;
    property Columns: TCollapsibleDBGridColumns read FColumns write SetColumns;
    property OnGetGroupText: TCollapsibleGetGroupTextEvent read FOnGetGroupText write FOnGetGroupText;
    property OnGetCellText: TCollapsibleGetCellTextEvent read FOnGetCellText write FOnGetCellText;
    property OnBeforeGroupExpand: TCollapsibleGridBeforeGroupEvent read FOnBeforeGroupExpand write FOnBeforeGroupExpand;
    property OnBeforeGroupCollapse: TCollapsibleGridBeforeGroupEvent read FOnBeforeGroupCollapse write FOnBeforeGroupCollapse;
    property OnBeforeRowSelect: TCollapsibleGridBeforeRowEvent read FOnBeforeRowSelect write FOnBeforeRowSelect;
    property OnFormatGroupHeader: TCollapsibleFormatGroupHeaderEvent read FOnFormatGroupHeader write FOnFormatGroupHeader;
    property OnDrawGroupRow: TFMXCollapsibleDrawRowEvent read FOnDrawGroupRow write FOnDrawGroupRow;
    property OnDrawDataRow: TFMXCollapsibleDrawRowEvent read FOnDrawDataRow write FOnDrawDataRow;
    property OnGroupExpanded: TCollapsibleGridNotifyEvent read FOnGroupExpanded write FOnGroupExpanded;
    property OnGroupCollapsed: TCollapsibleGridNotifyEvent read FOnGroupCollapsed write FOnGroupCollapsed;
    property OnRowActivated: TCollapsibleGridRowEvent read FOnRowActivated write FOnRowActivated;
    property OnSelectionChanged: TCollapsibleGridRowEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;

implementation

constructor TFMXCollapsibleGridDataLink.Create(AGrid: TFMXCollapsibleDBGrid);
begin
  inherited Create;
  FGrid := AGrid;
end;

procedure TFMXCollapsibleGridDataLink.ActiveChanged;
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

procedure TFMXCollapsibleGridDataLink.DataSetChanged;
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

procedure TFMXCollapsibleGridDataLink.DataSetScrolled(Distance: Integer);
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) and (FGrid.FSelectionSyncDepth = 0) then
    FGrid.SyncSelectionFromDataSet(FGrid.FAutoExpandSelectedGroup);
end;

procedure TFMXCollapsibleGridDataLink.RecordChanged(Field: TField);
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

constructor TFMXCollapsibleDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoExpandSelectedGroup := True;
  FAutoSizeColumnsAtStartup := False;
  FStartCollapsed := True;
  FShowDesignPreview := True;
  FUseActiveDataAtDesignTime := False;
  FDesignPreviewGroupCount := 3;
  FDesignPreviewRowsPerGroup := 3;
  FShowEmptyGroupAs := '(No Group)';
  FGroupField := '';
  FRows := TCollapsibleGridRows.Create;
  FColumns := TCollapsibleDBGridColumns.Create(Self);
  FGroupState := TCollapsibleGroupState.Create;
  FGroupState.DefaultCollapsed := FStartCollapsed;
  FGroupRowColor := $FFE3EDF8;
  FGroupTextSettings := TTextSettings.Create(Self);
  FGroupTextSettings.Font.Assign(TextSettings.Font);
  FGroupTextSettings.FontColor := TextSettings.FontColor;
  FGroupTextSettings.OnChanged := GroupTextSettingsChanged;
  FHeaderTextSettings := TTextSettings.Create(Self);
  FHeaderTextSettings.Font.Assign(TextSettings.Font);
  FHeaderTextSettings.Font.Style := FHeaderTextSettings.Font.Style + [TFontStyle.fsBold];
  FHeaderTextSettings.FontColor := TAlphaColors.White;
  FHeaderTextSettings.OnChanged := HeaderTextSettingsChanged;
  FHeaderRowColor := $FF10687D;
  FOddRowColor := $FFF7F7F7;
  FSelectedRowColor := $FFD7E8FA;
  FDataLink := TFMXCollapsibleGridDataLink.Create(Self);
  ReadOnly := True;
  DefaultDrawing := False;
  RowHeight := 20;
  Options := Options - [TGridOption.Editing, TGridOption.CancelEditingByDefault];
  OnCellClick := InternalCellClick;
  OnCellDblClick := InternalCellDblClick;
  OnSelChanged := InternalSelChanged;
  OnDrawColumnBackground := InternalDrawColumnBackground;
  OnDrawColumnCell := InternalDrawColumnCell;
  OnDrawColumnHeader := InternalDrawColumnHeader;
  OnMouseDown := InternalMouseDown;
  OnViewportPositionChange := InternalViewportPositionChange;
  UpdateMetricsForTextSettings;
  CreateContextMenu;
end;

destructor TFMXCollapsibleDBGrid.Destroy;
begin
  FreeAndNil(FContextMenu);
  if Assigned(FDataLink) then
  begin
    FDataLink.FGrid := nil;
    FDataLink.DataSource := nil;
  end;
  inherited Destroy;
  FreeAndNil(FDataLink);
  FreeAndNil(FGroupState);
  FreeAndNil(FRows);
  FreeAndNil(FColumns);
  FreeAndNil(FGroupTextSettings);
  FreeAndNil(FHeaderTextSettings);
end;

procedure TFMXCollapsibleDBGrid.CreateContextMenu;

  procedure AddItem(const AText: string; AOnClick: TNotifyEvent);
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(FContextMenu);
    Item.Stored := False;
    Item.Text := AText;
    Item.OnClick := AOnClick;
    FContextMenu.AddObject(Item);
  end;

begin
  FContextMenu := TPopupMenu.Create(Self);
  FContextMenu.Stored := False;
  FContextMenu.Parent := Self;
  AddItem('Expand All Groups', ContextExpandAllGroups);
  AddItem('Collapse All Groups', ContextCollapseAllGroups);
end;

procedure TFMXCollapsibleDBGrid.Loaded;
begin
  inherited Loaded;
  UpdateMetricsForTextSettings;
  RebuildColumns;
  RefreshData;
end;

function TFMXCollapsibleDBGrid.DefinePresentationName: string;
begin
  Result := TPresentationProxyFactory.GeneratePresentationName(TStringGrid, ControlType);
end;

procedure TFMXCollapsibleDBGrid.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('GroupFontSize', ReadLegacyGroupFontSize, nil, False);
  Filer.DefineProperty('HeaderFontSize', ReadLegacyHeaderFontSize, nil, False);
end;

procedure TFMXCollapsibleDBGrid.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DataSource) then
    DataSource := nil;
end;

function TFMXCollapsibleDBGrid.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TFMXCollapsibleDBGrid.GetCurrentGroupName(ADataSet: TDataSet): string;
var
  Field: TField;
begin
  Result := '';
  if Assigned(ADataSet) and (FGroupField <> '') then
  begin
    Field := ADataSet.FindField(FGroupField);
    if Assigned(Field) and not Field.IsNull then
      Result := Field.AsString;
  end;
  Result := CollapsibleNormalizeGroupName(Result, FShowEmptyGroupAs);
end;

function TFMXCollapsibleDBGrid.BuildAutoSizeRows: TCollapsibleGridRows;
var
  BuildOptions: TCollapsibleDBGridBuildOptions;
  DataSet: TDataSet;
  GroupState: TCollapsibleGroupState;
  I: Integer;
begin
  Result := TCollapsibleGridRows.Create;
  try
    DataSet := FDataLink.DataSet;
    if Assigned(DataSet) and DataSet.Active then
    begin
      GroupState := TCollapsibleGroupState.Create;
      try
        GroupState.DefaultCollapsed := False;
        BuildOptions.GroupField := FGroupField;
        BuildOptions.KeyField := FKeyField;
        BuildOptions.EmptyGroupText := FShowEmptyGroupAs;
        BuildOptions.ShowEmptyGroupAs := FShowEmptyGroupAs;
        BuildOptions.RemoveFileNamePath := FRemoveFileNamePath;
        BuildOptions.Columns := FColumns;
        BuildOptions.GroupState := GroupState;
        BuildOptions.Sender := Self;
        BuildOptions.OnGetGroupText := FOnGetGroupText;
        BuildOptions.OnGetCellText := FOnGetCellText;
        Inc(FRefreshDepth);
        try
          TCollapsibleDBGridRowBuilder.BuildFromDataSet(DataSet, BuildOptions, Result);
        finally
          Dec(FRefreshDepth);
        end;
      finally
        GroupState.Free;
      end;
    end
    else if Assigned(FRows) then
      for I := 0 to FRows.Count - 1 do
        Result.Add(FRows[I]);
  except
    Result.Free;
    raise;
  end;
end;

function TFMXCollapsibleDBGrid.CellDisplayText(ACol: Integer;
  const ARow: TCollapsibleGridRow): string;
var
  Prefix: string;
  Text: string;
begin
  Result := '';
  if (ACol < 0) or (ACol >= Length(ARow.Values)) then
    Exit;
  if (ACol = 0) and (ARow.RowKind = crGroupHeader) then
  begin
    if FGroupState.IsCollapsed(ARow.GroupName) then
      Prefix := '  [+] '
    else
      Prefix := '  [-] ';
    Text := ARow.Values[ACol];
    if Assigned(FOnFormatGroupHeader) then
      FOnFormatGroupHeader(Self, ARow, Text);
    Result := Prefix + Text;
  end
  else if ACol = 0 then
    Result := '    ' + ARow.Values[ACol]
  else
    Result := ARow.Values[ACol];
end;

procedure TFMXCollapsibleDBGrid.AutoSizeColumn(ACol: Integer;
  ARows: TCollapsibleGridRows);
var
  DataIndex: Integer;
  HeaderText: string;
  NewWidth: Integer;
begin
  if not Assigned(FColumns) or (ACol < 0) or (ACol >= FColumns.Count) or
     (ACol >= ColumnCount) then
    Exit;
  HeaderText := FColumns[ACol].Header;
  if HeaderText = '' then
    HeaderText := FColumns[ACol].FieldName;
  Canvas.Font.Assign(FHeaderTextSettings.Font);
  NewWidth := Ceil(Canvas.TextWidth(HeaderText)) + 34;
  Canvas.Font.Assign(TextSettings.Font);
  if Assigned(ARows) then
    for DataIndex := 0 to ARows.Count - 1 do
    begin
      if ARows[DataIndex].RowKind = crGroupHeader then
        Canvas.Font.Assign(FGroupTextSettings.Font)
      else
        Canvas.Font.Assign(TextSettings.Font);
      NewWidth := Max(NewWidth, Ceil(Canvas.TextWidth(CellDisplayText(ACol, ARows[DataIndex]))) + 34);
    end;
  NewWidth := Max(NewWidth, 32);
  GridColumn(ACol).Width := NewWidth;
  FUpdatingColumnWidths := True;
  try
    FColumns[ACol].Width := Round(NewWidth);
  finally
    FUpdatingColumnWidths := False;
  end;
end;

procedure TFMXCollapsibleDBGrid.FitGridWidthToColumns;
var
  I: Integer;
  NewWidth: Single;
begin
  if Align <> TAlignLayout.None then
    Exit;
  NewWidth := 8;
  for I := 0 to ColumnCount - 1 do
    NewWidth := NewWidth + GridColumn(I).Width + 1;
  NewWidth := NewWidth + 24;
  Width := Max(32, NewWidth);
  ApplyAutoHeight;
end;

procedure TFMXCollapsibleDBGrid.AutoSizeColumns;
var
  ColIndex: Integer;
  MeasureRows: TCollapsibleGridRows;
begin
  if not Assigned(FColumns) or (FColumns.Count = 0) then
    Exit;
  MeasureRows := BuildAutoSizeRows;
  try
    for ColIndex := 0 to FColumns.Count - 1 do
      AutoSizeColumn(ColIndex, MeasureRows);
    FitGridWidthToColumns;
  finally
    MeasureRows.Free;
  end;
end;

function TFMXCollapsibleDBGrid.CanAutoSizeColumns: Boolean;
var
  DataSet: TDataSet;
begin
  Result := False;
  if csLoading in ComponentState then
    Exit;
  if not (csDesigning in ComponentState) then
    Exit(True);
  DataSet := nil;
  if Assigned(FDataLink) then
    DataSet := FDataLink.DataSet;
  Result := Assigned(DataSet) and DataSet.Active;
end;

function TFMXCollapsibleDBGrid.DesiredRowHeight: Single;
var
  FontSize: Single;
begin
  FontSize := TextSettings.Font.Size;
  if FontSize <= 0 then
    FontSize := 12;
  if FGroupTextSettings.Font.Size > FontSize then
    FontSize := FGroupTextSettings.Font.Size;
  Result := Max(20, Ceil(FontSize + 8));
end;

procedure TFMXCollapsibleDBGrid.UpdateMetricsForTextSettings;
var
  NewRowHeight: Single;
begin
  NewRowHeight := DesiredRowHeight;
  if not SameValue(RowHeight, NewRowHeight) then
  begin
    RowHeight := NewRowHeight;
    ApplyAutoHeight;
    Repaint;
  end;
end;

procedure TFMXCollapsibleDBGrid.ApplyAutoHeight;
var
  BorderExtent: Single;
  DesiredHeight: Single;
  HeaderHeightValue: Single;
  MaxHeight: Single;
  MaxVisibleRows: Integer;
  OwnerForm: TFmxObject;
  RowExtent: Single;
  RowHeightValue: Single;
  TopInForm: Single;
  VisibleRowCount: Integer;
begin
  if not FAutoHeight or (Align <> TAlignLayout.None) or (csLoading in ComponentState) then
    Exit;
  RowHeightValue := RowHeight;
  if RowHeightValue <= 0 then
    RowHeightValue := 20;
  HeaderHeightValue := Max(24, Ceil(FHeaderTextSettings.Font.Size + 8));
  HeaderHeightValue := Max(HeaderHeightValue, RowHeightValue + 4);
  RowExtent := RowHeightValue + 1;
  BorderExtent := 4;
  VisibleRowCount := Max(0, RowCount);
  DesiredHeight := HeaderHeightValue + (VisibleRowCount * RowExtent) + BorderExtent;
  MaxHeight := 1.0E30;
  if not (csDesigning in ComponentState) then
  begin
    if Parent is TControl then
      MaxHeight := Max(24, TControl(Parent).Height - Position.Y - 16);
    OwnerForm := Parent;
    while Assigned(OwnerForm) and not (OwnerForm is TCommonCustomForm) do
      OwnerForm := OwnerForm.Parent;
    if OwnerForm is TCommonCustomForm then
    begin
      TopInForm := LocalToAbsolute(PointF(0, 0)).Y;
      MaxHeight := Min(MaxHeight,
        Max(24, TCommonCustomForm(OwnerForm).ClientHeight - TopInForm - 16));
    end;
  end;
  if DesiredHeight > MaxHeight then
  begin
    MaxHeight := Max(24, MaxHeight - 20);
    MaxVisibleRows := Floor((MaxHeight - HeaderHeightValue - BorderExtent) / RowExtent);
    MaxVisibleRows := Max(0, Min(VisibleRowCount, MaxVisibleRows));
    Height := Max(24, HeaderHeightValue + (MaxVisibleRows * RowExtent) + BorderExtent);
  end
  else
    Height := Max(24, DesiredHeight);
end;

procedure TFMXCollapsibleDBGrid.ContextCollapseAllGroups(Sender: TObject);
begin
  CollapseAll;
end;

procedure TFMXCollapsibleDBGrid.ContextExpandAllGroups(Sender: TObject);
begin
  ExpandAll;
end;

function TFMXCollapsibleDBGrid.GetGroupFontColor: TAlphaColor;
begin
  Result := FGroupTextSettings.FontColor;
end;

function TFMXCollapsibleDBGrid.GetGroupFontFamily: TFontName;
begin
  Result := FGroupTextSettings.Font.Family;
end;

function TFMXCollapsibleDBGrid.GetGroupFontPointSize: Integer;
begin
  Result := Round(FGroupTextSettings.Font.Size);
end;

function TFMXCollapsibleDBGrid.GetGroupFontStyle: TFontStyles;
begin
  Result := FGroupTextSettings.Font.Style;
end;

function TFMXCollapsibleDBGrid.GetHeaderFontColor: TAlphaColor;
begin
  Result := FHeaderTextSettings.FontColor;
end;

function TFMXCollapsibleDBGrid.GetHeaderFontFamily: TFontName;
begin
  Result := FHeaderTextSettings.Font.Family;
end;

function TFMXCollapsibleDBGrid.GetHeaderFontPointSize: Integer;
begin
  Result := Round(FHeaderTextSettings.Font.Size);
end;

function TFMXCollapsibleDBGrid.GetHeaderFontStyle: TFontStyles;
begin
  Result := FHeaderTextSettings.Font.Style;
end;

procedure TFMXCollapsibleDBGrid.GroupTextSettingsChanged(Sender: TObject);
begin
  UpdateMetricsForTextSettings;
  if FAutoSizeColumnsAtStartup and CanAutoSizeColumns then
    AutoSizeColumns;
  ApplyAutoHeight;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.HeaderTextSettingsChanged(Sender: TObject);
begin
  if FAutoSizeColumnsAtStartup and CanAutoSizeColumns then
    AutoSizeColumns;
  ApplyAutoHeight;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.ReadLegacyGroupFontSize(Reader: TReader);
begin
  case Reader.NextValue of
    vaInt8, vaInt16, vaInt32:
      SetGroupFontPointSize(Reader.ReadInteger);
    vaSingle, vaExtended:
      SetGroupFontPointSize(Round(Reader.ReadFloat));
  else
    Reader.SkipValue;
  end;
end;

procedure TFMXCollapsibleDBGrid.ReadLegacyHeaderFontSize(Reader: TReader);
begin
  case Reader.NextValue of
    vaInt8, vaInt16, vaInt32:
      SetHeaderFontPointSize(Reader.ReadInteger);
    vaSingle, vaExtended:
      SetHeaderFontPointSize(Round(Reader.ReadFloat));
  else
    Reader.SkipValue;
  end;
end;

procedure TFMXCollapsibleDBGrid.SetGroupFontColor(const Value: TAlphaColor);
begin
  FGroupTextSettings.FontColor := Value;
end;

procedure TFMXCollapsibleDBGrid.SetGroupFontFamily(const Value: TFontName);
begin
  FGroupTextSettings.Font.Family := Value;
end;

procedure TFMXCollapsibleDBGrid.SetGroupFontPointSize(const Value: Integer);
begin
  FGroupTextSettings.Font.Size := Value;
end;

procedure TFMXCollapsibleDBGrid.SetGroupFontStyle(const Value: TFontStyles);
begin
  FGroupTextSettings.Font.Style := Value;
end;

procedure TFMXCollapsibleDBGrid.SetGroupRowColor(const Value: TAlphaColor);
begin
  if FGroupRowColor = Value then
    Exit;
  FGroupRowColor := Value;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.SetHeaderFontColor(const Value: TAlphaColor);
begin
  FHeaderTextSettings.FontColor := Value;
end;

procedure TFMXCollapsibleDBGrid.SetHeaderFontFamily(const Value: TFontName);
begin
  FHeaderTextSettings.Font.Family := Value;
end;

procedure TFMXCollapsibleDBGrid.SetHeaderFontPointSize(const Value: Integer);
begin
  FHeaderTextSettings.Font.Size := Value;
end;

procedure TFMXCollapsibleDBGrid.SetHeaderFontStyle(const Value: TFontStyles);
begin
  FHeaderTextSettings.Font.Style := Value;
end;

procedure TFMXCollapsibleDBGrid.SetHeaderRowColor(const Value: TAlphaColor);
begin
  if FHeaderRowColor = Value then
    Exit;
  FHeaderRowColor := Value;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.SetOddRowColor(const Value: TAlphaColor);
begin
  if FOddRowColor = Value then
    Exit;
  FOddRowColor := Value;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.SetSelectedRowColor(const Value: TAlphaColor);
begin
  if FSelectedRowColor = Value then
    Exit;
  FSelectedRowColor := Value;
  Repaint;
end;

procedure TFMXCollapsibleDBGrid.SetAutoHeight(const Value: Boolean);
begin
  if FAutoHeight = Value then
    Exit;
  FAutoHeight := Value;
  ApplyAutoHeight;
end;

procedure TFMXCollapsibleDBGrid.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource = Value then
    Exit;
  if Assigned(FDataLink.DataSource) then
    FDataLink.DataSource.RemoveFreeNotification(Self);
  FDataLink.DataSource := Value;
  if Assigned(Value) then
    Value.FreeNotification(Self);
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.SetColumns(
  const Value: TCollapsibleDBGridColumns);
begin
  FColumns.Assign(Value);
  ColumnsChanged;
end;

procedure TFMXCollapsibleDBGrid.ColumnsChanged;
begin
  if not Assigned(FColumns) then
    Exit;
  if FUpdatingColumnWidths then
    Exit;
  if csLoading in ComponentState then
    Exit;
  RebuildColumns;
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.SetGroupField(const Value: string);
begin
  if FGroupField = Value then
    Exit;
  FGroupField := Value;
  FGroupState.Clear;
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.SetKeyField(const Value: string);
begin
  if FKeyField = Value then
    Exit;
  FKeyField := Value;
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.SetRemoveFileNamePath(const Value: Boolean);
begin
  if FRemoveFileNamePath = Value then
    Exit;
  FRemoveFileNamePath := Value;
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.SetStartCollapsed(const Value: Boolean);
begin
  if FStartCollapsed = Value then
    Exit;
  FStartCollapsed := Value;
  FGroupState.DefaultCollapsed := Value;
  FGroupState.Clear;
  RefreshData;
end;

function TFMXCollapsibleDBGrid.GridColumn(AIndex: Integer): TColumn;
begin
  Result := inherited Columns[AIndex];
end;

procedure TFMXCollapsibleDBGrid.RebuildColumns;
var
  I: Integer;
  StringColumn: TStringColumn;
begin
  if not Assigned(FColumns) then
    Exit;
  BeginUpdate;
  try
    while ColumnCount > FColumns.Count do
      GridColumn(ColumnCount - 1).Free;

    while ColumnCount < FColumns.Count do
    begin
      StringColumn := TStringColumn.Create(Self);
      StringColumn.Stored := False;
      StringColumn.Parent := Self;
      StringColumn.ReadOnly := True;
    end;

    for I := 0 to FColumns.Count - 1 do
    begin
      GridColumn(I).Header := FColumns[I].Header;
      GridColumn(I).Width := FColumns[I].Width;
      GridColumn(I).ReadOnly := True;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TFMXCollapsibleDBGrid.RebuildRows;
var
  BuildOptions: TCollapsibleDBGridBuildOptions;
  ColIndex: Integer;
  DataSet: TDataSet;
  I: Integer;
  Prefix: string;
begin
  FRows.Clear;
  DataSet := FDataLink.DataSet;
  if FColumns.Count = 0 then
  begin
    BeginUpdate;
    try
      RowCount := 0;
    finally
      EndUpdate;
    end;
    Exit;
  end;
  if Assigned(DataSet) and DataSet.Active and
     ((not (csDesigning in ComponentState)) or FUseActiveDataAtDesignTime) then
  begin
    BuildOptions.GroupField := FGroupField;
    BuildOptions.KeyField := FKeyField;
    BuildOptions.EmptyGroupText := FShowEmptyGroupAs;
    BuildOptions.ShowEmptyGroupAs := FShowEmptyGroupAs;
    BuildOptions.RemoveFileNamePath := FRemoveFileNamePath;
    BuildOptions.Columns := FColumns;
    BuildOptions.GroupState := FGroupState;
    BuildOptions.Sender := Self;
    BuildOptions.OnGetGroupText := FOnGetGroupText;
    BuildOptions.OnGetCellText := FOnGetCellText;
    TCollapsibleDBGridRowBuilder.BuildFromDataSet(DataSet, BuildOptions, FRows);
  end
  else if FShowDesignPreview and (csDesigning in ComponentState) then
    TCollapsibleDBGridRowBuilder.BuildPreviewRows(FColumns, FDesignPreviewGroupCount,
      FDesignPreviewRowsPerGroup, FShowEmptyGroupAs, FGroupState, FRows);

  BeginUpdate;
  try
    RowCount := FRows.Count;
    for I := 0 to FRows.Count - 1 do
    begin
      if FRows[I].RowKind = crGroupHeader then
      begin
        if FGroupState.IsCollapsed(FRows[I].GroupName) then
          Prefix := '  [+] '
        else
          Prefix := '  [-] ';
        if ColumnCount > 0 then
          Cells[0, I] := Prefix + FRows[I].Values[0];
        for ColIndex := 1 to Min(ColumnCount, Length(FRows[I].Values)) - 1 do
          Cells[ColIndex, I] := FRows[I].Values[ColIndex];
      end
      else
      begin
        if ColumnCount > 0 then
          Cells[0, I] := '    ' + FRows[I].Values[0];
        for ColIndex := 1 to Min(ColumnCount, Length(FRows[I].Values)) - 1 do
          Cells[ColIndex, I] := FRows[I].Values[ColIndex];
      end;
    end;
  finally
    EndUpdate;
  end;
  if FAutoSizeColumnsAtStartup and (not FAutoSizedAtStartup) and
     CanAutoSizeColumns and Assigned(DataSet) and DataSet.Active then
  begin
    FAutoSizedAtStartup := True;
    AutoSizeColumns;
  end;
  if (csDesigning in ComponentState) and not CanAutoSizeColumns then
    FitGridWidthToColumns;
  ApplyAutoHeight;
end;

procedure TFMXCollapsibleDBGrid.RefreshData;
begin
  if csDestroying in ComponentState then
    Exit;
  Inc(FRefreshDepth);
  try
    RebuildRows;
    SyncSelectionFromDataSet(False);
    Repaint;
  finally
    Dec(FRefreshDepth);
  end;
end;

function TFMXCollapsibleDBGrid.GetRowObject(ARow: Integer;
  out AGridRow: TCollapsibleGridRow): Boolean;
begin
  Result := (ARow >= 0) and (ARow < FRows.Count);
  if Result then
    AGridRow := FRows[ARow];
end;

procedure TFMXCollapsibleDBGrid.ToggleRow(ARow: Integer);
var
  Allow: Boolean;
  GridRow: TCollapsibleGridRow;
  WasCollapsed: Boolean;
begin
  if not GetRowObject(ARow, GridRow) or (GridRow.RowKind <> crGroupHeader) then
    Exit;
  WasCollapsed := FGroupState.IsCollapsed(GridRow.GroupName);
  Allow := True;
  if WasCollapsed and Assigned(FOnBeforeGroupExpand) then
    FOnBeforeGroupExpand(Self, GridRow.GroupName, Allow)
  else if (not WasCollapsed) and Assigned(FOnBeforeGroupCollapse) then
    FOnBeforeGroupCollapse(Self, GridRow.GroupName, Allow);
  if not Allow then
    Exit;
  FGroupState.SetCollapsed(GridRow.GroupName, not WasCollapsed);
  RebuildRows;
  if WasCollapsed then
    TopRow := ARow;
  Selected := ARow;
  if WasCollapsed and Assigned(FOnGroupExpanded) then
    FOnGroupExpanded(Self, GridRow.GroupName)
  else if (not WasCollapsed) and Assigned(FOnGroupCollapsed) then
    FOnGroupCollapsed(Self, GridRow.GroupName);
end;

procedure TFMXCollapsibleDBGrid.InternalCellClick(const Column: TColumn;
  const Row: Integer);
begin
  if (Row >= 0) and (Row < FRows.Count) and (FRows[Row].RowKind = crGroupHeader) then
    ToggleRow(Row)
  else
    TrySyncDataSetFromRow(Row);
end;

procedure TFMXCollapsibleDBGrid.InternalCellDblClick(const Column: TColumn;
  const Row: Integer);
var
  GridRow: TCollapsibleGridRow;
begin
  if TrySyncDataSetFromRow(Row) and GetRowObject(Row, GridRow) and
     Assigned(FOnRowActivated) then
    FOnRowActivated(Self, GridRow);
end;

procedure TFMXCollapsibleDBGrid.InternalSelChanged(Sender: TObject);
var
  GridRow: TCollapsibleGridRow;
begin
  if FSelectionSyncDepth > 0 then
    Exit;
  TrySyncDataSetFromRow(Selected);
  if GetRowObject(Selected, GridRow) and Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self, GridRow);
end;

procedure TFMXCollapsibleDBGrid.InternalMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if (Button = TMouseButton.mbRight) and Assigned(FContextMenu) then
    FContextMenu.Popup(Round(LocalToScreen(PointF(X, Y)).X),
      Round(LocalToScreen(PointF(X, Y)).Y));
end;

procedure TFMXCollapsibleDBGrid.MouseWheel(Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  inherited MouseWheel(Shift, WheelDelta, Handled);
  if Handled then
    TrySyncDataSetFromRow(Selected);
end;

procedure TFMXCollapsibleDBGrid.InternalViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
  if not SameValue(OldViewportPosition.Y, NewViewportPosition.Y) then
    SyncDataSetFromTopVisibleRow;
end;

function TFMXCollapsibleDBGrid.RowFillColor(ARow: Integer;
  const AState: TGridDrawStates): TAlphaColor;
var
  GridRow: TCollapsibleGridRow;
begin
  if GetRowObject(ARow, GridRow) and (GridRow.RowKind = crGroupHeader) then
    Result := FGroupRowColor
  else if (TGridDrawState.Selected in AState) or
          (TGridDrawState.RowSelected in AState) then
    Result := FSelectedRowColor
  else if GetRowObject(ARow, GridRow) and Odd(GridRow.VisibleDataIndex) then
    Result := FOddRowColor
  else
    Result := $FFFFFFFF;
end;

procedure TFMXCollapsibleDBGrid.InternalDrawColumnBackground(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  FillBounds: TRectF;
begin
  UpdateMetricsForTextSettings;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := RowFillColor(Row, State);
  FillBounds := Bounds;
  FillBounds.Inflate(2, 1);
  Canvas.FillRect(FillBounds, 0, 0, [], 1);
end;

procedure TFMXCollapsibleDBGrid.InternalDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  DefaultDraw: Boolean;
  GridRow: TCollapsibleGridRow;
  FillBounds: TRectF;
  TextBounds: TRectF;
  TextValue: string;
begin
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := RowFillColor(Row, State);
  FillBounds := Bounds;
  FillBounds.Inflate(2, 1);
  Canvas.FillRect(FillBounds, 0, 0, [], 1);

  TextValue := '';
  if GetRowObject(Row, GridRow) then
  begin
    DefaultDraw := True;
    if GridRow.RowKind = crGroupHeader then
    begin
      if Assigned(FOnDrawGroupRow) then
        FOnDrawGroupRow(Self, Canvas, GridRow, Bounds, State, DefaultDraw);
    end
    else if Assigned(FOnDrawDataRow) then
      FOnDrawDataRow(Self, Canvas, GridRow, Bounds, State, DefaultDraw);
    if not DefaultDraw then
      Exit;
    TextValue := CellDisplayText(Column.Index, GridRow);
  end;
  if TextValue = '' then
    Exit;

  TextBounds := Bounds;
  TextBounds.Left := TextBounds.Left + 8;
  TextBounds.Right := TextBounds.Right - 6;
  if GridRow.RowKind = crGroupHeader then
    Canvas.Font.Assign(FGroupTextSettings.Font)
  else
    Canvas.Font.Assign(TextSettings.Font);
  Canvas.Fill.Kind := TBrushKind.Solid;
  if GridRow.RowKind = crGroupHeader then
    Canvas.Fill.Color := FGroupTextSettings.FontColor
  else
    Canvas.Fill.Color := TextSettings.FontColor;
  Canvas.FillText(TextBounds, TextValue, False, 1, [],
    TTextAlign.Leading, TTextAlign.Center);
end;

procedure TFMXCollapsibleDBGrid.InternalDrawColumnHeader(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
var
  TextBounds: TRectF;
begin
  UpdateMetricsForTextSettings;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := FHeaderRowColor;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := $FFE6F0F3;
  Canvas.DrawLine(PointF(Bounds.Right - 0.5, Bounds.Top),
    PointF(Bounds.Right - 0.5, Bounds.Bottom), 1);
  TextBounds := Bounds;
  TextBounds.Left := TextBounds.Left + 8;
  TextBounds.Right := TextBounds.Right - 6;
  Canvas.Font.Assign(FHeaderTextSettings.Font);
  Canvas.Fill.Color := FHeaderTextSettings.FontColor;
  Canvas.FillText(TextBounds, Column.Header, False, 1, [],
    TTextAlign.Leading, TTextAlign.Center);
end;

function TFMXCollapsibleDBGrid.TrySyncDataSetFromRow(ARow: Integer): Boolean;
var
  Allow: Boolean;
  DataSet: TDataSet;
  GridRow: TCollapsibleGridRow;
begin
  Result := False;
  DataSet := FDataLink.DataSet;
  if not Assigned(DataSet) or not DataSet.Active or not GetRowObject(ARow, GridRow) or
     (GridRow.RowKind <> crData) then
    Exit;
  Allow := True;
  if Assigned(FOnBeforeRowSelect) then
    FOnBeforeRowSelect(Self, GridRow, Allow);
  if not Allow then
    Exit;
  if (GridRow.RecNo > 0) and (DataSet.RecNo <> GridRow.RecNo) then
    DataSet.RecNo := GridRow.RecNo;
  Result := True;
end;

procedure TFMXCollapsibleDBGrid.SyncDataSetFromTopVisibleRow;
var
  I: Integer;
begin
  if (FRefreshDepth > 0) or (FSelectionSyncDepth > 0) or
     not Assigned(FRows) or (FRows.Count = 0) then
    Exit;

  for I := Max(0, TopRow) to FRows.Count - 1 do
    if FRows[I].RowKind = crData then
    begin
      Inc(FSelectionSyncDepth);
      try
        TrySyncDataSetFromRow(I);
      finally
        Dec(FSelectionSyncDepth);
      end;
      Break;
    end;
end;

procedure TFMXCollapsibleDBGrid.SyncSelectionFromDataSet(AExpandCurrentGroup: Boolean);
var
  DataSet: TDataSet;
  GroupName: string;
  I: Integer;
  TargetRow: Integer;
begin
  DataSet := FDataLink.DataSet;
  if not Assigned(DataSet) or not DataSet.Active or DataSet.IsEmpty or (FRows.Count = 0) then
    Exit;
  GroupName := GetCurrentGroupName(DataSet);
  TargetRow := -1;
  for I := 0 to FRows.Count - 1 do
    if (FRows[I].RowKind = crData) and (FRows[I].RecNo = DataSet.RecNo) then
    begin
      TargetRow := I;
      Break;
    end;
  if (TargetRow < 0) and AExpandCurrentGroup then
  begin
    FGroupState.SetCollapsed(GroupName, False);
    RebuildRows;
    for I := 0 to FRows.Count - 1 do
      if (FRows[I].RowKind = crData) and (FRows[I].RecNo = DataSet.RecNo) then
      begin
        TargetRow := I;
        Break;
      end;
  end;
  if TargetRow < 0 then
    for I := 0 to FRows.Count - 1 do
      if (FRows[I].RowKind = crGroupHeader) and SameText(FRows[I].GroupName, GroupName) then
      begin
        TargetRow := I;
        Break;
      end;
  if TargetRow >= 0 then
  begin
    Inc(FSelectionSyncDepth);
    try
      Selected := TargetRow;
    finally
      Dec(FSelectionSyncDepth);
    end;
  end;
end;

procedure TFMXCollapsibleDBGrid.CollapseAll;
var
  I: Integer;
begin
  for I := 0 to FRows.Count - 1 do
    if FRows[I].RowKind = crGroupHeader then
      FGroupState.SetCollapsed(FRows[I].GroupName, True);
  RefreshData;
end;

procedure TFMXCollapsibleDBGrid.ExpandAll;
var
  I: Integer;
begin
  for I := 0 to FRows.Count - 1 do
    if FRows[I].RowKind = crGroupHeader then
      FGroupState.SetCollapsed(FRows[I].GroupName, False);
  RefreshData;
end;

end.
