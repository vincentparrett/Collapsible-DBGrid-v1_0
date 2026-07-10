unit CollapsibleDBGrid.Data;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, Data.DB,
  CollapsibleDBGrid.Core;

type
  TCollapsibleDBGridColumn = class(TCollectionItem)
  private
    FFieldName: string;
    FHeader: string;
    FWidth: Integer;
    procedure SetFieldName(const Value: string);
    procedure SetHeader(const Value: string);
    procedure SetWidth(const Value: Integer);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
  published
    property FieldName: string read FFieldName write SetFieldName;
    property Header: string read FHeader write SetHeader;
    property Width: Integer read FWidth write SetWidth default 120;
  end;

  TCollapsibleDBGridColumns = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCollapsibleDBGridColumn;
    procedure SetItem(Index: Integer; const Value: TCollapsibleDBGridColumn);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TCollapsibleDBGridColumn;
    procedure Update(Item: TCollectionItem); override;
    property Items[Index: Integer]: TCollapsibleDBGridColumn read GetItem write SetItem; default;
  end;

  ICollapsibleDBGridColumnsChanged = interface
    ['{91E1A997-1057-45D6-8394-C34DD40D132F}']
    procedure ColumnsChanged;
  end;

  TCollapsibleGetGroupTextEvent = procedure(Sender: TObject; DataSet: TDataSet;
    const GroupValue: string; var GroupText: string) of object;
  TCollapsibleGetCellTextEvent = procedure(Sender: TObject; DataSet: TDataSet;
    Column: TCollapsibleDBGridColumn; var CellText: string) of object;

  TCollapsibleDBGridBuildOptions = record
    GroupField: string;
    KeyField: string;
    EmptyGroupText: string;
    ShowEmptyGroupAs: string;
    RemoveFileNamePath: Boolean;
    Columns: TCollapsibleDBGridColumns;
    GroupState: TCollapsibleGroupState;
    Sender: TObject;
    OnGetGroupText: TCollapsibleGetGroupTextEvent;
    OnGetCellText: TCollapsibleGetCellTextEvent;
  end;

  TCollapsibleDBGridRowBuilder = class
  public
    class procedure BuildFromDataSet(ADataSet: TDataSet;
      const AOptions: TCollapsibleDBGridBuildOptions; ARows: TCollapsibleGridRows); static;
    class procedure BuildPreviewRows(const AColumns: TCollapsibleDBGridColumns;
      const AGroupCount, ARowsPerGroup: Integer; const AEmptyGroupText: string;
      AGroupState: TCollapsibleGroupState; ARows: TCollapsibleGridRows); static;
  end;

implementation

function FieldText(ADataSet: TDataSet; const AFieldName: string): string;
var
  Field: TField;
begin
  Result := '';
  if (ADataSet = nil) or (AFieldName = '') then
    Exit;
  Field := ADataSet.FindField(AFieldName);
  if Assigned(Field) and not Field.IsNull then
    Result := Field.AsString;
end;

function RemoveFilePathIfPresent(const AValue: string): string;
var
  Candidate: string;
begin
  Result := AValue;
  Candidate := Trim(AValue);
  if Candidate = '' then
    Exit;
  if (LastDelimiter('\/', Candidate) = 0) then
    Exit;
  Candidate := ExcludeTrailingPathDelimiter(Candidate);
  if Candidate = '' then
    Exit;
  Result := ExtractFileName(Candidate);
  if Result = '' then
    Result := AValue;
end;

constructor TCollapsibleDBGridColumn.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FWidth := 120;
end;

function TCollapsibleDBGridColumn.GetDisplayName: string;
begin
  Result := FHeader;
  if Result = '' then
    Result := FFieldName;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TCollapsibleDBGridColumn.SetFieldName(const Value: string);
begin
  if FFieldName = Value then
    Exit;
  FFieldName := Value;
  Changed(False);
end;

procedure TCollapsibleDBGridColumn.SetHeader(const Value: string);
begin
  if FHeader = Value then
    Exit;
  FHeader := Value;
  Changed(False);
