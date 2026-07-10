unit VCL.CollapsibleDBGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math, System.SysUtils, System.Types,
  System.UITypes, Data.DB, Vcl.Controls, Vcl.Grids, Vcl.Graphics, Vcl.Menus,
  CollapsibleDBGrid.Core, CollapsibleDBGrid.Data;

type
  TVCLCollapsibleDBGrid = class;

  TCollapsibleGridNotifyEvent = procedure(Sender: TObject; const GroupName: string) of object;
  TCollapsibleGridRowEvent = procedure(Sender: TObject; const Row: TCollapsibleGridRow) of object;
  TCollapsibleGridBeforeGroupEvent = procedure(Sender: TObject; const GroupName: string;
    var Allow: Boolean) of object;
  TCollapsibleGridBeforeRowEvent = procedure(Sender: TObject;
    const Row: TCollapsibleGridRow; var Allow: Boolean) of object;
  TCollapsibleFormatGroupHeaderEvent = procedure(Sender: TObject;
    const Row: TCollapsibleGridRow; var Text: string) of object;
  TVCLCollapsibleDrawRowEvent = procedure(Sender: TObject; Canvas: TCanvas;
    const Row: TCollapsibleGridRow; const Rect: TRect; State: TGridDrawState;
    var DefaultDraw: Boolean) of object;

  TVCLCollapsibleGridDataLink = class(TDataLink)
  private
    FGrid: TVCLCollapsibleDBGrid;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AGrid: TVCLCollapsibleDBGrid);
  end;

  TVCLCollapsibleDBGrid = class(TCustomDrawGrid, ICollapsibleDBGridColumnsChanged)
  private
    FAutoExpandSelectedGroup: Boolean;
    FAutoHeight: Boolean;
    FAutoSizeColumnsAtStartup: Boolean;
    FAutoSizedAtStartup: Boolean;
    FColumns: TCollapsibleDBGridColumns;
    FContextMenu: TPopupMenu;
    FDataLink: TVCLCollapsibleGridDataLink;
    FDesignPreviewGroupCount: Integer;
    FDesignPreviewRowsPerGroup: Integer;
    FGroupField: string;
    FGroupFont: TFont;
    FGroupRowColor: TColor;
    FGroupState: TCollapsibleGroupState;
    FHeaderFont: TFont;
    FHeaderRowColor: TColor;
    FKeyField: string;
    FOnBeforeGroupCollapse: TCollapsibleGridBeforeGroupEvent;
    FOnBeforeGroupExpand: TCollapsibleGridBeforeGroupEvent;
    FOnBeforeRowSelect: TCollapsibleGridBeforeRowEvent;
    FOnDrawDataRow: TVCLCollapsibleDrawRowEvent;
    FOnDrawGroupRow: TVCLCollapsibleDrawRowEvent;
    FOnFormatGroupHeader: TCollapsibleFormatGroupHeaderEvent;
    FOddRowColor: TColor;
    FOnGetCellText: TCollapsibleGetCellTextEvent;
    FOnGetGroupText: TCollapsibleGetGroupTextEvent;
    FOnGroupCollapsed: TCollapsibleGridNotifyEvent;
    FOnGroupExpanded: TCollapsibleGridNotifyEvent;
    FOnRowActivated: TCollapsibleGridRowEvent;
    FOnSelectionChanged: TCollapsibleGridRowEvent;
    FRemoveFileNamePath: Boolean;
    FRows: TCollapsibleGridRows;
    FRefreshDepth: Integer;
    FScrollBarRefreshPending: Boolean;
    FSelectionSyncDepth: Integer;
    FSelectedRowColor: TColor;
    FShowDesignPreview: Boolean;
    FShowEmptyGroupAs: string;
    FStartCollapsed: Boolean;
    FUpdatingColumnWidths: Boolean;
    FUseActiveDataAtDesignTime: Boolean;
    function DataRowIndex(AGridRow: Integer): Integer;
    function EffectiveColCount: Integer;
    function EffectiveRowCount: Integer;
    function GetCurrentGroupName(ADataSet: TDataSet): string;
    function GetDataSource: TDataSource;
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
    procedure GroupFontChanged(Sender: TObject);
    procedure HeaderFontChanged(Sender: TObject);
    procedure IgnoreStreamedGridLayout(Reader: TReader);
    procedure SetColumns(const Value: TCollapsibleDBGridColumns);
    procedure SetAutoHeight(const Value: Boolean);
    procedure SetGroupFont(const Value: TFont);
    procedure SetGroupRowColor(const Value: TColor);
    procedure SetHeaderFont(const Value: TFont);
    procedure SetHeaderRowColor(const Value: TColor);
    procedure SetOddRowColor(const Value: TColor);
    procedure SetSelectedRowColor(const Value: TColor);
    procedure SetDataSource(const Value: TDataSource);
    procedure SetGroupField(const Value: string);
    procedure SetKeyField(const Value: string);
    procedure SetRemoveFileNamePath(const Value: Boolean);
    procedure SetStartCollapsed(const Value: Boolean);
    procedure RefreshScrollBars;
    procedure ToggleRow(ARow: Integer);
    function TrySyncDataSetFromRow(ARow: Integer): Boolean;
    procedure SyncDataSetFromTopVisibleRow;
    procedure UpdateMetricsForFont;
    procedure ColumnsChanged;
  protected
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure RebuildRows;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure SyncSelectionFromDataSet(AExpandCurrentGroup: Boolean);
    procedure TopLeftChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CollapseAll;
    procedure ExpandAll;
    procedure RefreshData;
    property Rows: TCollapsibleGridRows read FRows;
  published
    property Align;
    property Anchors;
    property Color;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Font;
    property HeaderFont: TFont read FHeaderFont write SetHeaderFont;
    property HeaderRowColor: TColor read FHeaderRowColor write SetHeaderRowColor default $007D6810;
    property Options;
    property ScrollBars;
    property GroupField: string read FGroupField write SetGroupField;
    property GroupFont: TFont read FGroupFont write SetGroupFont;
    property GroupRowColor: TColor read FGroupRowColor write SetGroupRowColor default $00F8EDE3;
    property OddRowColor: TColor read FOddRowColor write SetOddRowColor default $00F7F7F7;
    property SelectedRowColor: TColor read FSelectedRowColor write SetSelectedRowColor default $00FAE8D7;
    property KeyField: string read FKeyField write SetKeyField;
    property ParentColor;
    property ParentFont;
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
    property OnDrawGroupRow: TVCLCollapsibleDrawRowEvent read FOnDrawGroupRow write FOnDrawGroupRow;
    property OnDrawDataRow: TVCLCollapsibleDrawRowEvent read FOnDrawDataRow write FOnDrawDataRow;
    property OnGroupExpanded: TCollapsibleGridNotifyEvent read FOnGroupExpanded write FOnGroupExpanded;
    property OnGroupCollapsed: TCollapsibleGridNotifyEvent read FOnGroupCollapsed write FOnGroupCollapsed;
    property OnRowActivated: TCollapsibleGridRowEvent read FOnRowActivated write FOnRowActivated;
    property OnSelectionChanged: TCollapsibleGridRowEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;

