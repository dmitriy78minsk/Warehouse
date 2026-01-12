-- 1. ОЧИСТКА (Соблюдаем порядок из-за внешних ключей)
TRUNCATE TABLE DocLines;
DELETE FROM Documents;    DBCC CHECKIDENT ('Documents', RESEED, 0);
DELETE FROM BatchLoc;
DELETE FROM Batches;      DBCC CHECKIDENT ('Batches', RESEED, 0);
DELETE FROM Place;        DBCC CHECKIDENT ('Place', RESEED, 0);
DELETE FROM Warehouse;    DBCC CHECKIDENT ('Warehouse', RESEED, 0);
DELETE FROM Goods;        DBCC CHECKIDENT ('Goods', RESEED, 0);

-- 2. СПРАВОЧНИКИ (Создаем ID 1 и ID 2)
INSERT INTO Goods (GoodsName, SKU) VALUES ('Монитор 24 дюйма', 'MON-24-IPS'); -- GoodsId: 1
INSERT INTO Warehouse (WarehouseName, Address) VALUES ('Основной склад', 'ул. Промышленная, 1'); -- WarehouseId: 1
INSERT INTO Warehouse (WarehouseName, Address) VALUES ('Склад выдачи', 'ул. Центральная, 10'); -- WarehouseId: 2

INSERT INTO Place (WarehouseId, PlaceName) VALUES (1, 'Полка А-1'); -- PlaceId: 1
INSERT INTO Place (WarehouseId, PlaceName) VALUES (2, 'Зона выдачи'); -- PlaceId: 2

-- 3. СОБЫТИЕ: ПРИХОД (01.01.2026)
-- Партия №1
INSERT INTO Batches (GoodsId, BatchNum, PurchasePrice, PurchaseDate, InitialQty)
VALUES (1, 'BATCH-001', 150.00, '20260101 10:00:00', 100); -- BatchId: 1

-- Документ №1 (Приход)
INSERT INTO Documents (DocNum, DocDate, DocType) 
VALUES ('V-001', '20260101 10:00:00', 1); -- DocId: 1

-- Строка документа (Приход на PlaceId 1)
INSERT INTO DocLines (DocId, BatchId, Qty, Price, ToPlaceId) 
VALUES (1, 1, 100, 150.00, 1);

-- Остаток: 100 на Складе 1
INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty) VALUES (1, 1, 100);


-- 4. СОБЫТИЕ: ПЕРЕМЕЩЕНИЕ (05.01.2026)
-- Документ №2 (Перемещение)
INSERT INTO Documents (DocNum, DocDate, DocType) 
VALUES ('T-001', '20260105 12:00:00', 3); -- DocId: 2

-- Строка: с 1 на 2 (30 шт)
INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId, ToPlaceId) 
VALUES (2, 1, 30, 150.00, 1, 2);

-- Обновляем остатки: на первом стало 70, на втором появилось 30
UPDATE BatchLoc SET CurrentQty = 70 WHERE BatchId = 1 AND PlaceId = 1;
INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty) VALUES (1, 2, 30);


-- 5. СОБЫТИЕ: РАСХОД (10.01.2026)
-- Документ №3 (Расход)
INSERT INTO Documents (DocNum, DocDate, DocType) 
VALUES ('S-001', '20260110 15:30:00', 2); -- DocId: 3

-- Строка: уход со склада 2 (10 шт)
INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId) 
VALUES (3, 1, 10, 200.00, 2);

-- Обновляем остаток: на втором складе осталось 20
UPDATE BatchLoc SET CurrentQty = 20 WHERE BatchId = 1 AND PlaceId = 2;

-- ПРОВЕРКА ТЕКУЩЕГО СОСТОЯНИЯ
SELECT 'Текущий остаток' as Status, G.GoodsName, W.WarehouseName, P.PlaceName, BL.CurrentQty 
FROM BatchLoc BL
JOIN Place P ON BL.PlaceId = P.PlaceId
JOIN Warehouse W ON P.WarehouseId = W.WarehouseId
JOIN Batches B ON BL.BatchId = B.BatchId
JOIN Goods G ON B.GoodsId = G.GoodsId;