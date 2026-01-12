unit uWarehouses;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, udmMain, uDBUtils, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.Bind.DBScope, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Grid;

type
  TfrmWarehouse = class(TForm)
    Panel1: TPanel;
    btClose: TCornerButton;
    tbActions: TToolBar;
    btAdd: TSpeedButton;
    btDelete: TSpeedButton;
    gridWarehouse: TStringGrid;
    BindSourceDB: TBindSourceDB;
    BindingsList: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure btAddClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWarehouse: TfrmWarehouse;

implementation

{$R *.fmx}

procedure TfrmWarehouse.btAddClick(Sender: TObject);
begin
  dtmMain.qryWarehouse.Append;
  gridWarehouse.SetFocus;
end;

procedure TfrmWarehouse.btDeleteClick(Sender: TObject);
begin
  TDBUtils.safeDelete(dtmMain.qryWarehouse,
    'Удалить выбранный склад?',
    'Нельзя удалить: к складу привязаны стеллажи!');
end;

end.