implementation

constructor TVCLCollapsibleGridDataLink.Create(AGrid: TVCLCollapsibleDBGrid);
begin
  inherited Create;
  FGrid := AGrid;
end;

procedure TVCLCollapsibleGridDataLink.ActiveChanged;
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

procedure TVCLCollapsibleGridDataLink.DataSetChanged;
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

procedure TVCLCollapsibleGridDataLink.DataSetScrolled(Distance: Integer);
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) and (FGrid.FSelectionSyncDepth = 0) then
    FGrid.SyncSelectionFromDataSet(FGrid.FAutoExpandSelectedGroup);
end;

procedure TVCLCollapsibleGridDataLink.RecordChanged(Field: TField);
begin
  if Assigned(FGrid) and not (csDestroying in FGrid.ComponentState) and
     (FGrid.FRefreshDepth = 0) then
    FGrid.RefreshData;
end;

constructor TVCLCollapsibleDBGrid.Create(AOwner: TComponent);
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
  FGroupState.DefaultCollapsed := True;
  FGroupRowColor := $00F8EDE3;
  FGroupFont := TFont.Create;
  FGroupFont.Assign(Font);
  FGroupFont.OnChange := GroupFontChanged;
  FHeaderRowColor := $007D6810;
  FOddRowColor := $00F7F7F7;
  FSelectedRowColor := $00FAE8D7;
  FHeaderFont := TFont.Create;
  FHeaderFont.Assign(Font);
  FHeaderFont.Color := clWhite;
  FHeaderFont.Style := FHeaderFont.Style + [fsBold];
  FHeaderFont.OnChange := HeaderFontChanged;
  FDataLink := TVCLCollapsibleGridDataLink.Create(Self);
  DefaultDrawing := False;
  FixedCols := 0;
  FixedRows := 0;
  Options := Options + [goRowSelect] - [goEditing];
  ColCount := EffectiveColCount;
  RowCount := EffectiveRowCount;
  UpdateMetricsForFont;
  CreateContextMenu;
