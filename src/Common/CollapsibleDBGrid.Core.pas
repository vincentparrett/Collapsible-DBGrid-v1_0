unit CollapsibleDBGrid.Core;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TCollapsibleGridRowKind = (crGroupHeader, crData);

  TCollapsibleGridRow = record
    RowKind: TCollapsibleGridRowKind;
    GroupName: string;
    GroupText: string;
    KeyValue: string;
    RecNo: Integer;
    VisibleDataIndex: Integer;
    Values: TArray<string>;
  end;

  TCollapsibleGridRows = TList<TCollapsibleGridRow>;

  TCollapsibleGroupState = class(TPersistent)
  private
    FDefaultCollapsed: Boolean;
    FStates: TDictionary<string, Boolean>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function IsCollapsed(const AGroupName: string): Boolean;
    procedure SetCollapsed(const AGroupName: string; const ACollapsed: Boolean);
    property DefaultCollapsed: Boolean read FDefaultCollapsed write FDefaultCollapsed;
  end;

function CollapsibleNormalizeGroupName(const AGroupName, AEmptyText: string): string;
implementation

function CollapsibleNormalizeGroupName(const AGroupName, AEmptyText: string): string;
begin
  Result := Trim(AGroupName);
  if Result = '' then
    Result := AEmptyText;
end;

constructor TCollapsibleGroupState.Create;
begin
  inherited Create;
  FDefaultCollapsed := True;
  FStates := TDictionary<string, Boolean>.Create;
end;

destructor TCollapsibleGroupState.Destroy;
begin
  FStates.Free;
  inherited Destroy;
end;

procedure TCollapsibleGroupState.Clear;
begin
  FStates.Clear;
end;

function TCollapsibleGroupState.IsCollapsed(const AGroupName: string): Boolean;
begin
  if not FStates.TryGetValue(AGroupName, Result) then
  begin
    Result := FDefaultCollapsed;
    FStates.AddOrSetValue(AGroupName, Result);
  end;
end;

procedure TCollapsibleGroupState.SetCollapsed(const AGroupName: string;
  const ACollapsed: Boolean);
begin
  FStates.AddOrSetValue(AGroupName, ACollapsed);
end;

end.
