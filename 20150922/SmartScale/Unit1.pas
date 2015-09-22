unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.ScrollBox, FMX.Memo, FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation,
  System.Bluetooth, System.Bluetooth.Components;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Switch1: TSwitch;
    Layout1: TLayout;
    Memo1: TMemo;
    Text1: TText;
    Text2: TText;
    BluetoothLE1: TBluetoothLE;
    procedure Switch1Switch(Sender: TObject);
    procedure BluetoothLE1EndDiscoverDevices(const Sender: TObject;
      const ADeviceList: TBluetoothLEDeviceList);
    procedure BluetoothLE1EndDiscoverServices(const Sender: TObject;
      const AServiceList: TBluetoothGattServiceList);
    procedure BluetoothLE1CharacteristicRead(const Sender: TObject;
      const ACharacteristic: TBluetoothGattCharacteristic;
      AGattStatus: TBluetoothGattStatus);
  private
    { Private declarations }
    FBLEDevice: TBluetoothLEDevice; // Ctrl + [space]
    FBLEGattService: TBluetoothGattService;
    FBLEGattChar: TBluetoothGattCharacteristic;

    procedure StartScale;
    procedure StopScale; // Shift + Ctrl + C
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

const
  ScaleDeviceName = 'Wahoo';

  WEIGHT_SERVICE: TBluetoothUUID          = '{00001901-0000-1000-8000-00805F9B34FB}';
  WEIGHT_CHARACTERISTIC: TBluetoothUUID   = '{00002B01-0000-1000-8000-00805F9B34FB}';

procedure TForm1.Switch1Switch(Sender: TObject);
begin
  if Switch1.IsChecked then
    StartScale
  else
    StopScale;
end;

procedure TForm1.StartScale;
begin
  // 1, ��ġ�߰�
    // DiscoverDivices > OnEndDisconverDevices

  // 2, ���� �߰�
    // DiscoverServices > OnEndDiscoverServices

  // 3, ����
    // SubscribeToCharacteristics > OnCharacteristicRead

  BluetoothLE1.Enabled := True;
//  BluetoothLE1.DiscoverDevices(1000, [WEIGHT_SERVICE]);
  BluetoothLE1.DiscoverDevices(1000);
end;

procedure TForm1.BluetoothLE1EndDiscoverDevices(const Sender: TObject;
  const ADeviceList: TBluetoothLEDeviceList);
var
  Device: TBluetoothLEDevice;
begin
  if ADeviceList.Count = 0 then
  begin
    Memo1.Lines.Add('�߰ߵ� ��ġ�� �����ϴ�.');
    Switch1.IsChecked := False;
    Exit;
  end;

  FBLEDevice := nil;
  // forin > Ctrl + J
  for Device in ADeviceList do
  begin
    Memo1.Lines.Add(' - ' + Device.DeviceName);

    if Device.DeviceName.StartsWith(ScaleDeviceName) then
    begin
      FBLEDevice := Device;
      Memo1.Lines.Add('��� ã�ҽ��ϴ�.');
    end;
  end;

  if FBLEDevice = nil then
    Exit;

  // [TIP] ���� �߰��� �����ϴ� ��찡 ���� ����
    // ������ ��� �ѹ��� �߰߿�û
  if not FBLEDevice.DiscoverServices then
    FBLEDevice.DiscoverServices;
end;

procedure TForm1.BluetoothLE1EndDiscoverServices(const Sender: TObject;
  const AServiceList: TBluetoothGattServiceList);
begin
  FBLEGattService := BluetoothLE1.GetService(FBLEDevice, WEIGHT_SERVICE);
  if FBLEGattService = nil then
  begin
    Memo1.Lines.Add('WEIGHT ���񽺸� ã�� ���߽��ϴ�.');
    Exit;
  end;

  // [TIP] Ư������� �����ϱ� ���� �Ʒ� �ڵ� ȣ��
  BluetoothLE1.GetCharacteristics(FBLEGattService);
  FBLEGattChar := BluetoothLE1.GetCharacteristic(FBLEGattService, WEIGHT_CHARACTERISTIC);
  if FBLEGattChar = nil then
  begin
    Memo1.Lines.Add('WEIGHT ���� Ư���� ã�� ���߽��ϴ�.');
    Exit;
  end;

  if BluetoothLE1.SubscribeToCharacteristic(FBLEDevice, FBLEGattChar) then
    Memo1.Lines.Add('WEIGHT Ư���� �����߽��ϴ�.');
end;

procedure TForm1.BluetoothLE1CharacteristicRead(const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  AGattStatus: TBluetoothGattStatus);
var
  Weight: Single;
begin
  Weight := (ACharacteristic.GetValueAsInteger shr 8) / 10;

  Text1.Text := Format('%3.1f', [Weight]);
end;

procedure TForm1.StopScale;
begin
  if Assigned(FBLEDevice) then
    BluetoothLE1.UnSubscribeToCharacteristic(FBLEDevice, FBLEGattChar);
  BluetoothLE1.Enabled := False;
end;

end.