end;

destructor TVCLCollapsibleDBGrid.Destroy;
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
  FreeAndNil(FGroupFont);
  FreeAndNil(FHeaderFont);
end;

procedure TVCLCollapsibleDBGrid.CreateContextMenu;

  procedure AddItem(const ACaption: string; AOnClick: TNotifyEvent);
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(FContextMenu);
    Item.Caption := ACaption;
    Item.OnClick := AOnClick;
    FContextMenu.Items.Add(Item);
  end;

begin
  FContextMenu := TPopupMenu.Create(Self);
  AddItem('Expand All Groups', ContextExpandAllGroups);
  AddItem('Collapse All Groups', ContextCollapseAllGroups);
end;

procedure TVCLCollapsibleDBGrid.Loaded;
begin
  inherited Loaded;
  UpdateMetricsForFont;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty('RowHeights', IgnoreStreamedGridLayout, nil, False);
  Filer.DefineProperty('ColWidths', IgnoreStreamedGridLayout, nil, False);
end;

procedure TVCLCollapsibleDBGrid.IgnoreStreamedGridLayout(Reader: TReader);
begin
  Reader.SkipValue;
end;

procedure TVCLCollapsibleDBGrid.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateMetricsForFont;
  if FAutoSizeColumnsAtStartup and CanAutoSizeColumns then
    AutoSizeColumns;
end;

procedure TVCLCollapsibleDBGrid.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing and FScrollBarRefreshPending then
  begin
    FScrollBarRefreshPending := False;
    RefreshScrollBars;
  end;
end;

procedure TVCLCollapsibleDBGrid.HeaderFontChanged(Sender: TObject);
begin
  UpdateMetricsForFont;
  if FAutoSizeColumnsAtStartup and CanAutoSizeColumns then
    AutoSizeColumns;
end;

procedure TVCLCollapsibleDBGrid.GroupFontChanged(Sender: TObject);
begin
  UpdateMetricsForFont;
  if FAutoSizeColumnsAtStartup and CanAutoSizeColumns then
    AutoSizeColumns;
end;

procedure TVCLCollapsibleDBGrid.SetGroupFont(const Value: TFont);
begin
  FGroupFont.Assign(Value);
end;

procedure TVCLCollapsibleDBGrid.SetGroupRowColor(const Value: TColor);
begin
  if FGroupRowColor = Value then
    Exit;
  FGroupRowColor := Value;
  Invalidate;
end;

procedure TVCLCollapsibleDBGrid.SetHeaderFont(const Value: TFont);
begin
  FHeaderFont.Assign(Value);
end;

procedure TVCLCollapsibleDBGrid.SetHeaderRowColor(const Value: TColor);
begin
  if FHeaderRowColor = Value then
    Exit;
  FHeaderRowColor := Value;
  Invalidate;
end;

procedure TVCLCollapsibleDBGrid.SetOddRowColor(const Value: TColor);
begin
  if FOddRowColor = Value then
    Exit;
  FOddRowColor := Value;
  Invalidate;
end;

procedure TVCLCollapsibleDBGrid.SetSelectedRowColor(const Value: TColor);
begin
  if FSelectedRowColor = Value then
    Exit;
  FSelectedRowColor := Value;
  Invalidate;
end;

