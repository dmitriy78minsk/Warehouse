unit udmMain;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQLDef,
  FireDAC.FMXUI.Wait, FireDAC.Comp.UI, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL, Data.DB, FireDAC.Comp.Client, System.IniFiles,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FMX.Dialogs;

type
  TdtmMain = class(TDataModule)
    dbConn: TFDConnection;
    driverLink: TFDPhysMSSQLDriverLink;
    waitCursor: TFDGUIxWaitCursor;
    qryGoods: TFDQuery;
    qryGoodsGoodsId: TLargeintField;
    qryGoodsGoodsName: TWideStringField;
    qryGoodsSKU: TWideStringField;
    qryWarehouse: TFDQuery;
    qryWarehouseWarehouseId: TLargeintField;
    qryWarehouseWarehouseName: TWideStringField;
    qryWarehouseAddress: TWideStringField;
    qryPlaces: TFDQuery;
    qryPlacesPlaceId: TLargeintField;
    qryPlacesPlaceName: TWideStringField;
    qryPlacesWarehouseId: TLargeintField;
    qryPlacesWarehouseName_Lookup: TStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure qryPlacesBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dtmMain: TdtmMain;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uMain;

{$R *.dfm}

procedure TdtmMain.DataModuleCreate(Sender: TObject);
var
  ini: TIniFile;
  sPath: string;
begin
  // Определяем путь к INI в папке с EXE
  sPath := ExtractFilePath(ParamStr(0)) + 'config.ini';

  ini := TIniFile.Create(sPath);
  try
    dbConn.Connected := False;
    dbConn.Params.Clear;

    // Заполняем параметры подключения из INI
    dbConn.Params.Add('DriverID=MSSQL');
    dbConn.Params.Add('Server=' + ini.ReadString('Database', 'Server', '.\SQLEXPRESS'));
    dbConn.Params.Add('Database=' + ini.ReadString('Database', 'Database', 'WarehouseDB'));
    dbConn.Params.Add('User_Name=' + ini.ReadString('Database', 'User_Name', 'sa'));
    dbConn.Params.Add('TrustServerCertificate=Yes');
    dbConn.Params.Add('Encrypt=No');
    dbConn.Params.Add('Password=' + ini.ReadString('Database', 'Password', ''));

    try
      dbConn.Connected := True;
    except
      on E: Exception do
        raise Exception.Create('Не удалось подключиться к БД: ' + E.Message);
    end;

  finally
    ini.Free;
  end;
end;

procedure TdtmMain.qryPlacesBeforePost(DataSet: TDataSet);
begin
  if DataSet.FieldByName('PlaceName').AsString.Trim = '' then
  begin
    ShowMessage('Ошибка: Название места не может быть пустым!');
    Abort;
  end;
  if DataSet.FieldByName('WarehouseId').AsString.Trim = '' then
  begin
    ShowMessage('Ошибка: Не выбран склад!');
    Abort;
  end;
end;

end.
