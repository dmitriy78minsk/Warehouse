-- 1. Справочник товаров
CREATE TABLE Goods (
    GoodsId BIGINT PRIMARY KEY IDENTITY(1,1),
    GoodsName NVARCHAR(100) NOT NULL,
    SKU NVARCHAR(50) -- Артикул самого товара (модель)
);

-- 2. Склады (добавлен адрес)
CREATE TABLE Warehouse (
    WarehouseId BIGINT PRIMARY KEY IDENTITY(1,1),
    WarehouseName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) 
);

-- 3. Места хранения
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
    DocDate DATETIME DEFAULT GETDATE()
);

-- 5. Партии
CREATE TABLE Batches (
    BatchId BIGINT PRIMARY KEY IDENTITY(1,1),
    GoodsId BIGINT NOT NULL,
    BatchNum NVARCHAR(50),-- Артикул/номер конкретной партии для фильтрации
    PurchasePrice DECIMAL(18, 2) NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(), -- ТВОЕ ТРЕБОВАНИЕ: Дата закупки
    InitialQty DECIMAL(18, 3) NOT NULL, 
    CONSTRAINT FK_Batches_Goods FOREIGN KEY (GoodsId) REFERENCES Goods(GoodsId)
);

-- 6. Привязка к местам (остатки)
CREATE TABLE BatchLoc (
    LocId BIGINT PRIMARY KEY IDENTITY(1,1),
    BatchId BIGINT NOT NULL,
    PlaceId BIGINT NOT NULL,
    CurrentQty DECIMAL(18, 3) NOT NULL,
    CONSTRAINT FK_Loc_Batch FOREIGN KEY (BatchId) REFERENCES Batches(BatchId),
    CONSTRAINT FK_Loc_Place FOREIGN KEY (PlaceId) REFERENCES Place(PlaceId)
);

-- 7. Строки документа
CREATE TABLE DocLines (
    LineId BIGINT PRIMARY KEY IDENTITY(1,1),
    DocId BIGINT NOT NULL,
    BatchId BIGINT NOT NULL,
    Qty DECIMAL(18, 3) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_Lines_Doc FOREIGN KEY (DocID) REFERENCES Documents(DocID),
    CONSTRAINT FK_Lines_Batch FOREIGN KEY (BatchID) REFERENCES Batches(BatchID)
);