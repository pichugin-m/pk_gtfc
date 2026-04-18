program gtfc;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, u_form_main, u_gtfc_const, u_gtfc_drawcontrol, u_gtfc_logicaldraw,
  u_gtfc_visualobjects, u_gtfc_geometry, u_gtfc_objecttree;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='gtfc';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFgassicMain, FgassicMain);
  Application.Run;
end.

