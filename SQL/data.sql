-- 1. ОЧИСТКА
TRUNCATE TABLE DocLines;
DELETE FROM Documents;    DBCC CHECKIDENT ('Documents', RESEED, 0);
DELETE FROM BatchLoc;
DELETE FROM Batches;      DBCC CHECKIDENT ('Batches', RESEED, 0);
DELETE FROM Place;        DBCC CHECKIDENT ('Place', RESEED, 0);
DELETE FROM Warehouse;    DBCC CHECKIDENT ('Warehouse', RESEED, 0);
DELETE FROM Goods;        DBCC CHECKIDENT ('Goods', RESEED, 0);

PRINT '--- 1. База очищена ---';

-- 2. ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ
-- ----------------------------------------------------------
INSERT INTO Goods (GoodsName, SKU) VALUES ('Монитор 24 дюйма', 'MON-24-IPS'); -- GoodsId: 1
INSERT INTO Warehouse (WarehouseName, Address) VALUES ('Основной склад', 'ул. Промышленная, 1'); -- WarehouseId: 1
INSERT INTO Warehouse (WarehouseName, Address) VALUES ('Склад выдачи', 'ул. Центральная, 10'); -- WarehouseId: 2

INSERT INTO Place (WarehouseId, PlaceName) VALUES (1, 'Полка А-1'); -- PlaceId: 1
INSERT INTO Place (WarehouseId, PlaceName) VALUES (2, 'Зона выдачи'); -- PlaceId: 2

PRINT '--- 2. Справочники заполнены ---';

-- 3. СОБЫТИЕ: ПРИХОД (100 шт на Полку А-1)
-- ----------------------------------------------------------
EXEC dbo.sp_AddIncoming 
    @GoodsId = 1, 
    @PlaceId = 1, 
    @Qty = 100.000, 
    @Price = 1500.00, 
    @BatchNum = 'BATCH-001', 
    @DocNum = 'V-001';

PRINT '--- 3. Приход выполнен (sp_AddIncoming) ---';

-- 4. СОБЫТИЕ: ПЕРЕМЕЩЕНИЕ (30 шт с Полки А-1 в Зону выдачи)
-- ----------------------------------------------------------
EXEC dbo.sp_MoveStock
    @BatchId = 1,
    @FromPlaceId = 1,
    @ToPlaceId = 2,
    @Qty = 30.000,
    @DocNum = 'T-001';

PRINT '--- 4. Перемещение выполнено (sp_MoveStock) ---';

-- 5. СОБЫТИЕ: РАСХОД MANUAL (10 шт из Зоны выдачи)
-- ----------------------------------------------------------
EXEC dbo.sp_AddOutgoingManual
    @BatchId = 1,
    @PlaceId = 2,
    @Qty = 10.000,
    @DocNum = 'S-001-MAN';

PRINT '--- 5. Ручной расход выполнен (sp_AddOutgoingManual) ---';

-- 6. СОБЫТИЕ: РАСХОД FIFO (5 шт с Основного склада)
-- ----------------------------------------------------------
-- Процедура сама найдет остаток на PlaceId 1 (где осталось 70 шт)
EXEC dbo.sp_AddOutgoingFIFO
    @GoodsId = 1,
    @WarehouseId = 1,
    @QtyToIssue = 5.000,
    @DocNum = 'S-002-FIFO';

PRINT '--- 6. FIFO расход выполнен (sp_AddOutgoingFIFO) ---';

