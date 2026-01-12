CREATE OR ALTER FUNCTION dbo.fn_GetInventoryAtDate (@TargetDate DATETIME)
RETURNS TABLE
AS
RETURN (
    SELECT 
        W.WarehouseName,
        W.Address AS WarehouseAddress,
        P.PlaceName,
        G.GoodsName,
        B.BatchNum,
        -- 1. —читаем количество на дату (выносим в подзапрос или дублируем формулу)
        (BL.CurrentQty 
         + ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                   WHERE DL.BatchId = BL.BatchId AND DL.FromPlaceId = BL.PlaceId 
                   AND D.DocDate > @TargetDate AND D.DocType IN (2, 3)), 0)
         - ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                   WHERE DL.BatchId = BL.BatchId AND DL.ToPlaceId = BL.PlaceId 
                   AND D.DocDate > @TargetDate AND D.DocType IN (1, 3)), 0)
        ) AS QtyAtDate,
        
        B.PurchasePrice,

        -- 2. —читаем общую сумму (та же формула количества * цена)
        ((BL.CurrentQty 
         + ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                   WHERE DL.BatchId = BL.BatchId AND DL.FromPlaceId = BL.PlaceId 
                   AND D.DocDate > @TargetDate AND D.DocType IN (2, 3)), 0)
         - ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                   WHERE DL.BatchId = BL.BatchId AND DL.ToPlaceId = BL.PlaceId 
                   AND D.DocDate > @TargetDate AND D.DocType IN (1, 3)), 0)
        ) * B.PurchasePrice) AS TotalSum,

        B.BatchId,
        BL.LocId,
        G.GoodsId,
        B.PurchaseDate,
        P.PlaceId,
        W.WarehouseId
    FROM BatchLoc BL
    JOIN Batches B ON BL.BatchId = B.BatchId
    JOIN Goods G ON B.GoodsId = G.GoodsId
    JOIN Place P ON BL.PlaceId = P.PlaceId
    JOIN Warehouse W ON P.WarehouseId = W.WarehouseId
    -- —крываем пустые позиции на указанную дату
    WHERE (BL.CurrentQty 
           + ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                     WHERE DL.BatchId = BL.BatchId AND DL.FromPlaceId = BL.PlaceId 
                     AND D.DocDate > @TargetDate AND D.DocType IN (2, 3)), 0)
           - ISNULL((SELECT SUM(DL.Qty) FROM DocLines DL JOIN Documents D ON DL.DocId = D.DocId 
                     WHERE DL.BatchId = BL.BatchId AND DL.ToPlaceId = BL.PlaceId 
                     AND D.DocDate > @TargetDate AND D.DocType IN (1, 3)), 0)
          ) > 0
);