unit uDocManualOutgoing;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.EditBox, FMX.NumberBox,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmDocManualOutgoing = class(TForm)
    edtQty: TNumberBox;
    Label4: TLabel;
    edtDocNum: TEdit;
    Label2: TLabel;
    Panel1: TPanel;
    btClose: TCornerButton;
    CornerButton1: TCornerButton;
    spManualOut: TFDStoredProc;
    procedure btCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    selectedBatchId: Integer;
    selectedPlaceId: Integer;
  end;


implementation

{$R *.fmx}

procedure TfrmDocManualOutgoing.btCloseClick(Sender: TObject);
begin
  try
    if (edtDocNum.Text = '') then
    begin
      ShowMessage('Ошибка: Укажите номер документа!');
      Exit;
    end;

    spManualOut.Prepare;

    spManualOut.ParamByName('@BatchId').Value := SelectedBatchId;
    spManualOut.ParamByName('@PlaceId').Value := SelectedPlaceId;
    spManualOut.ParamByName('@Qty').Value     := edtQty.Value;
    spManualOut.ParamByName('@DocNum').Value  := edtDocNum.Text;

    spManualOut.ExecProc;

    ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Ошибка базы данных: ' + E.Message);
  end;
end;

end.
