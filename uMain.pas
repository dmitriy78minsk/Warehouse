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
  uPlaces, FMX.DateTimeCtrls;

type
  TfrmMain = class(TForm)
    toolbar: TToolBar;
    btGoods: TSpeedButton;
    btWarehouses: TSpeedButton;
    btPlaces: TSpeedButton;
    deReportDate: TDateEdit;
    teReportTime: TTimeEdit;
    lbDate: TLabel;
    btShowGoods: TSpeedButton;
    grInventory: TStringGrid;
    qryInventory: TFDQuery;
    qryInventoryWarehouseName: TWideStringField;
    qryInventoryWarehouseAddress: TWideStringField;
    qryInventoryPlaceName: TWideStringField;
    qryInventoryGoodsName: TWideStringField;
    qryInventoryBatchNum: TWideStringField;
    qryInventoryQtyAtDate: TFMTBCDField;
    qryInventoryPurchasePrice: TFMTBCDField;
    qryInventoryTotalSum: TFMTBCDField;
    qryInventoryBatchId: TLargeintField;
    qryInventoryLocId: TLargeintField;
    qryInventoryGoodsId: TLargeintField;
    qryInventoryPurchaseDate: TSQLTimeStampField;
    qryInventoryPlaceId: TLargeintField;
    qryInventoryWarehouseId: TLargeintField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure FormShow(Sender: TObject);
    procedure btGoodsClick(Sender: TObject);
    procedure btWarehousesClick(Sender: TObject);
    procedure btPlacesClick(Sender: TObject);
    procedure btShowGoodsClick(Sender: TObject);
  private
    procedure LoadInventory;
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

procedure TfrmMain.btShowGoodsClick(Sender: TObject);
begin
   LoadInventory();
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
    LoadInventory();
  except
    on E: Exception do
      ShowMessage('Ошибка при загрузке данных: ' + E.Message);
  end;
end;

procedure TfrmMain.LoadInventory;
var
  TargetDT: TDateTime;
begin
  TargetDT := Trunc(deReportDate.Date) + Frac(teReportTime.Time);

  qryInventory.Close;

  qryInventory.ParamByName('TARGETDATE').Value := TargetDT;

  qryInventory.Open;

end;

end.
