unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TfrmMain = class(TForm)
    swActive: TToggleSwitch;
    lblURL: TLabel;
    edtURL: TEdit;
    tmrRefresh: TTimer;
    tbBrightness: TTrackBar;
    spnInterval: TUpDown;
    lblInterval: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    sbStatus: TStatusBar;
    procedure tmrRefreshTimer(Sender: TObject);
    procedure swActiveClick(Sender: TObject);
    procedure tbBrightnessChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure spnIntervalChanging(Sender: TObject; var AllowChange: Boolean);
  private
    function GetBrightnessValue(const AUrl: string): integer;
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.Win.ComObj,
  IdHTTP,
  WinApi.ActiveX;

procedure SetBrightness(Timeout: Integer; Brightness: Byte);
var
  FSWbemLocator: OleVariant;
  FWMIService: OleVariant;
  FWbemObjectSet: OleVariant;
  FWbemObject: OleVariant;
  oEnum: IEnumVARIANT;
  iValue: LongWord;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\WMI', '', '');
  FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM WmiMonitorBrightnessMethods Where Active=True','WQL',$00000020);
  oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;

  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    FWbemObject.WmiSetBrightness(Timeout, Brightness);
    FWbemObject := Unassigned;
  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  LInterval: Integer;
begin
  LInterval := tmrRefresh.Interval div 1000;
  lblInterval.Caption := LInterval.ToString + ' Sek.';
end;

function TfrmMain.GetBrightnessValue(const AUrl: string): integer;
var
  HTTP: TIdHTTP;
  ContentStream: TStringStream;
begin
  HTTP := TIdHTTP.Create(nil);
  ContentStream := TStringStream.Create;
  try
    HTTP.Get(AUrl, ContentStream);
    if HTTP.ResponseCode = 200 then
      Result := ContentStream.DataString.ToInteger
    else
      Result := -1;
  finally
    ContentStream.Free;
    HTTP.Free;
  end;
end;

procedure TfrmMain.spnIntervalChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  tmrRefresh.Interval := spnInterval.Position * 1000;
  lblInterval.Caption := spnInterval.Position.ToString + ' Sek.';
end;

procedure TfrmMain.swActiveClick(Sender: TObject);
begin
  tmrRefresh.Enabled := swActive.IsOn;
end;

procedure TfrmMain.tbBrightnessChange(Sender: TObject);
begin
  SetBrightness(tmrRefresh.Interval, tbBrightness.Position);
  sbStatus.Panels[0].Text := Format('Helligkeit: %d %', [tbBrightness.Position]);
end;

procedure TfrmMain.tmrRefreshTimer(Sender: TObject);
var
  LValue: Integer;
begin
  LValue := GetBrightnessValue(edtURL.Text);
  tbBrightness.Position := LValue;
  SetBrightness(tmrRefresh.Interval, LValue);
  sbStatus.Panels[0].Text := FormatDateTime('hh:mm:ss', Now) + Format(' - Helligkeit: %d %', [LValue]);
end;

end.
