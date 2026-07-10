unit FMX.CollapsibleDBGrid.Register;

interface

procedure Register;

implementation

uses
  System.Classes, FMX.CollapsibleDBGrid;

procedure Register;
begin
  RegisterComponents('CollapsibleDBGrid', [TFMXCollapsibleDBGrid]);
end;

end.
