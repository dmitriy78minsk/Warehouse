unit uPlaces;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, uDBUtils, udmMain, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, Fmx.Bind.Grid, Data.Bind.Grid, Data.Bind.Controls,
  FMX.ListBox, FMX.Edit, Data.DB, System.Actions, FMX.ActnList;

type
  TfrmPlaces = class(TForm)
    Panel1: TPanel;
    tbActions: TToolBar;
    btAdd: TSpeedButton;
    btDelete: TSpeedButton;
    gridPlaces: TStringGrid;
    BindingsList1: TBindingsList;
    srcPlaces: TBindSourceDB;
    srcWarehouse: TBindSourceDB;
    LinkGridToDataSourcesrcPlaces: TLinkGridToDataSource;
    LinkFillControlToField1: TLinkFillControlToField;
    Panel2: TPanel;
    CornerButton1: TCornerButton;
    cbWarehouse: TComboBox;
    lbWarehouses: TLabel;
    lbPlace: TLabel;
    edPlace: TEdit;
    LinkControlToField1: TLinkControlToField;
    btSave: TSpeedButton;
    ActionList: TActionList;
    acPost: TAction;
    procedure btAddClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure acPostExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPlaces: TfrmPlaces;

implementation

{$R *.fmx}

procedure TfrmPlaces.acPostExecute(Sender: TObject);
begin
  if dtmMain.qryPlaces.State in [dsEdit, dsInsert] then
  begin
    dtmMain.qryPlaces.Post;
  end;
end;

procedure TfrmPlaces.btAddClick(Sender: TObject);
begin
  if dtmMain.qryPlaces.State in [dsEdit, dsInsert] then
    dtmMain.qryPlaces.Post;

  dtmMain.qryPlaces.Append;

  edPlace.SetFocus;
end;

procedure TfrmPlaces.btDeleteClick(Sender: TObject);
begin
  TDBUtils.safeDelete(dtmMain.qryPlaces,
    'Удалить выбранное место?',
    'Нельзя удалить: место занято товаром!');
end;

end.