end;

procedure TCollapsibleDBGridColumn.SetWidth(const Value: Integer);
begin
  if FWidth = Value then
    Exit;
  FWidth := Value;
  Changed(False);
end;

constructor TCollapsibleDBGridColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCollapsibleDBGridColumn);
end;

function TCollapsibleDBGridColumns.Add: TCollapsibleDBGridColumn;
begin
  Result := inherited Add as TCollapsibleDBGridColumn;
end;

function TCollapsibleDBGridColumns.GetItem(Index: Integer): TCollapsibleDBGridColumn;
begin
  Result := inherited Items[Index] as TCollapsibleDBGridColumn;
end;

procedure TCollapsibleDBGridColumns.SetItem(Index: Integer;
  const Value: TCollapsibleDBGridColumn);
begin
  inherited Items[Index] := Value;
end;

procedure TCollapsibleDBGridColumns.Update(Item: TCollectionItem);
var
  Listener: ICollapsibleDBGridColumnsChanged;
begin
  inherited Update(Item);
  if Supports(Owner, ICollapsibleDBGridColumnsChanged, Listener) then
    Listener.ColumnsChanged;
end;

class procedure TCollapsibleDBGridRowBuilder.BuildFromDataSet(ADataSet: TDataSet;
  const AOptions: TCollapsibleDBGridBuildOptions; ARows: TCollapsibleGridRows);
var
  CurrentGroup: string;
  CurrentRows: TCollapsibleGridRows;
  CurrentSongCount: Integer;
  I: Integer;
  SavedBookmark: TBookmark;
  Row: TCollapsibleGridRow;
  Header: TCollapsibleGridRow;
  VisibleIndex: Integer;

  procedure FlushGroup;
  var
    J: Integer;
    Suffix: string;
  begin
    if CurrentGroup = '' then
      Exit;
    Header := Default(TCollapsibleGridRow);
    SetLength(Header.Values, AOptions.Columns.Count);
    Header.RowKind := crGroupHeader;
    Header.GroupName := CurrentGroup;
    Header.RecNo := 0;
    Header.KeyValue := '';
    Header.VisibleDataIndex := -1;
    if CurrentSongCount = 1 then
      Suffix := ''
    else
      Suffix := 's';
    Header.GroupText := Format('%s (%d row%s)', [CurrentGroup, CurrentSongCount, Suffix]);
    if AOptions.Columns.Count > 0 then
      Header.Values[0] := Header.GroupText;
    ARows.Add(Header);
    if not AOptions.GroupState.IsCollapsed(CurrentGroup) then
      for J := 0 to CurrentRows.Count - 1 do
      begin
        Row := CurrentRows[J];
        Row.VisibleDataIndex := VisibleIndex;
        Inc(VisibleIndex);
        ARows.Add(Row);
      end;
  end;

var
  Column: TCollapsibleDBGridColumn;
  GroupText: string;
