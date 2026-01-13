unit uDocOutgoing;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.EditBox, FMX.NumberBox,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.ListBox;

type
  TWriteOffMode = (wmManual, wmFIFO); // Режимы: Ручной и FIFO

  TfrmDocOutgoing = class(TForm)
    edtQty: TNumberBox;
    Label4: TLabel;
    edtDocNum: TEdit;
    Label2: TLabel;
    Panel1: TPanel;
    btSave: TCornerButton;
    btClose: TCornerButton;
    spManualOut: TFDStoredProc;
    cbGoods: TComboBox;
    lbWarehouse: TLabel;
    cbWarehouse: TComboBox;
    lbGoods: TLabel;
    spFIFO: TFDStoredProc;
    procedure btSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FMode: TWriteOffMode;
    procedure SetMode(const Value: TWriteOffMode);
  public
    selectedBatchId: Integer;
    selectedPlaceId: Integer;
    property Mode: TWriteOffMode read FMode write SetMode;
  end;


implementation

{$R *.fmx}

uses udmMain;

procedure TfrmDocOutgoing.btSaveClick(Sender: TObject);
var
  goodsId, warehouseId: Integer;
begin
  try
    if (edtDocNum.Text = '') then
    begin
      ShowMessage('Ошибка: Укажите номер документа!');
      Exit;
    end;

    case FMode of
    wmManual:
    begin
     spManualOut.Prepare;

      spManualOut.ParamByName('@BatchId').Value := SelectedBatchId;
      spManualOut.ParamByName('@PlaceId').Value := SelectedPlaceId;
      spManualOut.ParamByName('@Qty').Value     := edtQty.Value;
      spManualOut.ParamByName('@DocNum').Value  := edtDocNum.Text;

      spManualOut.ExecProc;
    end;

    wmFIFO:
    begin
      if (cbGoods.ItemIndex = -1) or (cbWarehouse.ItemIndex = -1) then
      begin
        ShowMessage('Ошибка: Выберите товар и склад!');
        Exit;
      end;

      goodsId := Integer(cbGoods.Items.Objects[cbGoods.ItemIndex]);
      warehouseId := Integer(cbWarehouse.Items.Objects[cbWarehouse.ItemIndex]);

      spFIFO.Prepare;

      spFIFO.Params.ParamByName('@GoodsId').Value     := goodsId;
      spFIFO.Params.ParamByName('@WarehouseId').Value := warehouseId;
      spFIFO.Params.ParamByName('@QtyToIssue').Value  := edtQty.Value;
      spFIFO.Params.ParamByName('@DocNum').Value      := edtDocNum.Text;

      spFIFO.ExecProc;
    end;
  end;

  ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Ошибка базы данных: ' + E.Message);
  end;
end;

procedure TfrmDocOutgoing.FormCreate(Sender: TObject);
begin
  // 1. Склады
  dtmMain.qryWarehouse.Open; // Просто открываем, SQL уже внутри
  cbWarehouse.Items.Clear;
  while not dtmMain.qryWarehouse.Eof do
  begin
    cbWarehouse.Items.AddObject(
      dtmMain.qryWarehouse.FieldByName('WarehouseName').AsString,
      TObject(dtmMain.qryWarehouse.FieldByName('WarehouseId').AsInteger)
    );
    dtmMain.qryWarehouse.Next;
  end;

  // 2. Товары
  dtmMain.qryGoods.Open;
  cbGoods.Items.Clear;
  while not dtmMain.qryGoods.Eof do
  begin
    cbGoods.Items.AddObject(
      dtmMain.qryGoods.FieldByName('GoodsName').AsString,
      TObject(dtmMain.qryGoods.FieldByName('GoodsId').AsInteger)
    );
    dtmMain.qryGoods.Next;
  end;
end;

procedure TfrmDocOutgoing.SetMode(const Value: TWriteOffMode);
begin
  // 1. Сохраняем значение во внутреннюю переменную
  FMode := Value;

  // 2. Настраиваем визуальную часть
  case FMode of
    wmManual:
    begin
      lbWarehouse.Visible := False;
      cbGoods.Visible := False;
      cbWarehouse.Visible := False;
    end;

    wmFIFO:
    begin

    end;
  end;
end;

end.