procedure TVCLCollapsibleDBGrid.UpdateMetricsForFont;
var
  I: Integer;
  NewHeaderHeight: Integer;
  NewRowHeight: Integer;
begin
  Canvas.Font.Assign(Font);
  NewRowHeight := Max(20, Canvas.TextHeight('Wg') + 8);
  Canvas.Font.Assign(FGroupFont);
  NewRowHeight := Max(NewRowHeight, Canvas.TextHeight('Wg') + 8);
  if DefaultRowHeight <> NewRowHeight then
    DefaultRowHeight := NewRowHeight;
  for I := 0 to RowCount - 1 do
    RowHeights[I] := NewRowHeight;
  if FixedRows > 0 then
  begin
    Canvas.Font.Assign(FHeaderFont);
    NewHeaderHeight := Max(NewRowHeight, Canvas.TextHeight('Wg') + 8);
    RowHeights[0] := NewHeaderHeight;
  end;
  Invalidate;
  ApplyAutoHeight;
  RefreshScrollBars;
end;

procedure TVCLCollapsibleDBGrid.RefreshScrollBars;
begin
  if csLoading in ComponentState then
  begin
    FScrollBarRefreshPending := True;
    Exit;
  end;
  if not HandleAllocated or not Showing then
  begin
    FScrollBarRefreshPending := True;
    Exit;
  end;
  Perform(WM_SIZE, SIZE_RESTORED, MakeLParam(ClientWidth, ClientHeight));
  Invalidate;
end;

procedure TVCLCollapsibleDBGrid.ApplyAutoHeight;
var
  DesiredClientHeight: Integer;
  DesiredHeight: Integer;
  MaxHeight: Integer;
  MaxClientHeight: Integer;
  NextClientHeight: Integer;
  NonClientHeight: Integer;
  RowIndex: Integer;
  SnappedClientHeight: Integer;
begin
  if not FAutoHeight or (Align <> alNone) or (csLoading in ComponentState) then
    Exit;

  DesiredClientHeight := GridLineWidth;
  for RowIndex := 0 to RowCount - 1 do
    Inc(DesiredClientHeight, RowHeights[RowIndex] + GridLineWidth);

  if Width < 4 then
    Exit;

  NonClientHeight := Height - ClientHeight;
  DesiredHeight := Height + DesiredClientHeight - ClientHeight;
  MaxHeight := MaxInt;
  if Assigned(Parent) and not (csDesigning in ComponentState) then
    MaxHeight := Max(24, Parent.ClientHeight - Top - 8);

  if DesiredHeight > MaxHeight then
  begin
    MaxClientHeight := Max(1, MaxHeight - NonClientHeight);
    SnappedClientHeight := GridLineWidth;
    for RowIndex := 0 to RowCount - 1 do
    begin
      NextClientHeight := SnappedClientHeight + RowHeights[RowIndex] + GridLineWidth;
      if NextClientHeight > MaxClientHeight then
        Break;
      SnappedClientHeight := NextClientHeight;
    end;
    Height := Max(24, NonClientHeight + SnappedClientHeight);
  end
  else
    Height := Max(24, DesiredHeight);
end;

procedure TVCLCollapsibleDBGrid.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Assigned(FDataLink) and (Operation = opRemove) and
     (AComponent = FDataLink.DataSource) then
    DataSource := nil;
end;

function TVCLCollapsibleDBGrid.GetDataSource: TDataSource;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.DataSource
  else
    Result := nil;
end;

function TVCLCollapsibleDBGrid.EffectiveColCount: Integer;
begin
  Result := 1;
  if Assigned(FColumns) and (FColumns.Count > Result) then
    Result := FColumns.Count;
end;

function TVCLCollapsibleDBGrid.DataRowIndex(AGridRow: Integer): Integer;
begin
  Result := AGridRow - FixedRows;
end;

function TVCLCollapsibleDBGrid.EffectiveRowCount: Integer;
begin
  Result := 1;
  if Assigned(FColumns) and (FColumns.Count > 0) then
  begin
    Result := 2;
    if Assigned(FRows) and (FRows.Count > 0) then
      Result := FRows.Count + 1;
  end;
end;