begin
  ARows.Clear;
  if (ADataSet = nil) or not ADataSet.Active or ADataSet.IsEmpty or
     (AOptions.GroupState = nil) then
    Exit;

  CurrentRows := TCollapsibleGridRows.Create;
  SavedBookmark := nil;
  try
    SavedBookmark := ADataSet.GetBookmark;
    ADataSet.DisableControls;
    try
      CurrentGroup := '';
      CurrentSongCount := 0;
      VisibleIndex := 0;
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        GroupText := CollapsibleNormalizeGroupName(FieldText(ADataSet, AOptions.GroupField),
          AOptions.EmptyGroupText);
        if Assigned(AOptions.OnGetGroupText) then
          AOptions.OnGetGroupText(AOptions.Sender, ADataSet, GroupText, GroupText);

        if (CurrentGroup <> '') and not SameText(CurrentGroup, GroupText) then
        begin
          FlushGroup;
          CurrentRows.Clear;
          CurrentSongCount := 0;
        end;
        CurrentGroup := GroupText;

        Row := Default(TCollapsibleGridRow);
        Row.RowKind := crData;
        Row.GroupName := CurrentGroup;
        Row.RecNo := ADataSet.RecNo;
        Row.VisibleDataIndex := -1;
        if AOptions.KeyField <> '' then
          Row.KeyValue := FieldText(ADataSet, AOptions.KeyField);
        if Row.KeyValue = '' then
          Row.KeyValue := IntToStr(ADataSet.RecNo);
        SetLength(Row.Values, AOptions.Columns.Count);
        for I := 0 to AOptions.Columns.Count - 1 do
        begin
          Column := AOptions.Columns[I];
          Row.Values[I] := FieldText(ADataSet, Column.FieldName);
          if Assigned(AOptions.OnGetCellText) then
            AOptions.OnGetCellText(AOptions.Sender, ADataSet, Column, Row.Values[I]);
          if AOptions.RemoveFileNamePath then
            Row.Values[I] := RemoveFilePathIfPresent(Row.Values[I]);
        end;
        CurrentRows.Add(Row);
        Inc(CurrentSongCount);
        ADataSet.Next;
      end;
      FlushGroup;
    finally
      if (SavedBookmark <> nil) and ADataSet.BookmarkValid(SavedBookmark) then
        ADataSet.GotoBookmark(SavedBookmark);
      ADataSet.EnableControls;
    end;
  finally
    if SavedBookmark <> nil then
      ADataSet.FreeBookmark(SavedBookmark);
    CurrentRows.Free;
  end;
end;

class procedure TCollapsibleDBGridRowBuilder.BuildPreviewRows(
  const AColumns: TCollapsibleDBGridColumns; const AGroupCount, ARowsPerGroup: Integer;
  const AEmptyGroupText: string; AGroupState: TCollapsibleGroupState;
  ARows: TCollapsibleGridRows);
var
  GroupIndex: Integer;
  RowIndex: Integer;
  ColIndex: Integer;
  GroupName: string;
  Header: TCollapsibleGridRow;
  Row: TCollapsibleGridRow;
  VisibleIndex: Integer;

  function ColumnCaption(AIndex: Integer): string;
  begin
    Result := Trim(AColumns[AIndex].Header);
    if Result = '' then
      Result := Trim(AColumns[AIndex].FieldName);
    if Result = '' then
      Result := Format('Column %d', [AIndex + 1]);
  end;

begin
  ARows.Clear;
  if (AColumns = nil) or (AGroupState = nil) then
    Exit;
  VisibleIndex := 0;
  for GroupIndex := 1 to AGroupCount do
  begin
    GroupName := Format('Preview Group %d', [GroupIndex]);
    Header := Default(TCollapsibleGridRow);
    SetLength(Header.Values, AColumns.Count);
    Header.RowKind := crGroupHeader;
    Header.GroupName := GroupName;
    Header.GroupText := Format('%s (%d rows)', [GroupName, ARowsPerGroup]);
    Header.VisibleDataIndex := -1;
    if AColumns.Count > 0 then
      Header.Values[0] := Header.GroupText;
    ARows.Add(Header);
    if AGroupState.IsCollapsed(GroupName) then
      Continue;
    for RowIndex := 1 to ARowsPerGroup do
    begin
      Row := Default(TCollapsibleGridRow);
      SetLength(Row.Values, AColumns.Count);
      Row.RowKind := crData;
      Row.GroupName := GroupName;
      Row.KeyValue := Format('preview-%d-%d', [GroupIndex, RowIndex]);
      Row.RecNo := RowIndex;
      Row.VisibleDataIndex := VisibleIndex;
      Inc(VisibleIndex);
      for ColIndex := 0 to AColumns.Count - 1 do
        Row.Values[ColIndex] := Format('%s sample %d.%d', [ColumnCaption(ColIndex), GroupIndex, RowIndex]);
      ARows.Add(Row);
    end;
  end;
end;

end.
