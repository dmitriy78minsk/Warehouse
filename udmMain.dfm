object dtmMain: TdtmMain
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object dbConn: TFDConnection
    Params.Strings = (
      'Database=WarehouseDB'
      'DriverID=MSSQL'
      'Server=localhost\SQLEXPRESS'
      'User_Name=sa'
      'Password=root'
      'Encrypt=No')
    Connected = True
    LoginPrompt = False
    Left = 24
    Top = 16
  end
  object driverLink: TFDPhysMSSQLDriverLink
    Left = 96
    Top = 16
  end
  object waitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 184
    Top = 16
  end
  object qryGoods: TFDQuery
    Connection = dbConn
    SQL.Strings = (
      'SELECT '
      '    GoodsId, '
      '    GoodsName, '
      '    SKU'
      'FROM Goods'
      'ORDER BY GoodsName')
    Left = 24
    Top = 96
    object qryGoodsGoodsId: TLargeintField
      AutoGenerateValue = arAutoInc
      FieldName = 'GoodsId'
      Origin = 'GoodsId'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryGoodsGoodsName: TWideStringField
      FieldName = 'GoodsName'
      Origin = 'GoodsName'
      Required = True
      Size = 100
    end
    object qryGoodsSKU: TWideStringField
      FieldName = 'SKU'
      Origin = 'SKU'
      Size = 50
    end
  end
  object qryWarehouse: TFDQuery
    Active = True
    AggregatesActive = True
    Connection = dbConn
    UpdateOptions.AutoIncFields = 'WarehouseId'
    SQL.Strings = (
      'SELECT '
      '    WarehouseId, '
      '    WarehouseName, '
      '    Address '
      'FROM Warehouse '
      'ORDER BY WarehouseName')
    Left = 104
    Top = 96
    object qryWarehouseWarehouseId: TLargeintField
      AutoGenerateValue = arAutoInc
      FieldName = 'WarehouseId'
      Origin = 'WarehouseId'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryWarehouseWarehouseName: TWideStringField
      FieldName = 'WarehouseName'
      Origin = 'WarehouseName'
      Required = True
      Size = 100
    end
    object qryWarehouseAddress: TWideStringField
      FieldName = 'Address'
      Origin = 'Address'
      Size = 255
    end
  end
  object qryPlaces: TFDQuery
    Active = True
    BeforePost = qryPlacesBeforePost
    AggregatesActive = True
    Connection = dbConn
    UpdateOptions.KeyFields = 'PlaceId'
    UpdateOptions.AutoIncFields = 'PlaceId'
    SQL.Strings = (
      'SELECT '
      '  PlaceId, '
      '  PlaceName, '
      '  WarehouseId '
      'FROM '
      '  Place')
    Left = 184
    Top = 96
    object qryPlacesPlaceId: TLargeintField
      AutoGenerateValue = arAutoInc
      FieldName = 'PlaceId'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryPlacesPlaceName: TWideStringField
      FieldName = 'PlaceName'
      Required = True
      Size = 100
    end
    object qryPlacesWarehouseId: TLargeintField
      FieldName = 'WarehouseId'
      Required = True
    end
    object qryPlacesWarehouseName_Lookup: TStringField
      FieldKind = fkLookup
      FieldName = 'WarehouseName_Lookup'
      LookupDataSet = qryWarehouse
      LookupKeyFields = 'WarehouseId'
      LookupResultField = 'WarehouseName'
      KeyFields = 'WarehouseId'
      Size = 100
      Lookup = True
    end
  end
end
