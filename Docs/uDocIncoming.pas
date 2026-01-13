unit uDocIncoming;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, udmMain, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.EditBox,
  FMX.NumberBox, FMX.Edit;

type
  TTfrmDocIncoming = class(TForm)
    lbGoods: TLabel;
    cbGoods: TComboBox;
    lbWarehouse: TLabel;
    cbWarehouse: TComboBox;
    qryPlacesByWarehouse: TFDQuery;
    qryPlacesByWarehousePlaceId: TLargeintField;
    qryPlacesByWarehousePlaceName: TWideStringField;
    qryPlacesByWarehouseWarehouseId: TLargeintField;
    Label1: TLabel;
    cbPlaces: TComboBox;
    Label2: TLabel;
    edtDocNum: TEdit;
    Label3: TLabel;
    edtBatchNum: TEdit;
    edtQty: TNumberBox;
    Label4: TLabel;
    Label5: TLabel;
    edtPrice: TNumberBox;
    Panel1: TPanel;
    btClose: TCornerButton;
    CornerButton1: TCornerButton;
    spAddIncoming: TFDStoredProc;
    procedure FormCreate(Sender: TObject);
    procedure cbWarehouseChange(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDocIncoming: TTfrmDocIncoming;

implementation

{$R *.fmx}

procedure TTfrmDocIncoming.btCloseClick(Sender: TObject);
var
  goodsId, placeId: Integer;
begin
  // Проверки "на пустые поля"
  if (cbGoods.ItemIndex = -1) or (cbPlaces.ItemIndex = -1) then
  begin
    ShowMessage('Ошибка: Выберите товар и место!');
    Exit;
  end;

  if (edtQty.Text = '') or (edtPrice.Text = '') then
  begin
    ShowMessage('Ошибка: Укажите количество и цену!');
    Exit;
  end;

  // Получаем ID из выпадающих списков
  goodsId := Integer(cbGoods.Items.Objects[cbGoods.ItemIndex]);
  placeId := Integer(cbPlaces.Items.Objects[cbPlaces.ItemIndex]);

  try
    // Настройка и запуск хранимой процедуры в DataModule
    spAddIncoming.Prepare;

    spAddIncoming.ParamByName('@GoodsId').AsInteger := goodsId;
    spAddIncoming.ParamByName('@PlaceId').AsInteger := placeId;
    spAddIncoming.ParamByName('@Qty').Value        := edtQty.Value;
    spAddIncoming.ParamByName('@Price').Value      := edtPrice.Value;
    spAddIncoming.ParamByName('@BatchNum').AsString  := edtBatchNum.Text;
    spAddIncoming.ParamByName('@DocNum').AsString    := edtDocNum.Text;

    spAddIncoming.ExecProc;

    ShowMessage('Товар успешно принят на склад!');

    ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Ошибка БД: ' + E.Message);
  end;

end;

procedure TTfrmDocIncoming.cbWarehouseChange(Sender: TObject);
var
  SelectedWHId: Integer;
begin
  // 1. Проверяем, выбрано ли что-то в списке складов
  if cbWarehouse.ItemIndex = -1 then
  begin
    cbPlaces.Items.Clear;
    Exit;
  end;

  // 2. Извлекаем WarehouseId, который мы сохранили в Objects при загрузке
  SelectedWHId := Integer(cbWarehouse.Items.Objects[cbWarehouse.ItemIndex]);

  // 3. Работаем с запросом мест хранения в DataModule
  qryPlacesByWarehouse.Close;
  // Используем параметр, который прописан в SQL (WHERE WarehouseId = :WHID)
  qryPlacesByWarehouse.ParamByName('WHID').AsInteger := SelectedWHId;
  qryPlacesByWarehouse.Open;

  // 4. Заполняем список мест (полки/зоны)
  cbPlaces.Items.Clear;
  while not qryPlacesByWarehouse.Eof do
  begin
    cbPlaces.Items.AddObject(
      qryPlacesByWarehouse.FieldByName('PlaceName').AsString,
      TObject(qryPlacesByWarehouse.FieldByName('PlaceId').AsInteger)
    );
    qryPlacesByWarehouse.Next;
  end;

//  // 5. Визуальное удобство: если места есть, выбираем первое по умолчанию
//  if cbPlaces.Items.Count > 0 then
//    cbPlaces.ItemIndex := 0
//  else
//    cbPlaces.Text := 'Нет доступных мест';
end;

procedure TTfrmDocIncoming.FormCreate(Sender: TObject);
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

end.