function TVCLCollapsibleDBGrid.GetCurrentGroupName(ADataSet: TDataSet): string;
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

function TVCLCollapsibleDBGrid.BuildAutoSizeRows: TCollapsibleGridRows;
var
  BuildOptions: TCollapsibleDBGridBuildOptions;
  DataSet: TDataSet;
  GroupState: TCollapsibleGroupState;
  I: Integer;
begin
  Result := TCollapsibleGridRows.Create;
  try
    DataSet := nil;
    if Assigned(FDataLink) then
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

function TVCLCollapsibleDBGrid.CellDisplayText(ACol: Integer;
  const ARow: TCollapsibleGridRow): string;
var
  Prefix: string;
  Text: string;
begin
  Result := '';
  if (ACol < 0) or (ACol >= Length(ARow.Values)) then
    Exit;
  Prefix := '';
  if ARow.RowKind = crGroupHeader then
  begin
    if ACol = 0 then
      if FGroupState.IsCollapsed(ARow.GroupName) then
        Prefix := '  [+] '
      else
        Prefix := '  [-] ';
  end
  else if ACol = 0 then
    Prefix := '    ';
  Text := ARow.Values[ACol];
  if (ACol = 0) and (ARow.RowKind = crGroupHeader) and Assigned(FOnFormatGroupHeader) then
    FOnFormatGroupHeader(Self, ARow, Text);
  Result := Prefix + Text;
end;

procedure TVCLCollapsibleDBGrid.FitGridWidthToColumns;
var
  I: Integer;
  NewWidth: Integer;
begin
  if Align <> alNone then
    Exit;
  NewWidth := 4;
  for I := 0 to FColumns.Count - 1 do
    Inc(NewWidth, ColWidths[I] + GridLineWidth);
  Inc(NewWidth, GetSystemMetrics(SM_CXVSCROLL));
  Width := Max(32, NewWidth);
  ApplyAutoHeight;
end;

procedure TVCLCollapsibleDBGrid.AutoSizeColumn(ACol: Integer;
  ARows: TCollapsibleGridRows);
var
  DataIndex: Integer;
  HeaderText: string;
  NewWidth: Integer;
begin
  if not Assigned(FColumns) or (ACol < 0) or (ACol >= FColumns.Count) then
    Exit;
  HeaderText := FColumns[ACol].Header;
  if HeaderText = '' then
    HeaderText := FColumns[ACol].FieldName;
  Canvas.Font.Assign(FHeaderFont);
  NewWidth := Canvas.TextWidth(HeaderText) + 18;
  if Assigned(ARows) then
    for DataIndex := 0 to ARows.Count - 1 do
    begin
      if ARows[DataIndex].RowKind = crGroupHeader then
        Canvas.Font.Assign(FGroupFont)
      else
        Canvas.Font.Assign(Font);
      NewWidth := Max(NewWidth, Canvas.TextWidth(CellDisplayText(ACol, ARows[DataIndex])) + 18);
    end;
  NewWidth := Max(NewWidth, 32);
  ColWidths[ACol] := NewWidth;
  FUpdatingColumnWidths := True;
  try
    FColumns[ACol].Width := NewWidth;
  finally
    FUpdatingColumnWidths := False;
  end;
end;

procedure TVCLCollapsibleDBGrid.AutoSizeColumns;
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

function TVCLCollapsibleDBGrid.CanAutoSizeColumns: Boolean;
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

procedure TVCLCollapsibleDBGrid.ContextCollapseAllGroups(Sender: TObject);
begin
  CollapseAll;
end;

procedure TVCLCollapsibleDBGrid.ContextExpandAllGroups(Sender: TObject);
begin
  ExpandAll;
end;

procedure TVCLCollapsibleDBGrid.SetDataSource(const Value: TDataSource);
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

procedure TVCLCollapsibleDBGrid.SetAutoHeight(const Value: Boolean);
begin
  if FAutoHeight = Value then
    Exit;
  FAutoHeight := Value;
  ApplyAutoHeight;
end;

procedure TVCLCollapsibleDBGrid.SetColumns(
  const Value: TCollapsibleDBGridColumns);
begin
  FColumns.Assign(Value);
  ColumnsChanged;
end;

