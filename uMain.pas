unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, udmMain,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, System.Rtti, FMX.Grid.Style,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.StdCtrls, uGoods, uWarehouses,
  uPlaces;

type
  TfrmMain = class(TForm)
    qryStock: TFDQuery;
    StringGrid1: TStringGrid;
    BindSourceDB: TBindSourceDB;
    BindingsList: TBindingsList;
    LinkGridToDataSourceBindSourceDB: TLinkGridToDataSource;
    toolbar: TToolBar;
    btGoods: TSpeedButton;
    btWarehouses: TSpeedButton;
    btPlaces: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure btGoodsClick(Sender: TObject);
    procedure btWarehousesClick(Sender: TObject);
    procedure btPlacesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.btGoodsClick(Sender: TObject);
var
  frmGoods: TfrmGoods;
begin
  frmGoods := TfrmGoods.Create(Self);
  try
    dtmMain.qryGoods.Open;
    frmGoods.ShowModal;
  finally
    dtmMain.qryGoods.Close;
    frmGoods.Free;
  end;
end;

procedure TfrmMain.btPlacesClick(Sender: TObject);
var
  frmPlaces: TfrmPlaces;
begin
  frmPlaces := TfrmPlaces.Create(Self);
  try
    dtmMain.qryWarehouse.Open;
    dtmMain.qryPlaces.Open;
    frmPlaces.ShowModal;
  finally
    dtmMain.qryPlaces.Close;
    dtmMain.qryWarehouse.Close;
    frmPlaces.Free;
  end;
end;

procedure TfrmMain.btWarehousesClick(Sender: TObject);
var
  frmWarehouse: TfrmWarehouse;
begin
  frmWarehouse := TfrmWarehouse.Create(Self);
  try
    dtmMain.qryWarehouse.Open;
    frmWarehouse.ShowModal;
    // qryStock.Refresh;
  finally
    dtmMain.qryWarehouse.Close;
    frmWarehouse.Free;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  try
    // Закрываем на случай, если он был открыт в дизайнере
    qryStock.Close;
    // Открываем запрос к базе
    qryStock.Open;
  except
    on E: Exception do
      ShowMessage('Ошибка при загрузке данных: ' + E.Message);
  end;
end;

end.
