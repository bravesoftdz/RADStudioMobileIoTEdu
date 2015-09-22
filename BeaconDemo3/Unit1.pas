unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Media,
  System.Beacon, System.Beacon.Components;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Switch1: TSwitch;
    Image1: TImage;
    StatusBar1: TStatusBar;
    Label2: TLabel;
    Rectangle1: TRectangle;
    FloatAnimation1: TFloatAnimation;
    MediaPlayer1: TMediaPlayer;
    Beacon1: TBeacon;
    Timer1: TTimer;
    procedure Switch1Switch(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Beacon1BeaconEnter(const Sender: TObject; const ABeacon: IBeacon;
      const CurrentBeaconList: TBeaconList);
    procedure Beacon1BeaconExit(const Sender: TObject; const ABeacon: IBeacon;
      const CurrentBeaconList: TBeaconList);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FBeacon: IBeacon;

    procedure StartAlert;
    procedure StopAlert;
    // Ctrl + Shift + C: �ڵ��ϼ�
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils;

{ TForm1 }

procedure TForm1.Beacon1BeaconEnter(const Sender: TObject;
  const ABeacon: IBeacon; const CurrentBeaconList: TBeaconList);
begin
  FBeacon := ABeacon;
end;

procedure TForm1.Beacon1BeaconExit(const Sender: TObject;
  const ABeacon: IBeacon; const CurrentBeaconList: TBeaconList);
begin
  FBeacon := nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StopAlert;
end;

procedure TForm1.StartAlert;
var
  Path: string;
begin
  Rectangle1.Visible := True;
  FloatAnimation1.Enabled := True;

{$IFNDEF MSWINDOWS}
// MSWINDOWS�� �ƴѰ�� ����
  Path := TPath.Combine(TPath.GetDocumentsPath, 'alert.mp3');
  MediaPlayer1.FileName := Path;
{$ENDIF}

  MediaPlayer1.Play;
end;

procedure TForm1.StopAlert;
begin
  Rectangle1.Visible := False;
  FloatAnimation1.Enabled := False;

  MediaPlayer1.Stop;
end;

procedure TForm1.Switch1Switch(Sender: TObject);
begin
  Beacon1.Enabled := Switch1.IsChecked;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Assigned(FBeacon) then
  begin
    Label2.Text :=
      Format('������������ �Ÿ�: %2.1f', [FBeacon.Distance]);

    if FBeacon.Distance <= 1 then
      StartAlert
    else
      StopAlert;
  end;
end;

end.