procedure TVCLCollapsibleDBGrid.ColumnsChanged;
begin
  if not Assigned(FColumns) then
    Exit;
  if FUpdatingColumnWidths then
    Exit;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.SetGroupField(const Value: string);
begin
  if FGroupField = Value then
    Exit;
  FGroupField := Value;
  FGroupState.Clear;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.SetKeyField(const Value: string);
begin
  if FKeyField = Value then
    Exit;
  FKeyField := Value;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.SetRemoveFileNamePath(const Value: Boolean);
begin
  if FRemoveFileNamePath = Value then
    Exit;
  FRemoveFileNamePath := Value;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.SetStartCollapsed(const Value: Boolean);
begin
  if FStartCollapsed = Value then
    Exit;
  FStartCollapsed := Value;
  FGroupState.DefaultCollapsed := Value;
  FGroupState.Clear;
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.RebuildRows;
var
  BuildOptions: TCollapsibleDBGridBuildOptions;
  DataSet: TDataSet;
  I: Integer;
begin
  FRows.Clear;
  if not Assigned(FDataLink) then
    Exit;
  if FColumns.Count = 0 then
  begin
    BeginUpdate;
    try
      FixedRows := 0;
      ColCount := EffectiveColCount;
      RowCount := EffectiveRowCount;
    finally
      EndUpdate;
    end;
    Exit;
  end;
  DataSet := FDataLink.DataSet;
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
    ColCount := EffectiveColCount;
    if FColumns.Count > 0 then
    begin
      RowCount := EffectiveRowCount;
      FixedRows := 1;
    end
    else
    begin
      FixedRows := 0;
      RowCount := EffectiveRowCount;
    end;
    for I := 0 to FColumns.Count - 1 do
      ColWidths[I] := FColumns[I].Width;
  finally
    EndUpdate;
  end;
  UpdateMetricsForFont;
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

procedure TVCLCollapsibleDBGrid.RefreshData;
begin
  if csDestroying in ComponentState then
    Exit;
  Inc(FRefreshDepth);
  try
    try
      RebuildRows;
      SyncSelectionFromDataSet(False);
      Invalidate;
    except
      on Exception do
      begin
        if not (csDesigning in ComponentState) then
          raise;
        if Assigned(FRows) then
          FRows.Clear;
        ColCount := EffectiveColCount;
        RowCount := EffectiveRowCount;
        Invalidate;
      end;
    end;
  finally
    Dec(FRefreshDepth);
  end;
end;

procedure TVCLCollapsibleDBGrid.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DataIndex: Integer;
  Row: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Assigned(FRows) then
    Exit;
  MouseToCell(X, Y, DataIndex, Row);
  if Button = mbRight then
  begin
    if Assigned(FContextMenu) then
      FContextMenu.Popup(ClientToScreen(Point(X, Y)).X, ClientToScreen(Point(X, Y)).Y);
    Exit;
  end;
  DataIndex := DataRowIndex(Row);
  if (Button = mbLeft) and (DataIndex >= 0) then
  begin
    if (DataIndex < FRows.Count) and (FRows[DataIndex].RowKind = crGroupHeader) then
      ToggleRow(DataIndex)
    else
      TrySyncDataSetFromRow(DataIndex);
  end;
end;

function TVCLCollapsibleDBGrid.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  DataRowHeight: Integer;
  HeaderHeight: Integer;
  I: Integer;
  MaxTopRow: Integer;
  NewTopRow: Integer;
  VisibleRows: Integer;
begin
  Result := True;
  if not Assigned(FRows) or (FRows.Count = 0) or (RowCount <= FixedRows) then
    Exit;

  HeaderHeight := 0;
  for I := 0 to FixedRows - 1 do
    Inc(HeaderHeight, RowHeights[I] + GridLineWidth);

  DataRowHeight := Max(1, DefaultRowHeight + GridLineWidth);
  VisibleRows := Max(1, (ClientHeight - HeaderHeight) div DataRowHeight);
  MaxTopRow := Max(FixedRows, RowCount - VisibleRows);

  NewTopRow := TopRow;
  if WheelDelta > 0 then
    Dec(NewTopRow)
  else if WheelDelta < 0 then
    Inc(NewTopRow);
  NewTopRow := EnsureRange(NewTopRow, FixedRows, MaxTopRow);

  if TopRow <> NewTopRow then
    TopRow := NewTopRow
  else
    SyncDataSetFromTopVisibleRow;
