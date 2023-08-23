unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    swActive: TToggleSwitch;
    lblURL: TLabel;
    edtURL: TEdit;
    tmrRefresh: TTimer;
    lblValue: TLabel;
    procedure tmrRefreshTimer(Sender: TObject);
    procedure swActiveClick(Sender: TObject);
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

procedure  SetBrightness(Timeout : Integer; Brightness : Byte);
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\WMI', '', '');
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM WmiMonitorBrightnessMethods Where Active=True','WQL',$00000020);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    FWbemObject.WmiSetBrightness(Timeout, Brightness);
    FWbemObject:=Unassigned;
  end;
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

procedure TfrmMain.swActiveClick(Sender: TObject);
begin
  tmrRefresh.Enabled := swActive.IsOn;
end;

procedure TfrmMain.tmrRefreshTimer(Sender: TObject);
var
  LValue: Integer;
begin
  LValue := GetBrightnessValue(edtURL.Text);
  lblValue.Caption := LValue.ToString;
  SetBrightness(tmrRefresh.Interval, LValue);
end;

end.