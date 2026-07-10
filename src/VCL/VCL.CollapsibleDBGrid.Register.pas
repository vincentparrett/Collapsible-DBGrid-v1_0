unit VCL.CollapsibleDBGrid.Register;

interface

procedure Register;

implementation

uses
  System.Classes, VCL.CollapsibleDBGrid;

procedure Register;
begin
  RegisterComponents('CollapsibleDBGrid', [TVCLCollapsibleDBGrid]);
end;

end.