end;

procedure TVCLCollapsibleDBGrid.DblClick;
var
  DataIndex: Integer;
begin
  inherited DblClick;
  DataIndex := DataRowIndex(Row);
  if Assigned(FRows) and (DataIndex >= 0) and (DataIndex < FRows.Count) and TrySyncDataSetFromRow(DataIndex) and
     Assigned(FOnRowActivated) then
    FOnRowActivated(Self, FRows[DataIndex]);
end;

procedure TVCLCollapsibleDBGrid.TopLeftChanged;
begin
  inherited TopLeftChanged;
  SyncDataSetFromTopVisibleRow;
end;

function TVCLCollapsibleDBGrid.SelectCell(ACol, ARow: Integer): Boolean;
var
  DataIndex: Integer;
begin
  if not Assigned(FRows) then
  begin
    Result := inherited SelectCell(ACol, ARow);
    Exit;
  end;
  Result := inherited SelectCell(ACol, ARow);
  DataIndex := DataRowIndex(ARow);
  if Result and (FSelectionSyncDepth = 0) and (DataIndex >= 0) and
     (DataIndex < FRows.Count) and Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self, FRows[DataIndex]);
end;

procedure TVCLCollapsibleDBGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  DataIndex: Integer;
  DefaultDraw: Boolean;
  Prefix: string;
  Text: string;
