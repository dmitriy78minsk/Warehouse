-- 1. Справочник товаров
CREATE TABLE Goods (
    GoodsId BIGINT PRIMARY KEY IDENTITY(1,1),
    GoodsName NVARCHAR(100) NOT NULL,
    SKU NVARCHAR(50) 
);

-- 2. Склады
CREATE TABLE Warehouse (
    WarehouseId BIGINT PRIMARY KEY IDENTITY(1,1),
    WarehouseName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) 
);

-- 3. Места хранения (полки/ячейки)
CREATE TABLE Place (
    PlaceId BIGINT PRIMARY KEY IDENTITY(1,1),
    WarehouseId BIGINT NOT NULL,
    PlaceName NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Place_Warehouse FOREIGN KEY (WarehouseId) REFERENCES Warehouse(WarehouseId)
);

-- 4. Заголовок документа
CREATE TABLE Documents (
    DocId BIGINT PRIMARY KEY IDENTITY(1,1),
    DocNum NVARCHAR(20) NOT NULL,
    DocDate DATETIME DEFAULT GETDATE(),
    DocType INT NOT NULL -- 1: Приход, 2: Расход, 3: Перемещение
);

-- 5. Партии (создаются при приходе)
CREATE TABLE Batches (
    BatchId BIGINT PRIMARY KEY IDENTITY(1,1),
    GoodsId BIGINT NOT NULL,
    BatchNum NVARCHAR(50),
    PurchasePrice DECIMAL(18, 2) NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    InitialQty DECIMAL(18, 3) NOT NULL, 
    CONSTRAINT FK_Batches_Goods FOREIGN KEY (GoodsId) REFERENCES Goods(GoodsId)
);

-- 6. Текущие остатки (Online срез)
CREATE TABLE BatchLoc (
    LocId BIGINT PRIMARY KEY IDENTITY(1,1),
    BatchId BIGINT NOT NULL,
    PlaceId BIGINT NOT NULL,
    CurrentQty DECIMAL(18, 3) NOT NULL,
    CONSTRAINT FK_Loc_Batch FOREIGN KEY (BatchId) REFERENCES Batches(BatchId),
    CONSTRAINT FK_Loc_Place FOREIGN KEY (PlaceId) REFERENCES Place(PlaceId)
);

-- 7. Строки документа (Журнал движений)
CREATE TABLE DocLines (
    LineId BIGINT PRIMARY KEY IDENTITY(1,1),
    DocId BIGINT NOT NULL,
    BatchId BIGINT NOT NULL,
    Qty DECIMAL(18, 3) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    -- Поля для перемещений и четкого учета:
    FromPlaceId BIGINT NULL, -- Откуда ушло (для Расхода и Перемещения)
    ToPlaceId BIGINT NULL,   -- Куда пришло (для Прихода и Перемещения)
    CONSTRAINT FK_Lines_Doc FOREIGN KEY (DocId) REFERENCES Documents(DocId),
    CONSTRAINT FK_Lines_Batch FOREIGN KEY (BatchId) REFERENCES Batches(BatchId),
    CONSTRAINT FK_Lines_FromPlace FOREIGN KEY (FromPlaceId) REFERENCES Place(PlaceId),
    CONSTRAINT FK_Lines_ToPlace FOREIGN KEY (ToPlaceId) REFERENCES Place(PlaceId)
);