program MonitorBrightness;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Blue');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