begin
  Canvas.Font.Assign(Font);
  if (FixedRows > 0) and (ARow < FixedRows) then
  begin
    Canvas.Brush.Color := FHeaderRowColor;
    Canvas.Font.Assign(FHeaderFont);
    Canvas.FillRect(ARect);
    if Assigned(FColumns) and (ACol >= 0) and (ACol < FColumns.Count) then
    begin
      Text := FColumns[ACol].Header;
      if Text = '' then
        Text := FColumns[ACol].FieldName;
      InflateRect(ARect, -6, 0);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), ARect,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    end;
    Exit;
  end;

  DataIndex := DataRowIndex(ARow);
  if Assigned(FRows) and (DataIndex >= 0) and (DataIndex < FRows.Count) and
     (FRows[DataIndex].RowKind = crGroupHeader) then
    Canvas.Brush.Color := FGroupRowColor
  else if gdSelected in AState then
    Canvas.Brush.Color := FSelectedRowColor
  else if Assigned(FRows) and (DataIndex >= 0) and (DataIndex < FRows.Count) and
          Odd(FRows[DataIndex].VisibleDataIndex) then
    Canvas.Brush.Color := FOddRowColor
  else
    Canvas.Brush.Color := Color;
  Canvas.FillRect(ARect);
  if not Assigned(FRows) or (DataIndex < 0) or (DataIndex >= FRows.Count) or
     (ACol < 0) or (ACol >= Length(FRows[DataIndex].Values)) then
    Exit;
  DefaultDraw := True;
  if FRows[DataIndex].RowKind = crGroupHeader then
  begin
    if Assigned(FOnDrawGroupRow) then
      FOnDrawGroupRow(Self, Canvas, FRows[DataIndex], ARect, AState, DefaultDraw);
  end
  else if Assigned(FOnDrawDataRow) then
    FOnDrawDataRow(Self, Canvas, FRows[DataIndex], ARect, AState, DefaultDraw);
  if not DefaultDraw then
    Exit;
  Prefix := '';
  if FRows[DataIndex].RowKind = crGroupHeader then
  begin
    Canvas.Font.Assign(FGroupFont);
    if ACol = 0 then
      if FGroupState.IsCollapsed(FRows[DataIndex].GroupName) then
        Prefix := '  [+] '
      else
        Prefix := '  [-] ';
  end
  else if ACol = 0 then
    Prefix := '    ';
  Text := Prefix + FRows[DataIndex].Values[ACol];
  InflateRect(ARect, -6, 0);
  DrawText(Canvas.Handle, PChar(Text), Length(Text), ARect,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
end;

procedure TVCLCollapsibleDBGrid.ToggleRow(ARow: Integer);
var
  Allow: Boolean;
  WasCollapsed: Boolean;
  GroupName: string;
begin
  if not Assigned(FRows) or (ARow < 0) or (ARow >= FRows.Count) or
     (FRows[ARow].RowKind <> crGroupHeader) then
    Exit;
  GroupName := FRows[ARow].GroupName;
  WasCollapsed := FGroupState.IsCollapsed(GroupName);
  Allow := True;
  if WasCollapsed and Assigned(FOnBeforeGroupExpand) then
    FOnBeforeGroupExpand(Self, GroupName, Allow)
  else if (not WasCollapsed) and Assigned(FOnBeforeGroupCollapse) then
    FOnBeforeGroupCollapse(Self, GroupName, Allow);
  if not Allow then
    Exit;
  FGroupState.SetCollapsed(GroupName, not WasCollapsed);
  RebuildRows;
  Row := ARow + FixedRows;
  if WasCollapsed and Assigned(FOnGroupExpanded) then
    FOnGroupExpanded(Self, GroupName)
  else if (not WasCollapsed) and Assigned(FOnGroupCollapsed) then
    FOnGroupCollapsed(Self, GroupName);
end;

function TVCLCollapsibleDBGrid.TrySyncDataSetFromRow(ARow: Integer): Boolean;
var
  Allow: Boolean;
  DataSet: TDataSet;
begin
  Result := False;
  if not Assigned(FDataLink) or not Assigned(FRows) then
    Exit;
  DataSet := FDataLink.DataSet;
  if not Assigned(DataSet) or not DataSet.Active or (ARow < 0) or
     (ARow >= FRows.Count) or (FRows[ARow].RowKind <> crData) then
    Exit;
  Allow := True;
  if Assigned(FOnBeforeRowSelect) then
    FOnBeforeRowSelect(Self, FRows[ARow], Allow);
  if not Allow then
    Exit;
  if (FRows[ARow].RecNo > 0) and (DataSet.RecNo <> FRows[ARow].RecNo) then
    DataSet.RecNo := FRows[ARow].RecNo;
  Result := True;
end;

procedure TVCLCollapsibleDBGrid.SyncDataSetFromTopVisibleRow;
var
  DataIndex: Integer;
  GridRow: Integer;
begin
  if (FRefreshDepth > 0) or (FSelectionSyncDepth > 0) or
     not Assigned(FRows) or (FRows.Count = 0) then
    Exit;

  for GridRow := Max(FixedRows, TopRow) to RowCount - 1 do
  begin
    DataIndex := DataRowIndex(GridRow);
    if (DataIndex >= 0) and (DataIndex < FRows.Count) and
       (FRows[DataIndex].RowKind = crData) then
    begin
      Inc(FSelectionSyncDepth);
      try
        TrySyncDataSetFromRow(DataIndex);
      finally
        Dec(FSelectionSyncDepth);
      end;
      Break;
    end;
  end;
end;

procedure TVCLCollapsibleDBGrid.SyncSelectionFromDataSet(AExpandCurrentGroup: Boolean);
var
  DataSet: TDataSet;
  GroupName: string;
  I: Integer;
  TargetRow: Integer;
begin
  if not Assigned(FDataLink) or not Assigned(FRows) then
    Exit;
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
      Row := TargetRow + FixedRows;
    finally
      Dec(FSelectionSyncDepth);
    end;
  end;
end;

procedure TVCLCollapsibleDBGrid.CollapseAll;
var
  I: Integer;
begin
  if not Assigned(FRows) then
    Exit;
  for I := 0 to FRows.Count - 1 do
    if FRows[I].RowKind = crGroupHeader then
      FGroupState.SetCollapsed(FRows[I].GroupName, True);
  RefreshData;
end;

procedure TVCLCollapsibleDBGrid.ExpandAll;
var
  I: Integer;
begin
  if not Assigned(FRows) then
    Exit;
  for I := 0 to FRows.Count - 1 do
    if FRows[I].RowKind = crGroupHeader then
      FGroupState.SetCollapsed(FRows[I].GroupName, False);
  RefreshData;
end;

end.
