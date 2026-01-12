program warehouse;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  udmMain in 'udmMain.pas' {dtmMain: TDataModule},
  uGoods in 'Dictionaries\uGoods.pas' {frmGoods},
  uDBUtils in 'Utils\uDBUtils.pas',
  uWarehouses in 'Dictionaries\uWarehouses.pas' {frmWarehouse},
  uPlaces in 'Dictionaries\uPlaces.pas' {frmPlaces},
  uDocIncoming in 'Docs\uDocIncoming.pas' {TfrmDocIncoming};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdtmMain, dtmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
