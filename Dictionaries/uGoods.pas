unit uGoods;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, udmMain, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FMX.DialogService, FireDAC.Stan.Intf, Data.DB, uDBUtils;

type
  TfrmGoods = class(TForm)
    tbActions: TToolBar;
    Panel1: TPanel;
    btClose: TCornerButton;
    btAdd: TSpeedButton;
    btDelete: TSpeedButton;
    gridGoods: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure btAddClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGoods: TfrmGoods;

implementation

{$R *.fmx}

procedure TfrmGoods.btAddClick(Sender: TObject);
begin
  dtmMain.qryGoods.Append;
  gridGoods.SetFocus;
end;

procedure TfrmGoods.btDeleteClick(Sender: TObject);
begin
  TDBUtils.safeDelete(dtmMain.qryGoods,
    'Удалить выбранный товар?',
    'Нельзя удалить: товар используется в документах!');
end;

end.
