-- Очищаем то, что могло создаться криво
DELETE FROM DocLines;
DELETE FROM Documents;
DELETE FROM BatchLoc;
DELETE FROM Batches;
DELETE FROM Place;
DELETE FROM Warehouse;
DELETE FROM Goods;

-- Включаем ручной ввод ID, чтобы не запутаться в связях
SET IDENTITY_INSERT Goods ON;
INSERT INTO Goods (GoodsId, GoodsName, SKU) VALUES (1, 'Монитор Samsung 24', 'SAM-24-IPS');
INSERT INTO Goods (GoodsId, GoodsName, SKU) VALUES (2, 'Клавиатура Logitech G213', 'LOGI-G213-RGB');
SET IDENTITY_INSERT Goods OFF;

SET IDENTITY_INSERT Warehouse ON;
INSERT INTO Warehouse (WarehouseId, WarehouseName, Address) VALUES (1, 'Основной склад', 'ул. Промышленная, 10');
SET IDENTITY_INSERT Warehouse OFF;

SET IDENTITY_INSERT Place ON;
INSERT INTO Place (PlaceId, WarehouseId, PlaceName) VALUES (1, 1, 'Стеллаж A-1');
INSERT INTO Place (PlaceId, WarehouseId, PlaceName) VALUES (2, 1, 'Стеллаж B-5');
SET IDENTITY_INSERT Place OFF;

-- Создаем Партию для мониторов
SET IDENTITY_INSERT Batches ON;
INSERT INTO Batches (BatchId, GoodsId, BatchNum, PurchasePrice, PurchaseDate, InitialQty) 
VALUES (1, 1, 'BATCH-SAM-001', 15000.00, GETDATE(), 10);
SET IDENTITY_INSERT Batches OFF;

-- РАСПРЕДЕЛЯЕМ мониторы по местам (Вот тут была пустота!)
INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty) VALUES (1, 1, 3.000); -- 3 шт на А-1
INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty) VALUES (1, 2, 7.000); -- 7 шт на B-5

-- Проверка
SELECT * FROM v_InventoryBalance;